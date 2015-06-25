provide *

import shared-gdrive("interp-state-definitions.arr", "0BwTSVb9gEh9-dU41NklRaEJISWM") as C


is-desugared = C.is-desugared

fun eval(str :: String) -> C.Value:
  doc: "Parse, desugar, and interpret a Paret program."
  interp(desugar(C.parse(str)), empty, empty).value
end

fun desugar(expr :: C.Expr) -> C.Expr%(is-desugared):
  doc: "desugar 'sugar-and','sugar-or', 'sugar-let', and 'sugar-rec-lam' in an expression."
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
    | e-with(record, body) => C.e-with(desugar(record), desugar(body))
     
    | e-set(name, val) => C.e-set(name, desugar(val))
    | e-do(stmts) => C.e-do(stmts.map(desugar))
      
    | sugar-and(l, r) => C.e-if(desugar(l), C.e-if(desugar(r), C.e-bool(true), C.e-bool(false)), C.e-bool(false))
    | sugar-or(l, r) => C.e-if(desugar(l), C.e-bool(true), C.e-if(desugar(r), C.e-bool(true), C.e-bool(false)))
    | sugar-let(bindings, body) => C.e-app(C.e-lam(bindings.map(lam(x): x.name end), desugar(body)), bindings.map(lam(x): desugar(x.expr) end))
      
    | sugar-rec-lam(fun-name, params, body) => desugar(C.sugar-let(link(C.binding(fun-name, C.e-str("dummy")), empty), C.e-set(fun-name, C.e-lam(params, desugar(body)))))
  end
end






fun interp(expr :: C.Expr%(is-desugared), env :: C.Env, store :: C.Store) -> C.Result:
  doc: "Compute the result of evaluating the given expression."
  cases (C.Expr) expr:
    | e-num(v) => C.result(C.v-num(v), store)
    | e-str(v) => C.result(C.v-str(v), store)
    | e-bool(v) => C.result(C.v-bool(v), store)
    | e-op(op, l, r) => binop-interp(op, l, r, env, store)
    | e-if(cond, cons, alt) => if-interp(cond, cons, alt, env, store)
      
    | e-lam(params, body) => C.result(C.v-fun(params, body, env), store)
      
    | e-app(func, args) => 
      f-res = interp(func, env, store)
      if C.is-v-fun(f-res.value):
        if f-res.value.params.length() == args.length():
          app-interp(f-res.value, args, env, f-res.store)
        else:
          raise(C.err-arity-mismatch(f-res.value.params.length(), args.length()))
        end
      else:
        raise(C.err-not-a-function(f-res.value))
      end
        
    | e-id(name) => C.result(get-store(get-binding(name, env), store), store)
      
    | e-rec(fields) => rec-interp(fields, env, store, empty)
    | e-lookup(record, name) => 
      rec-res = interp(record, env, store)
      if C.is-v-rec(rec-res.value):
        C.result(lookup-interp(rec-res.value.fields, name), rec-res.store)
      else:
        raise(C.err-not-a-record(rec-res.value))
      end
    | e-extend(record, name, new-value) => 
      rec-res = interp(record, env, store)
      if C.is-v-rec(rec-res.value):
        new-val-res = interp(new-value, env, rec-res.store)
        new-rec = C.v-rec(extend-interp(rec-res.value.fields, new-val-res.value, name))
        C.result(new-rec, new-val-res.store)
      else:
        raise(C.err-not-a-record(rec-res.value))
      end
    | e-with(record, body) => 
      rec-res = interp(record, env, store)
      if C.is-v-rec(rec-res.value):
        with-interp(rec-res.value.fields, body, env, rec-res.store)
      else:
        raise(C.err-not-a-record(rec-res.value))
      end
      
    | e-set(name, val) =>
      val-res = interp(val, env, store)
      loc = get-binding(name, env)
      new-store = link(C.store-cell(loc, val-res.value), val-res.store)
      C.result(val-res.value, new-store)
      
    | e-do(stmts) => do-interp(stmts, env, store)
  end
end











fun with-interp(fields :: List<C.FieldVal>, body :: C.Expr, env :: C.Env, store :: C.Store) -> C.Result:
  cases (List<C.FieldVal>) fields:
    | empty => interp(body, env, store)
    | link(hd, tl) =>
      new-loc = gensym("loc")
      new-env = link(C.env-cell(hd.field-name, new-loc), env)
      new-store = link(C.store-cell(new-loc, hd.value), store)
      with-interp(tl, body, new-env, new-store)
  end
end



fun do-interp(stmts :: List<C.Expr>, env :: C.Env, store :: C.Store) -> C.Result:
  cases (List <C.Expr>) stmts:
    #| empty => parser should catch this
    | link(hd, tl) =>
      hd-res = interp(hd, env, store)
      if is-empty(tl):
        C.result(hd-res.value, hd-res.store)
      else:
        do-interp(tl, env, hd-res.store)
      end
  end
end




