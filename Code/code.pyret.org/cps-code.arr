provide {
  eval: eval,
  eval-cps: eval-cps
} end

import shared-gdrive("cps-definitions.arr", "0BwTSVb9gEh9-cEZCNWtmT1FxeHM") as C

type CPSExpr = C.CPSExpr
cps-if = C.cps-if
cps-app-atomic = C.cps-app-atomic
cps-app-kont = C.cps-app-kont
cps-app-cps = C.cps-app-cps
cps-lam = C.cps-lam
cps-op = C.cps-op

type Expr = C.Expr
e-if = C.e-if
e-op = C.e-op
e-app = C.e-app
e-lam = C.e-lam
e-num = C.e-num
e-bool = C.e-bool
e-id = C.e-id

type Value = C.Value
v-num = C.v-num
v-bool = C.v-bool

type CPSAtomicExpr = C.CPSAtomicExpr
a-lam = C.a-lam
a-num = C.a-num
a-bool = C.a-bool
a-id = C.a-id

type Kont = C.Kont
k-lam = C.k-lam
k-id = C.k-id


fun eval(prog :: String) -> Value:
  C.interp(C.parse(prog))
end

fun eval-cps(prog :: String) -> Value:
  ast = to-expr(cps(C.parse(prog)))
  id-func = C.e-lam("result", C.e-id("result"))
  C.interp(C.e-app(ast, id-func))
end

fun eval-help(ast :: Expr) -> Value:
  id-func = C.e-lam("result", C.e-id("result"))
  C.interp(C.e-app(ast, id-func))
end

fun cps(e :: Expr) -> CPSExpr:
  cases(Expr) e:
    | e-op(op, left, right) =>
      cps-lam("k*",
        cps-app-cps(cps(left),
          k-lam("left*",
            cps-app-cps(cps(right),
              k-lam("right*",
                cps-op(op, a-id("left*"), a-id("right*"), k-id("k*")))))))
    | e-if(cond :: Expr, consq :: Expr, altern :: Expr) =>
      cps-lam("k*",
        cps-app-cps(cps(cond),
          k-lam("cond*", 
            cps-if(a-id("cond*"), 
              cps-app-cps(cps(consq), k-id("k*")),
              cps-app-cps(cps(altern), k-id("k*"))))))
    | e-let(name, expr, body) => cps(e-app(e-lam(name, body), expr))
    | e-lam(param, body) =>
      cps-lam("k*",
        cps-app-kont(k-id("k*"), 
          a-lam(param, "k*", 
            cps-app-cps(
              cps-lam("k-dyn*", 
                cps-app-cps(cps(body), k-id("k-dyn*"))), k-id("k*")))))
    | e-app(func, arg) =>
      cps-lam("k*", 
        cps-app-cps(cps(func), 
          k-lam("func*",
            cps-app-cps(cps(arg),
              k-lam("arg*",
                cps-app-atomic(a-id("func*"), a-id("arg*"), k-id("k*")))))))
    | e-id(name) =>
      cps-lam("k*", cps-app-kont(k-id("k*"), a-id(name)))
    | e-num(value) =>
      cps-lam("k*", cps-app-kont(k-id("k*"), a-num(value)))
    | e-bool(value) =>
      cps-lam("k*", cps-app-kont(k-id("k*"), a-bool(value)))
  end
end






fun to-expr(expr :: CPSExpr) -> Expr:
  cases (CPSExpr) expr:
    | cps-if(cond, consq, altern) => e-if(atomic(cond), to-expr(consq), to-expr(altern))
    | cps-app-atomic(func, arg, k) => e-app(e-app(atomic(func), atomic(arg)), kont(k))
    | cps-app-kont(k, value) => e-app(kont(k), atomic(value))
    | cps-app-cps(func, k) => e-app(to-expr(func), kont(k))
    | cps-lam(k-name, ex) => e-lam(k-name, to-expr(ex))
    | cps-op(op, left, right, k) => e-app(kont(k), e-op(op, atomic(left), atomic(right)))
  end
end


fun atomic(expr :: CPSAtomicExpr) -> Expr:
  cases (CPSAtomicExpr) expr:
    | a-lam(v-name, k-name, body) => e-lam(v-name, (e-lam(k-name, to-expr(body))))
    | a-num(value) => e-num(value)
    | a-bool(value) => e-bool(value)
    | a-id(v-name) => e-id(v-name)
  end
end

fun kont(k :: Kont) -> Expr:
  cases (Kont) k:
    | k-lam(v-name, expr) => e-lam(v-name, to-expr(expr))
    | k-id(k-name) => e-id(k-name) 
  end
end








