provide *

import shared-gdrive("interp-lazy-definitions.arr", "0BwTSVb9gEh9-TjNBZXBzVUNiekE") as C

is-desugared = C.is-desugared

fun eval(str :: String) -> C.Value:
  doc: "Parse, desugar, and interpret a lazy Paret program."
  expr = desugar(C.parse(str))
  comp = C.r-comp(C.c-suspend(expr, empty))
  force(comp)
end

fun force(rc :: C.RefComputation) -> C.Value:
  cases(C.Computation) rc!comp:
    | c-value(val) =>
      # This computation has already been done, so just return the result
      val
    | c-suspend(expr, env) =>
      # Compute the value
      val = interp(expr, env)
      # Update the reference so that we don't have to compute it again
      rc!{comp: C.c-value(val)}
      # Return the value we just computed
      val
  end
end

fun desugar(expr :: C.Expr) -> C.Expr%(is-desugared):
  doc: "desugar 'sugar-and' and 'sugar-or' and 'sugar-let' in an expression."
    cases (C.Expr) expr:
    | e-num(_) => expr
    | e-str(_) => expr
    | e-bool(_) => expr
    | e-op(op, l, r) => C.e-op(op, desugar(l), desugar(r))
    | e-if(cond, cons, alt) => C.e-if(desugar(cond), desugar(cons), desugar(alt))
    | e-lam(params, body) => C.e-lam(params, desugar(body))
    | e-app(func, args) => C.e-app(desugar(func), args.map(desugar))
    | e-id(_) => expr
      
    | e-rec(fields) => C.e-rec(fields.map(lam(x): (C.e-field(x.field-name, desugar(x.value))) end))
    | e-lookup(record, name) => C.e-lookup(desugar(record), name)
    | e-extend(record, name, new-value) => C.e-extend(desugar(record), name, desugar(new-value))
     
    | sugar-and(l, r) => C.e-if(desugar(l), C.e-if(desugar(r), C.e-bool(true), C.e-bool(false)), C.e-bool(false))
    | sugar-or(l, r) => C.e-if(desugar(l), C.e-bool(true), C.e-if(desugar(r), C.e-bool(true), C.e-bool(false)))
    | sugar-let(bindings, body) => C.e-app(C.e-lam(bindings.map(lam(x): x.name end), desugar(body)), bindings.map(lam(x): desugar(x.expr) end))
  end
end



fun interp(expr :: C.Expr%(is-desugared), env :: C.Env) -> C.Value:
  doc: "Compute the result of evaluating the given expression."
  cases (C.Expr) expr:
    | e-num(v) => C.v-num(v)
    | e-str(v) => C.v-str(v)
    | e-bool(v) => C.v-bool(v)
    | e-op(op, l, r) => binop-interp(op, l, r, env)
    | e-if(cond, cons, alt) => if-interp(cond, cons, alt, env)
    | e-lam(params, body) => C.v-fun(params, body, env)
    | e-app(func, args) => fun-app-interp(func, args, env)
    | e-id(name) => get-binding(name, env)
      
    | e-rec(fields) => C.v-rec(fields.map(lam(x): C.v-field(x.field-name, C.r-comp(C.c-suspend(x.value, env))) end))
    | e-lookup(record, name) => 
      rec-val = interp(record, env)
      if C.is-v-rec(rec-val):
        lookup-interp(rec-val.fields, name)
      else:
        raise(C.err-not-a-record(rec-val))
      end
    | e-extend(record, name, new-value) => 
      rec-val = interp(record, env)
      if C.is-v-rec(rec-val):
        C.v-rec(extend-interp(rec-val.fields, name, C.r-comp(C.c-suspend(new-value, env))))
      else:
        raise(C.err-not-a-record(rec-val))
      end
  end
end



fun lookup-interp(fields :: List<C.FieldVal>, name :: String) -> C.Value:
  doc: "interpret lookup expressions"
  cases (List<C.FieldVal>) fields:
    | empty => raise(C.err-field-not-found(C.v-rec(fields), name))
    | link(hd, tl) => 
      if hd.field-name == name:
        force(hd.value)
      else:
        lookup-interp(tl, name)
      end
  end
end

fun extend-interp(fields :: List<C.FieldVal>, name :: String, new-value :: C.RefComputation) -> List<C.FieldVal>:
  doc: "interpret extend expressions"
  cases (List<C.FieldVal>) fields:
    | empty => link(C.v-field(name, new-value), empty)
    | link(hd, tl) => 
      if hd.field-name == name:
        link(C.v-field(name, new-value), tl)
      else:
        link(hd, extend-interp(tl, name, new-value))
      end
  end
end



















fun fun-app-interp(func :: C.Expr, args :: List<C.Expr>, env :: C.Env) -> C.Value:
  doc: "interpret function applications"
  arg-vs = args.map(lam(x): C.r-comp(C.c-suspend(x, env)) end)
  f-val = interp(func, env)
  if C.is-v-fun(f-val):
    if arg-vs.length() == f-val.params.length():
      new-env = (map2(lam(x, y): C.env-cell(x, y) end, f-val.params, arg-vs)).append(f-val.env)
      interp(f-val.body, new-env)
    else:
      raise(C.err-arity-mismatch(f-val.params.length(), arg-vs.length()))
    end
  else:
    raise(C.err-not-a-function(f-val))
  end
end

fun get-binding(name :: String, env :: C.Env) -> C.Value:
  doc: "find the value associated with the given identifier name"
  cases (C.Env) env:
    | empty => raise(C.err-unbound-id(name))
    | link(hd, tl) => 
      if hd.name == name:
        force(hd.value)
      else:
        get-binding(name, tl)
      end
  end
end

fun binop-interp (op :: C.Operator, l :: C.Expr, r :: C.Expr, env :: C.Env) -> C.Value:
  doc: "interpret an expression corresponding to a binary operator applied to two arguments"
  l-v = interp(l, env)
  r-v = interp(r, env)
  cases (C.Operator) op:
    | op-plus => 
      if C.is-v-num(l-v):
        if C.is-v-num(r-v):
          C.v-num(l-v.value + r-v.value)
        else:
          raise(C.err-bad-arg-to-op(op, r-v))
        end
      else:
        raise(C.err-bad-arg-to-op(op, l-v))
      end
    | op-append =>
      if C.is-v-str(l-v):
        if C.is-v-str(r-v):
          C.v-str(l-v.value + r-v.value)
        else:
          raise(C.err-bad-arg-to-op(op, r-v))
        end
      else:
        raise(C.err-bad-arg-to-op(op, l-v))
      end
    | op-num-eq =>
      if C.is-v-num(l-v):
        if C.is-v-num(r-v):
          C.v-bool(l-v.value == r-v.value)
        else:
          raise(C.err-bad-arg-to-op(op, r-v))
        end
      else:
        raise(C.err-bad-arg-to-op(op, l-v))
      end
    | op-str-eq =>
      if C.is-v-str(l-v):
        if C.is-v-str(r-v):
          C.v-bool(l-v.value == r-v.value)
        else:
          raise(C.err-bad-arg-to-op(op, r-v))
        end
      else:
        raise(C.err-bad-arg-to-op(op, l-v))
      end
  end
end

fun if-interp (cond :: C.Expr, cons :: C.Expr, alt :: C.Expr, env :: C.Env) -> C.Value:
  doc: "intepret if expressions"
  cond-v = interp(cond, env)
  cases (C.Value) cond-v:
    | v-bool(b) => 
      if b:
        interp(cons, env)
      else:
        interp(alt, env)
      end
    | else => raise(C.err-if-got-non-boolean(cond-v))
  end
end
