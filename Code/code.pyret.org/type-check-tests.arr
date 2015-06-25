import shared-gdrive("type-checker-definitions.arr", "0By8FB99CQCH9dWV4R0RoRHVLTk0") as C

import type-check from my-gdrive("type-checker-code.arr")

check "simple":
  type-check("true") is C.t-bool
  type-check("1") is C.t-num
  type-check("(empty : Num)") is C.t-list(C.t-num)
  type-check("(link true (empty : Bool))") is C.t-list(C.t-bool)
  type-check("(lam (x : Bool) (if x 1 0))") is C.t-fun(C.t-bool, C.t-num)
  type-check("(lam (x : Bool) (if x true false))") is C.t-fun(C.t-bool, C.t-bool)
  type-check("((lam (x : Bool) (if x 1 0)) true)") is C.t-num
  type-check("(+ 1 2)") is C.t-num
  type-check("(num= 1 2)") is C.t-bool
  type-check("(first (link true (empty : Bool)))") is C.t-bool
  type-check("(rest (link true (empty : Bool)))") is C.t-list(C.t-bool)
  type-check("(let ((x 1)) x)") is C.t-num
   type-check("(first (empty : Num))") is C.t-num
  type-check("(rest (empty : Num))") is C.t-list(C.t-num)
end

check "nesting, etc":
  type-check("(+ (+ 2 3) (+ 1 2))") is C.t-num
  type-check("(link (empty : Num) (empty : (List Num)))") is C.t-list(C.t-list(C.t-num))
  type-check("(link 1 (link 2 (link 3 (empty : Num))))") is C.t-list(C.t-num)
  type-check("(if (if true false true) (+ 1 1) (+ 2 2))") is C.t-num
  type-check("(link (+ 1 2) (empty : Num))") is C.t-list(C.t-num)
  type-check("(is-empty (link (+ 1 2) (empty : Num)))") is C.t-bool
  type-check("((lam (x : (Num -> Bool)) (x 1)) (lam (x : Num) (num= 3 x)))") is C.t-bool
  type-check("(let ((a (link 1 (empty : Num)))) (first a))") is C.t-num
  type-check("(let ((a (link 1 (empty : Num)))) (rest a))") is C.t-list(C.t-num)
  type-check("(let ((a (link 1 (empty : Num)))) (is-empty a))") is C.t-bool
  type-check("(if true ((lam (x : Num) (+ x 1)) 2) 4)") is C.t-num
  
  
  type-check("((lam (x : (List Num)) (rest x)) (empty : Num))") is C.t-list(C.t-num)
  
  type-check("((lam (x : (List (List Num))) (rest x)) (empty : (List Num)))") is C.t-list(C.t-list(C.t-num))
  type-check("((lam (x : (Bool -> Num)) (x true)) (lam (x : Bool) 1))") is C.t-num
  type-check("(lam (x : (Bool -> Num)) 1)") is C.t-fun(C.t-fun(C.t-bool, C.t-num), C.t-num)
end

check "static scope":
  type-check("(let ((a 1)) ((lam (x : Num) (+ x a)) (let ((a true)) 3)))") is C.t-num
  type-check("(let ((a 1)) (let ((b (lam (x : Num) (+ x a)))) (let ((a false)) (b 6))))") is C.t-num
  type-check("(let ((a true)) (let ((b (lam (x : Num) (+ x a)))) (let ((a 1)) (b 6))))") raises-satisfies C.is-tc-err-bad-arg-to-op
  type-check("(let ((a 1)) (let ((b (lam (x : Num) (if a x 0)))) (let ((a true)) (b 6))))") raises-satisfies C.is-tc-err-if-got-non-boolean
end

check "error: if got non bool":
  type-check("(if 1 2 3)") raises-satisfies C.is-tc-err-if-got-non-boolean
  type-check("(if (+ 1 2) 2 3)") raises-satisfies C.is-tc-err-if-got-non-boolean
  type-check("(let ((a (if 1 2 3))) a)") raises-satisfies C.is-tc-err-if-got-non-boolean
end
  
