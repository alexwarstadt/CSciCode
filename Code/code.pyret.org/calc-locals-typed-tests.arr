import sets as S
import shared-gdrive("calc-locals-typed-definitions.arr", "0By8FB99CQCH9QVN3blAxekFBT1U") as C
import parse-n-calc from my-gdrive("calc-locals-typed-code.arr")

is-err-with-not-a-record = C.is-err-with-not-a-record

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
  parse-n-calc("((lam (x : Num) 1) @)") is [set:]
  parse-n-calc("(record (a @))") is [set:]
  parse-n-calc("(record (a 1) (b @))") is [set:]
  parse-n-calc("(lookup (record (a @)) a)") is [set:]
  parse-n-calc("(lookup (record (a 1) (b @)) a)") is [set:]
  parse-n-calc("(extend (record (a @)) b true)") is [set:]
  parse-n-calc("(extend (record (a 1) (b @)) b 2)") is [set:]
  parse-n-calc("(extend (record (a 1) (b true)) b @)") is [set:]
  parse-n-calc("(with (record (a 1) (b @)) (Record (a Num) (b Bool)) 3)") is [set:]
  parse-n-calc("(with 1 Num 3)") raises-satisfies is-err-with-not-a-record
end

check "let bindings":
  parse-n-calc("(let ((x 1)) @)") is [set: "x"]
  parse-n-calc("(let ((x 1)) (+ 1 @))") is [set: "x"]
  parse-n-calc("(let ((x 1)) (if true 2 @))") is [set: "x"]
  parse-n-calc("(let ((x 1)) (if @ 1 2))") is [set: "x"]
  parse-n-calc("(let ((x 1)) (if true @ @))") is [set: "x"]
  parse-n-calc("(let ((x 1)) (if true @ @))") is [set: "x"]
  parse-n-calc("(let ((x 1)) ((lam (x : Num) 1) @))") is [set: "x"] 
  parse-n-calc("(let ((x 1)) ((lam (y : Num) 1) @))") is [set: "x"] 
  parse-n-calc("(let ((x 1)) (record (a @)))") is [set: "x"]
  parse-n-calc("(let ((x 1)) (record (a 1) (b @)))") is [set: "x"]
  parse-n-calc("(let ((x 1)) (lookup (record (a @)) a))") is [set: "x"]
  parse-n-calc("(let ((x 1)) (lookup (record (a 1) (b @)) a))") is [set: "x"]
  parse-n-calc("(let ((x 1)) (extend (record (a @)) b true))") is [set: "x"]
  parse-n-calc("(let ((x 1)) (extend (record (a 1) (b @)) b 2))") is [set: "x"]
  parse-n-calc("(let ((x 1)) (extend (record (a 1) (b true)) b @))") is [set: "x"]
  parse-n-calc("(let ((x 1)) (with (record (a 1) (b @)) (Record (a Num) (b Bool)) 3))") is [set: "x"]
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
  parse-n-calc("(with (record (a (+ 1 2)) (b 3)) (Record (a Num) (b Num)) (+ a @))") is [set: "a", "b"]
  parse-n-calc("(with (record (a (+ 1 2)) (b 3) (c true)) (Record (a Num) (b Num) (c Bool)) (+ a @))") is [set: "a", "b", "c"]
  parse-n-calc("(with (record (a (+ 1 2)) (b 3) (c @)) (Record (a Num) (b Num) (c Bool)) (+ a 1))") is [set:]
  parse-n-calc("(+ (with (record (a (+ 1 2)) (b 3) (c true)) (Record (a Num) (b Num) (c Bool)) (+ a b)) @)") is [set:]
  parse-n-calc("(with (record (a (+ 1 2)) (b 3) (c true)) (Record (a Num) (b Num) (c Bool)) (with (record (e false) (d 1)) (Record (e Bool) (d Num)) (if d (if c (+ 1 2) @) 3)))") is [set: "a", "b", "c", "d", "e"]
  parse-n-calc("(with (record (a 1)) (Record (a Num)) (with (record (e false)) (Record (e Bool)) @))") is [set: "a", "e"]
  parse-n-calc("(with (record (a 1)) (Record (a Num)) (with (record (a false)) (Record (a Bool)) @))") is [set: "a"]
  parse-n-calc("(with (record (a 1)) (Record (a Num)) (with (record (e @)) (Record (e Bool)) 2))") is [set: "a"]
  parse-n-calc("(with (record (a 1)) (Record (a Num)) (with 1 Num @))") raises-satisfies(is-err-with-not-a-record)
