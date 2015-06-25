provide {parse-n-calc: parse-n-calc} end

import sets as S
import shared-gdrive("calc-locals-untyped-definitions.arr", "0By8FB99CQCH9WEVMSDRFU1lpVFE") as C

fun parse-n-calc(prog :: String) -> Set<String>:
  doc: "Parse a program with a hole, and find the identifiers in scope there."
  calc-locals(C.parse(prog), [set:])
end

fun calc-locals(expr :: C.Expr, bound :: Set<String>) -> Set<String>:
  doc: "Find all of the identifiers in scope at a hole."
  # Implement me!
  [set:]
end


fun help-calc(expr :: C.Expr, bound :: Set<String>, env :: C.Env) -> Set<String>:
  [set:]
end