check "error: bad arg to op":
  type-check("(+ true false)") raises-satisfies C.is-tc-err-bad-arg-to-op
  type-check("(+ 1 (empty : Num))") raises-satisfies C.is-tc-err-bad-arg-to-op
  type-check("(num= true false)") raises-satisfies C.is-tc-err-bad-arg-to-op
  type-check("(link true false)") raises-satisfies C.is-tc-err-bad-arg-to-op
  type-check("(link 1 (empty : Bool))") raises-satisfies C.is-tc-err-bad-arg-to-op
  type-check("(is-empty false)") raises-satisfies C.is-tc-err-bad-arg-to-op
  type-check("(first 1)") raises-satisfies C.is-tc-err-bad-arg-to-op
  type-check("(rest true)") raises-satisfies C.is-tc-err-bad-arg-to-op
  type-check("(lam (x : Bool) (+ x 1))") raises-satisfies C.is-tc-err-bad-arg-to-op
  type-check("(lam (x : Num) (link (empty : Num) x))") raises-satisfies C.is-tc-err-bad-arg-to-op
end

check "error: ID":
  type-check("(+ 1 a)") raises-satisfies C.is-tc-err-unbound-id
  type-check("(link a (empty : Num))") raises-satisfies C.is-tc-err-unbound-id
  type-check("(lam (a : Num) (+ a b))") raises-satisfies C.is-tc-err-unbound-id
  type-check("(+ 1 a)") raises-satisfies C.is-tc-err-unbound-id
  type-check("(link 3 (link (+ a 1) (empty : Num)))") raises-satisfies C.is-tc-err-unbound-id
end

check "error: not function":
  type-check("(1 2)") raises-satisfies C.is-tc-err-not-a-function
  type-check("(let ((a 1)) (+ (let ((a (lam (x : Num) (+ x 1)))) 2) (a 1)))") raises-satisfies C.is-tc-err-not-a-function
  type-check("(lam (x : Num) (x 1))") raises-satisfies C.is-tc-err-not-a-function
end

check "error: if branches":
  type-check("(if true 1 true)") raises-satisfies C.is-tc-err-if-branches
  type-check("(if false 1 true)") raises-satisfies C.is-tc-err-if-branches
  type-check("(if true (lam (x : Num) (+ x 1)) (lam (x : Num) (num= x 1)))") raises-satisfies C.is-tc-err-if-branches
  type-check("(if false (empty : Num) (empty : Bool))") raises-satisfies C.is-tc-err-if-branches
  type-check("(if false (link 1 (empty : Num)) (link true (empty : Bool)))") raises-satisfies C.is-tc-err-if-branches
  type-check("(if true ((lam (x : Num) (+ x 1)) 2) (lam (x : Num) (num= x 1)))") raises-satisfies C.is-tc-err-if-branches
  type-check("(if 1 1 true)") raises-satisfies C.is-tc-err-if-got-non-boolean
end

check "error: bad arg to fun":
  type-check("((lam (x : Num) (+ x 1)) true)") raises-satisfies C.is-tc-err-bad-arg-to-fun
  type-check("((lam (x : Bool) 1) 1)") raises-satisfies C.is-tc-err-bad-arg-to-fun
  type-check("((lam (x : (List Num)) (rest x)) (empty : Bool))") raises-satisfies C.is-tc-err-bad-arg-to-fun
  type-check("((lam (x : (List Num)) (rest x)) (empty : (List Num)))") raises-satisfies C.is-tc-err-bad-arg-to-fun
  type-check("((lam (x : (Bool -> Num)) (x true)) (lam (x : Bool) x))") raises-satisfies C.is-tc-err-bad-arg-to-fun
end

check "error: checks left to right":
  type-check("(if 1 (+ 1 true) 2)") raises-satisfies C.is-tc-err-if-got-non-boolean
  type-check("(if true (+ 1 true) x)") raises-satisfies C.is-tc-err-bad-arg-to-op
  type-check("(+ (if true true 1) 2)") raises-satisfies C.is-tc-err-if-branches
  type-check("(link y 2)") raises-satisfies C.is-tc-err-unbound-id
  type-check("(+ ((lam (x : Num) (+ x 1)) true) y)") raises-satisfies C.is-tc-err-bad-arg-to-fun
end
