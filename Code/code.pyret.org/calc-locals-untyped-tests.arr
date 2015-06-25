import sets as S
import shared-gdrive("calc-locals-untyped-definitions.arr", "0By8FB99CQCH9WEVMSDRFU1lpVFE") as C
import parse-n-calc from my-gdrive("calc-locals-untyped-code.arr")

# Some testing advice: split your tests into multiple named check blocks.
# This helps with organization, and also if one block errors out, the others
# will still run.


check "simple, no bindings":
  parse-n-calc("@") is [set:]
  parse-n-calc("(+ @ 2)") is [set:]
  parse-n-calc("(+ 2 @)") is [set:]
  parse-n-calc("(num= @ 2)") is [set:]
  parse-n-calc("(num= 2 @)") is [set:]
  parse-n-calc("(if @ 2 1)") is [set:]
  parse-n-calc("(if true @ 1)") is [set:]
  parse-n-calc("(if true 1 @)") is [set:]
  parse-n-calc("(let ((x @)) 2)") is [set:]
  parse-n-calc("((lam (x) 1) @)") is [set:]
  parse-n-calc("(record (a @))") is [set:]
  parse-n-calc("(record (a 1) (b @))") is [set:]
  parse-n-calc("(lookup (record (a @)) a)") is [set:]
  parse-n-calc("(lookup (record (a 1) (b @)) a)") is [set:]
  parse-n-calc("(extend (record (a @)) b true)") is [set:]
  parse-n-calc("(extend (record (a 1) (b @)) b 2)") is [set:]
  parse-n-calc("(extend (record (a 1) (b true)) b @)") is [set:]
  parse-n-calc("(with (record (a 1) (b @)) 3)") is [set:]
end

check "let bindings":
  parse-n-calc("(let ((x 1)) @)") is [set: "x"]
  parse-n-calc("(let ((x 1)) (+ 1 @))") is [set: "x"]
  parse-n-calc("(let ((x 1)) (if true 2 @))") is [set: "x"]
  parse-n-calc("(let ((x 1)) (if @ 1 2))") is [set: "x"]
  parse-n-calc("(let ((x 1)) (if true @ @))") is [set: "x"]
  parse-n-calc("(let ((x 1)) (if true @ @))") is [set: "x"]
  parse-n-calc("(let ((x 1)) ((lam (x) 1) @))") is [set: "x"] 
  parse-n-calc("(let ((x 1)) ((lam (y) 1) @))") is [set: "x"] 
  parse-n-calc("(let ((x 1)) (record (a @)))") is [set: "x"]
  parse-n-calc("(let ((x 1)) (record (a 1) (b @)))") is [set: "x"]
  parse-n-calc("(let ((x 1)) (lookup (record (a @)) a))") is [set: "x"]
  parse-n-calc("(let ((x 1)) (lookup (record (a 1) (b @)) a))") is [set: "x"]
  parse-n-calc("(let ((x 1)) (extend (record (a @)) b true))") is [set: "x"]
  parse-n-calc("(let ((x 1)) (extend (record (a 1) (b @)) b 2))") is [set: "x"]
  parse-n-calc("(let ((x 1)) (extend (record (a 1) (b true)) b @))") is [set: "x"]
  parse-n-calc("(let ((x 1)) (with (record (a 1) (b @)) 3))") is [set: "x"]
end

check "nested let":
  parse-n-calc("(let ((x 1)) (let ((y 2)) @))") is [set: "x", "y"]
  parse-n-calc("(let ((x 1)) (let ((y @)) 2))") is [set: "x"]
  parse-n-calc("(let ((x 1)) (+ (let ((y 2)) 1) @))") is [set: "x"]
  parse-n-calc("(let ((x 1)) (let ((y 2)) (let ((x 3)) @)))") is [set: "x", "y"]
  parse-n-calc("(let ((x 1)) (let ((y (+ 1 1))) (let ((z 3)) @)))") is [set: "x", "y", "z"]
  parse-n-calc("(let ((x 1)) (let ((y 2)) (let ((z 3)) (+ 1 @))))") is [set: "x", "y", "z"]