end

check "lambda bindings":
  parse-n-calc("(lam (x : Num) (+ x @))") is [set: "x"]
  parse-n-calc("(lam (x : Num) (lam (y : Bool) @))") is [set: "x", "y"]
  parse-n-calc("(lam (x : Num) ((lam (y : Bool) 1) @))") is [set: "x"]
  parse-n-calc("((lam (x : Num) ((lam (y : Bool) 1) true)) @)") is [set:]
end

check "complicated bindings":
  parse-n-calc("(lam (x : Num) (let ((a 2)) (+ x @)))") is [set: "x", "a"]
  parse-n-calc("(let ((a (lam (x : Num) 1))) (a @))") is [set: "a"]
  parse-n-calc("(let ((a (lam (x : Num) @))) (a 2))") is [set: "x"]
  parse-n-calc("(let ((a (lam (a : Num) 1))) (a @))") is [set: "a"]
  parse-n-calc("(let ((a 1)) (let ((b (lam (x : Num) (+ a x)))) (let ((a 3)) (b @))))") is [set: "a", "b"]
  parse-n-calc("(let ((a (with (record (b true) (c 1)) (Record (b Bool) (c Num)) (lam (x : Num) @)))) 2)") is [set: "b", "c", "x"]
  parse-n-calc("(let ((x (record (a (record (b 1)))))) (with x (Record (a (Record (b Num)))) (with a (Record (b Num)) @)))") is [set: "b", "a", "x"]
end

check "bound records":
  parse-n-calc("(let ((b (record (a 1) (b true)))) (with b (Record (a Num) (b Bool)) @))") is [set: "a", "b"]
  parse-n-calc("(let ((c (record (a 1) (b true)))) (with b (Record (a Num) (b Bool)) @))") is [set: "a", "b", "c"]
  parse-n-calc("(let ((c (record (a 1) (b true)))) (with b (Record (a Num) (b Bool)) (with (extend c c 2) (Record (a Num) (b Bool) (c Num)) @)))") is [set: "a", "b", "c"]
  parse-n-calc("(let ((b (record (a 1) (b true)))) (with (extend b c 2) (Record (a Num) (b Bool) (c Num)) @))") is [set: "a", "b", "c"]
  parse-n-calc("(lam (x : (Record (a Num) (b Bool))) (with x (Record (a Num) (b Bool)) @))") is [set: "a", "b", "x"]
  parse-n-calc("(lam (x : (Record (a Num) (b Bool))) (extend x c @))") is [set: "x"]
  parse-n-calc("(lam (x : (Record (a Num) (b Bool))) (+ (lookup x a) @))") is [set: "x"]
  parse-n-calc("((lam (x : (Record (a Num) (b Bool))) (+ (lookup x a) 2)) (record (a 1) (b @)))") is [set:]
  parse-n-calc("(let ((a (record (x 1) (b 2)))) (with a (Record (x Num) (b Num)) @))") is [set: "x", "b", "a"]
  parse-n-calc("(let ((a (record (x 1) (b 2)))) (let ((y (record (c true)))) (with a (Record (x Num) (b Num)) @)))") is [set: "x", "b", "a", "y"]
  parse-n-calc("(let ((a (record (x 1) (b 2)))) (let ((y (record (c true)))) (with y (Record (c Bool)) @)))") is [set: "a", "y", "c"]
  parse-n-calc("(lam (x : (Record (a (Record (b Num))))) (with x (Record (a (Record (b Num)))) (with a (Record (b Num)) @)))") is [set: "b", "a", "x"]
  parse-n-calc("(lam (x : (Record (x (Record (b Num))))) (with x (Record (x (Record (b Num)))) (with x (Record (b Num)) @)))") is [set: "b", "x"]
  parse-n-calc("(let ((a (record (x 1) (b 2)))) (let ((y 1)) (with y Num @)))") raises-satisfies(is-err-with-not-a-record)
  parse-n-calc("(lam (x : (Record (a Num) (b Bool))) (lam (x : Num) (with x Num @)))") raises-satisfies(is-err-with-not-a-record)
end