fun lookup-interp(fields :: List<C.FieldVal>, name :: String) -> C.Value:
  doc: "interpret lookup expressions"
  cases (List<C.FieldVal>) fields:
    | empty => raise(C.err-field-not-found(C.v-rec(fields), name))
    | link(hd, tl) => 
      if hd.field-name == name:
        hd.value
      else:
        lookup-interp(tl, name)
      end
  end
end



fun extend-interp(fields :: List<C.FieldVal>, new-value :: C.Value, name :: String) -> List<C.FieldVal>:
  doc: "either find and replace field in list of fields, or add new field"
  cases (List<C.FieldVal>) fields:
    | empty => link(C.v-field(name, new-value), empty)
    | link(hd, tl) => 
      if hd.field-name == name:
        link(C.v-field(name, new-value), tl)
      else:
        link(hd, extend-interp(tl, new-value, name))
      end
  end
end















fun rec-interp(fields :: List<C.FieldExpr>, env :: C.Env, store :: C.Store, acc-recval :: List<C.FieldVal>) -> C.Result:
  cases (List<C.FieldExpr>) fields:
    | empty => C.result(C.v-rec(acc-recval), store)
    | link(hd, tl) =>
      field-res = interp(hd.value, env, store)
      new-acc = link(C.v-field(hd.field-name, field-res.value), acc-recval)
      rec-interp(tl, env, field-res.store, new-acc)
  end
end





fun app-interp(f-val :: C.Value, arglist :: List<C.Expr>, env :: C.Env, store :: C.Store) -> C.Result:
  cases (List<C.Expr>) arglist:
    | empty => interp(f-val.body, f-val.env, store)
    | link(harg, targ) => 
      new-loc = gensym("loc")
      arg-res = interp(harg, env, store)
      cases (List<String>) f-val.params:
        #| empty => should never go here because of outside check for arity mismatch
        | link(hpar, tpar) => new-fun = C.v-fun(tpar, f-val.body, link(C.env-cell(hpar, new-loc), f-val.env))
          new-store = link(C.store-cell(new-loc, arg-res.value), arg-res.store)
          app-interp(new-fun, targ, env, new-store)
      end
  end
end




fun get-binding(name :: String, env :: C.Env) -> String:
  doc: "find the location associated with the given identifier"
  cases (C.Env) env:
    | empty => raise(C.err-unbound-id(name))
    | link(hd, tl) => 
      if hd.name == name:
        hd.loc
      else:
        get-binding(name, tl)
      end
  end
end



fun get-store(loc :: String, store :: C.Store) -> C.Value:
  doc: "find the value at a location in the store"
  cases (C.Store) store:
    #| empty => should never get here becaue unbound-id would be raised first
    | link(hd, tl) =>
      if hd.loc == loc:
        hd.val
      else:
        get-store(loc, tl)
      end
  end
end



fun binop-interp (op :: C.Operator, l :: C.Expr, r :: C.Expr, env :: C.Env, sto :: C.Store) -> C.Result:
  doc: "interpret an expression corresponding to a binary operator applied to two arguments"
  l-v = interp(l, env, sto)
  r-v = interp(r, env, l-v.store)
  cases (C.Operator) op:
    | op-plus => 
      if C.is-v-num(l-v.value):
        if C.is-v-num(r-v.value):
          C.result(C.v-num(l-v.value.value + r-v.value.value), r-v.store)
        else:
          raise(C.err-bad-arg-to-op(op, r-v.value))
        end
      else:
        raise(C.err-bad-arg-to-op(op, l-v.value))
      end
    | op-append =>
      if C.is-v-str(l-v.value):
        if C.is-v-str(r-v.value):
          C.result(C.v-str(l-v.value.value + r-v.value.value), r-v.store)
        else:
          raise(C.err-bad-arg-to-op(op, r-v.value))
        end
      else:
        raise(C.err-bad-arg-to-op(op, l-v.value))
      end
    | op-num-eq =>
      if C.is-v-num(l-v.value):
        if C.is-v-num(r-v.value):
          C.result(C.v-bool(l-v.value.value == r-v.value.value), r-v.store)
        else:
          raise(C.err-bad-arg-to-op(op, r-v.value))
        end
      else:
        raise(C.err-bad-arg-to-op(op, l-v.value))
      end
    | op-str-eq =>
      if C.is-v-str(l-v.value):
        if C.is-v-str(r-v.value):
          C.result(C.v-bool(l-v.value.value == r-v.value.value), r-v.store)
        else:
          raise(C.err-bad-arg-to-op(op, r-v.value))
        end
      else:
        raise(C.err-bad-arg-to-op(op, l-v.value))
      end
  end
end

fun if-interp (cond :: C.Expr, cons :: C.Expr, alt :: C.Expr, env :: C.Env, sto :: C.Store) -> C.Result:
  doc: "intepret if expressions"
  cond-res = interp(cond, env, sto)
  cases (C.Value) cond-res.value:
    | v-bool(b) => 
      if b:
        interp(cons, env, cond-res.store)
      else:
        interp(alt, env, cond-res.store)
      end
    | else => raise(C.err-if-got-non-boolean(cond-res.value))
  end
end