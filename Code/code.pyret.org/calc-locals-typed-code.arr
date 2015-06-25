provide {parse-n-calc: parse-n-calc} end

import sets as S
import shared-gdrive("calc-locals-typed-definitions.arr", "0By8FB99CQCH9QVN3blAxekFBT1U") as C

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
      
    | e-lam(param, arg-type, body) => calc-locals(body, bound.add(param))
   
    | e-app(func, arg) => calc-locals(func, bound).union(calc-locals(arg, bound))
      
    | e-id(_) => [set:]
      
    | e-rec(fields) => fields.map(lam(x): calc-locals(x.value, bound) end).foldl(lam(x, y): x.union(y) end, bound)
      
    | e-lookup(rec, _) => calc-locals(rec, bound)
      
    | e-extend(rec, _, new-value) => calc-locals(rec, bound).union(calc-locals(new-value, bound))
      
    | e-with(rec, rec-type, body) =>
      if C.is-t-rec(rec-type):
        new-bound = rec-type.field-types.foldl(lam(x, y): y.add(x.field-name) end, bound)
        calc-locals(rec, bound).union(calc-locals(body, new-bound))
      else:
        raise(C.err-with-not-a-record(rec-type))
      end

    | e-let(name, ex, body) => calc-locals(ex, bound).union(calc-locals(body, bound.add(name)))
      
    | e-hole => bound
  end
end

