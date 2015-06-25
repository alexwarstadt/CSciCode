provide *

import shared-gdrive("interp-basic-definitions.arr", "0BwTSVb9gEh9-eGdGcFRPUDJJeVU") as C

is-desugared = C.is-desugared

fun eval(str :: String) -> C.Value:
  doc: "Parse, desugar, and interpret a Paret program."
  interp(desugar(C.parse(str)))
end

fun desugar(expr :: C.Expr) -> C.Expr%(is-desugared):
  doc: "desugar 'sugar-and' and 'sugar-or' in an expression."
  cases (C.Expr) expr:
    | e-num(_) => expr
    | e-str(_) => expr
    | e-bool(_) => expr
    | e-op(op, l, r) => C.e-op(op, desugar(l), desugar(r))
    | e-if(cond, cons, alt) => C.e-if(desugar(cond), desugar(cons), desugar(alt))
    | sugar-and(l, r) => C.e-if(desugar(l), C.e-if(desugar(r), C.e-bool(true), C.e-bool(false)), C.e-bool(false))
    | sugar-or(l, r) => C.e-if(desugar(l), C.e-bool(true), C.e-if(desugar(r), C.e-bool(true), C.e-bool(false)))
  end
where:
  desugar(C.e-num(1)) is C.e-num(1)
  desugar(C.e-str("a")) is C.e-str("a")
  desugar(C.e-bool(true)) is C.e-bool(true)
  desugar(C.e-op(C.op-plus, C.e-num(1), C.e-num(0))) is C.e-op(C.op-plus, C.e-num(1), C.e-num(0))
  desugar(C.e-if(C.e-bool(true), C.e-num(1), C.e-str("a"))) is C.e-if(C.e-bool(true), C.e-num(1), C.e-str("a"))
  desugar(C.sugar-and(C.e-bool(true), C.e-bool(false))) is C.e-if(C.e-bool(true), (C.e-if(C.e-bool(false), C.e-bool(true), C.e-bool(false))), C.e-bool(false))
  desugar(C.e-op(C.op-plus, (C.e-op(C.op-plus, C.e-num(1), C.e-num(2))), (C.e-op(C.op-plus, C.e-num(3), C.e-num(4))))) is (C.e-op(C.op-plus, (C.e-op(C.op-plus, C.e-num(1), C.e-num(2))), (C.e-op(C.op-plus, C.e-num(3), C.e-num(4)))))
end

fun binop-interp (op :: C.Operator, l :: C.Expr, r :: C.Expr) -> C.Value:
  doc: "interpret an expression corresponding to a binary operator applied to two arguments"
  l-v = interp(l)
  r-v = interp(r)
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

fun if-interp (cond :: C.Expr, cons :: C.Expr, alt :: C.Expr) -> C.Value:
  doc: "intepret if expressions"
  cond-v = interp(cond)
  cases (C.Value) cond-v:
    | v-bool(b) => 
      if b:
        interp(cons)
      else:
        interp(alt)
      end
    | else => raise(C.err-if-got-non-boolean(cond-v))
  end
end

fun interp(expr :: C.Expr%(is-desugared)) -> C.Value:
  doc: "Compute the result of evaluating the given expression."
  cases (C.Expr) expr:
    | e-num(v) => C.v-num(v)
    | e-str(v) => C.v-str(v)
    | e-bool(v) => C.v-bool(v)
    | e-op(op, l, r) => binop-interp(op, l, r)
    | e-if(cond, cons, alt) => if-interp(cond, cons, alt)
  end
end
  