end

check "with bindings":
  parse-n-calc("(with (record (a (+ 1 2)) (b 3)) (+ a @))") is [set: "a", "b"]
  parse-n-calc("(with (record (a (+ 1 2)) (b 3) (c true)) (+ a @))") is [set: "a", "b", "c"]
  parse-n-calc("(with (record (a (+ 1 2)) (b 3) (c @)) (+ a 1))") is [set:]
  parse-n-calc("(+ (with (record (a (+ 1 2)) (b 3) (c true)) (+ a b)) @)") is [set:]
  parse-n-calc("(with (record (a (+ 1 2)) (b 3) (c true)) (with (record (e false) (d 1)) (if d (if c (+ 1 2) @) 3)))") is [set: "a", "b", "c", "d", "e"]
  parse-n-calc("(with (record (a 1)) (with (record (e false)) @))") is [set: "a", "e"]
  parse-n-calc("(with (record (a 1)) (with (record (a false)) @))") is [set: "a"]
  parse-n-calc("(with (record (a 1)) (with (record (e @)) 2))") is [set: "a"]
end

check "lambda bindings":
  parse-n-calc("(lam (x) (+ x @))") is [set: "x"]
  parse-n-calc("(lam (x) (lam (y) @))") is [set: "x", "y"]
  parse-n-calc("(lam (x) ((lam (y) 1) @))") is [set: "x"]
  parse-n-calc("((lam (x) ((lam (y) 1) true)) @)") is [set:]
end

check "complicated bindings":
  parse-n-calc("(lam (x) (let ((a 2)) (+ x @)))") is [set: "x", "a"]
  parse-n-calc("(let ((a (lam (x) 1))) (a @))") is [set: "a"]
  parse-n-calc("(let ((a (lam (x) @))) (a 2))") is [set: "x"]
  parse-n-calc("(let ((a (lam (a) 1))) (a @))") is [set: "a"]
  parse-n-calc("(let ((a 1)) (let ((b (lam (x) (+ a x)))) (let ((a 3)) (b @))))") is [set: "a", "b"]
  parse-n-calc("(let ((a (with (record (b true) (c 1)) (lam (x) @)))) 2)") is [set: "b", "c", "x"]
end

check "bound records":
  parse-n-calc("(let ((b (record (a 1) (b true)))) (with b @))") is [set: "a", "b"]
  parse-n-calc("(let ((c (record (a 1) (b true)))) (with b @))") is [set: "a", "b", "c"]
  parse-n-calc("(let ((c (record (a 1) (b true)))) (with b (with (extend c c 2) @)))") is [set: "a", "b", "c"]
  parse-n-calc("(let ((b (record (a 1) (b true)))) (with (extend b c 2) @))") is [set: "a", "b", "c"]
  parse-n-calc("(let ((a (record (x 1) (b 2)))) (with a @))") is [set: "x", "b", "a"]
  parse-n-calc("(let ((a (record (x 1) (b 2)))) (let ((y (record (c true)))) (with a @)))") is [set: "x", "b", "a", "y"]
  parse-n-calc("(let ((a (record (x 1) (b 2)))) (let ((y (record (c true)))) (with y @)))") is [set: "a", "y", "c"]
  parse-n-calc("(let ((x (record (a (record (b 1)))))) (with x (with a @)))") is [set: "b", "a", "x"]
  parse-n-calc("(let ((a (lam (x) (extend x b 1)))) (let ((c (a (record (d 1))))) (with c @)))") is [set: "a", "b", "c", "d"]
  parse-n-calc("(let ((a (record (b 1)))) (let ((c (lam (x) (extend a d x)))) (let ((a 1)) (with (c 2) @))))") is [set: "a", "b", "c", "d"]
end


