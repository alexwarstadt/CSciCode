provide {parse-n-calc: parse-n-calc} end

import sets as S
import shared-gdrive("calc-locals-untyped-definitions.arr", "0By8FB99CQCH9WEVMSDRFU1lpVFE") as C

fun parse-n-calc(prog :: String) -> Set<String>:
  doc: "Parse a program with a hole, and find the identifiers in scope there."
  calc-locals(C.parse(prog), [set:])
end






fun calc-locals(expr :: C.Expr, bound :: Set<String>) -> Set<String>:
  doc: "Find all of the identifiers in scope at a hole."
  cases (C.Expr) expr:
    | e-num(_) => [set:]
    | e-bool(_) => [set:]
      
    | e-op(_, left, right) => calc-locals(left, bound).union(calc-locals(right, bound))
      
    | e-if(cond, consq, altern) => calc-locals(cond, bound).union(calc-locals(consq, bound)).union(calc-locals(altern, bound))
      
    | e-lam(param, body) => calc-locals(body, bound.add(param))
   
    | e-app(func, arg) => calc-locals(func, bound).union(calc-locals(arg, bound))
      
    | e-id(_) => [set:]
      
    | e-rec(fields) => fields.map(lam(x): calc-locals(x.value, bound) end).foldl(lam(x, y): x.union(y) end, bound)
      
    | e-lookup(record, _) => calc-locals(record, bound)
      
    | e-extend(record, _, new-value) => calc-locals(record, bound).union(calc-locals(new-value, bound))
      
    | e-with(record, body) =>
        new-bound = record.fields.foldl(lam(x, y): y.add(x.field-name) end, bound)
        calc-locals(record, bound).union(calc-locals(body, new-bound))

    | e-let(name, ex, body) => calc-locals(ex, bound).union(calc-locals(body, bound.add(name)))
      
    | e-hole => bound
  end
end
