import shared-gdrive("interp-fun-definitions.arr", "0By8FB99CQCH9R1JuU09BQkUtZ2c") as C

import eval from my-gdrive("interp-fun-code.arr")





check "lambda":
  eval("(lam() 5)") satisfies C.is-v-fun
  eval("(lam(x) 5)") satisfies C.is-v-fun
  eval("(lam(x) (+ x 1))") satisfies C.is-v-fun
  eval("(lam(x y) (+ x y))") satisfies C.is-v-fun
  eval("(lam(x y z) (if x (+ y z) 10))") satisfies C.is-v-fun
  eval("(lam(x y z) 5)") satisfies C.is-v-fun
  
  #nested lambdas
  eval("(lam(x y) (lam(z) (+ (+ x y) z)))") satisfies C.is-v-fun
end







check "function application":
  eval("((lam() 5))") is C.v-num(5)
  eval("((lam() (+ 2 3)))") is C.v-num(5)
  eval("((lam(x) 5) (+ 1 2))") is C.v-num(5)
  
  
  eval("((lam(x) (+ x 1))4)") is C.v-num(5)
  eval("((lam(x y) (+ x y)) 2 3)") is C.v-num(5)
  eval("((lam(x y z) (if x (+ y z) 10)) true 2 3)") is C.v-num(5)
  eval("((lam(x y z) (if x (+ y z) 10)) false 2 3)") is C.v-num(10)
  eval("((lam(x y z) 5) true 1 \"a\")") is C.v-num(5)
  
  #nested f-apps
  eval("((lam(x y) ((lam(z) (+ (+ x y) z)) 1)) 2 2)") is C.v-num(5)
  
  #same id used
  eval("((lam (x y) ((lam (x) (+ x y)) (+ x y))) 17 18)") is C.v-num(53)
  eval("((lam (x y) ((lam (x) (+ x y)) y)) 17 18)") is C.v-num(36)
  
  #errors
  eval("((lam(x) 5) (+ true true))") raises-satisfies
  _ == C.err-bad-arg-to-op(C.op-plus, C.v-bool(true))
  eval("((lam() (+ x 1)))") raises-satisfies
  _ == C.err-unbound-id("x")
  eval("((lam() (+ x 1)) 1)") raises-satisfies
  _ == C.err-arity-mismatch(0, 1)
  eval("((lam(x y z) (+ x 1)) 1)") raises-satisfies
  _ == C.err-arity-mismatch(3, 1)
  eval("(1 2)") raises-satisfies _ == C.err-not-a-function(C.v-num(1))
  eval("((+ 1 2) 2)") raises-satisfies _ == C.err-not-a-function(C.v-num(3))
end








check "let":
  eval("(let ((x 1)) x)") is C.v-num(1)
  eval("(let ((x 1)) (+ x 2))") is C.v-num(3)
  eval("(let ((x (+ 1 2))) x)") is C.v-num(3)
  eval("(let ((x 1) (y 2)) (+ x y))") is C.v-num(3)
  eval("(let ((x 1) (y 2)) (+ x 3))") is C.v-num(4)
  eval("(let ((b 1)) (let ((a b)) a))") is C.v-num(1)
  
  #lambda bound inside let
  eval("(let ((x (lam(y) (+ 1 y)))) (x 2))") is C.v-num(3)
  eval("(let ((x (lam(y) (y 3)))) (x (lam(y) (+ y 1))))") is C.v-num(4)
  eval("(let ((a 100)) (let ((b 2)) (let ((f (lam (x) (let ((b a)) (+ a (+ b x)))))) (f 1))))") is C.v-num(201)
  eval("(let ((f (lam(a b c) (+ (+ a b) c)))) (f 1 2 3))") is C.v-num(6)
  
  #let inside lamda
  eval("(lam(x) (let ((y 1)) (+ x y)))") satisfies C.is-v-fun
  eval("((lam(x) (let ((y 1)) (+ x y))) 2)") is C.v-num(3)
  eval("((lam(x) (let ((x 1)) (+ x x))) 10)") is C.v-num(2)
  
  #lexical scope
  eval("(let ((a 0)) (let ((f (lam (x) (+ x a)))) (let ((a 1)) (let ((a 2)) (f 0)))))") is C.v-num(0)
  eval("(let ((f (lam (x) (+ x y)))) (let ((y 0)) (f 1)))") raises-satisfies _ == C.err-unbound-id("y")
  
  #errors
  eval("(let ((a 1)) (+ a b))") raises-satisfies _ == C.err-unbound-id("b")
  eval("(let ((a 1)) (+ (let ((b 1)) a) b))") raises-satisfies _ == C.err-unbound-id("b")
  eval("(let ((f (lam(a b c) (+ (+ a b) c)))) (f 1))") raises-satisfies _ == C.err-arity-mismatch(3, 1)
  eval("(let ((a (+ true true))) a)") raises-satisfies _ == C.err-bad-arg-to-op(C.op-plus, C.v-bool(true))
  eval("(let ((a b)) a)") raises-satisfies _ == C.err-unbound-id("b")
end







check "short-circuiting":
  eval("(and false 1)") is C.v-bool(false)
  eval("(and (num= 1 0) 1)") is C.v-bool(false)
  eval("(or true 1)") is C.v-bool(true)
  eval("(or (num= 1 1) 1)") is C.v-bool(true)
  eval("(if true 1 (+ true false))") is C.v-num(1)
  eval("(if false (+ true false) 1)") is C.v-num(1)
  
  #and
  eval("(and true 1)") raises-satisfies
  _ == C.err-if-got-non-boolean(C.v-num(1))
  eval("(and 1 true)") raises-satisfies
  _ == C.err-if-got-non-boolean(C.v-num(1))
  eval("(and \"a\" true)") raises-satisfies
  _ == C.err-if-got-non-boolean(C.v-str("a"))
  eval("(and true \"a\")") raises-satisfies
  _ == C.err-if-got-non-boolean(C.v-str("a"))
  
  #or
  eval("(or false 1)") raises-satisfies
  _ == C.err-if-got-non-boolean(C.v-num(1))
  eval("(or 1 true)") raises-satisfies
  _ == C.err-if-got-non-boolean(C.v-num(1))
  eval("(or \"a\" true)") raises-satisfies
  _ == C.err-if-got-non-boolean(C.v-str("a"))
  eval("(or false \"a\")") raises-satisfies
  _ == C.err-if-got-non-boolean(C.v-str("a"))
end


















check "old tests from last hw":
  #interpretation is trivial
  eval("1") is C.v-num(1)
  eval("\"hello\"") is C.v-str("hello")
  eval("\"\"") is C.v-str("")
  eval("true") is C.v-bool(true)
  eval("false") is C.v-bool(false)
  
  #desugar simple and/or
  eval("(and true true)") is C.v-bool(true)
  eval("(and true false)") is C.v-bool(false)
  eval("(and false true)") is C.v-bool(false)
  eval("(and false false)") is C.v-bool(false)
  
  eval("(or true true)") is C.v-bool(true)
  eval("(or true false)") is C.v-bool(true)
  eval("(or false true)") is C.v-bool(true)
  eval("(or false false)") is C.v-bool(false)
  
  #nested boolean expressions under and/or
  eval("(and (and true true) false)") is C.v-bool(false) #and(and)
  eval("(and false (and true true))") is C.v-bool(false) #and(and)
  eval("(and (and true true) (and true true))") is C.v-bool(true) #and(and)
  eval("(and (or false true) true)") is C.v-bool(true) #and(or) left
  eval("(and false (or true true))") is C.v-bool(false) #and(or) right
  eval("(and (or true true) (or true true))") is C.v-bool(true) #and(or)both args

  eval("(or (and true true) false)") is C.v-bool(true) #or(and)
  eval("(or false (and true true))") is C.v-bool(true) #or(and)
  eval("(or (and true true) (and true true))") is C.v-bool(true) #or(and)
  eval("(or (or false true) true)") is C.v-bool(true) #or(or) left
  eval("(or false (or false false))") is C.v-bool(false) #or(or) right
  eval("(or (or true true) (or true true))") is C.v-bool(true) #or(or)both args
  
  eval("(and (num= 1 1) true)") is C.v-bool(true) #and(num=) left
  eval("(and false (num= 1 0))") is C.v-bool(false) #and(num=) right
  eval("(or (num= 1 1) true)") is C.v-bool(true) #or(num=) left
  eval("(or false (num= 1 0))") is C.v-bool(false) #or(num=) right
  
  eval("(and (str= \"a\" \"b\") true)") is C.v-bool(false) #and(num=) left
  eval("(and false (str= \"a\" \"b\"))") is C.v-bool(false) #and(num=) right
  eval("(or (str= \"a\" \"a\") true)") is C.v-bool(true) #or(num=) left
  eval("(or false (str= \"a\" \"b\"))") is C.v-bool(false) #or(num=) right
  
  #and/or short circuit
  eval("(and false 1)") is C.v-bool(false)
  eval("(and (num= 1 0) 1)") is C.v-bool(false)
  eval("(or true 1)") is C.v-bool(true)
  eval("(or (num= 1 1) 1)") is C.v-bool(true)
  
  #str=
  eval("(str= \"a\" \"b\")") is C.v-bool(false)
  eval("(str= \"a\" \"a\")") is C.v-bool(true)
  eval("(str= \"\" \"\")") is C.v-bool(true)
  eval("(str= (++ \"a\" \"b\") \"ab\")") is C.v-bool(true)
  eval("(str= \"ab\" (++ \"a\" \"b\"))") is C.v-bool(true)
  eval("(str= (++ \"a\" \"b\") (++ \"a\" \"b\"))") is C.v-bool(true)

  #num=
  eval("(num= 1 2)") is C.v-bool(false)
  eval("(num= 1 1)") is C.v-bool(true)
  eval("(num= 0 0)") is C.v-bool(true)
  eval("(num= (+ 1 2) 3)") is C.v-bool(true)
  eval("(num= 3 (+ 1 2))") is C.v-bool(true)
  eval("(num= (+ 1 2) (+ 1 2))") is C.v-bool(true)
  
  #+
  eval("(+ 0 0)") is C.v-num(0)
  eval("(+ 1 2)") is C.v-num(3)
  eval("(+ (+ 1 2) 1)") is C.v-num(4)
  eval("(+ 1 (+ 1 2))") is C.v-num(4)
  eval("(+ (+ 1 2) (+ 3 4))") is C.v-num(10)
  
  #+
  eval("(++ \"a\" \"b\")") is C.v-str("ab")
  eval("(++ \"\" \"\")") is C.v-str("")
  eval("(++ (++ \"a\" \"b\") \"c\")") is C.v-str("abc")
  eval("(++ \"a\" (++ \"b\" \"c\"))") is C.v-str("abc")
  eval("(++ (++ \"a\" \"b\") (++ \"c\" \"d\"))") is C.v-str("abcd")
  
  #if
  eval("(if true 1 2)") is C.v-num(1)
  eval("(if false 1 2)") is C.v-num(2)
  eval("(if true \"a\" \"b\")") is C.v-str("a")
  eval("(if false \"a\" \"b\")") is C.v-str("b")
  eval("(if true true false)") is C.v-bool(true)
  eval("(if false true false)") is C.v-bool(false)
  
  #nested in first expr of if
  eval("(if (and true true) 1 2)") is C.v-num(1)
  eval("(if (and true false) 1 2)") is C.v-num(2)
  eval("(if (or true false) 1 2)") is C.v-num(1)
  eval("(if (or false false) 1 2)") is C.v-num(2)
  eval("(if (if true true false) 1 2)") is C.v-num(1)
  eval("(if (if false true false) 1 2)") is C.v-num(2)
  eval("(if (num= 1 1) 1 2)") is C.v-num(1)
  eval("(if (num= 1 2) 1 2)") is C.v-num(2)
  eval("(if (str= \"a\" \"a\") 1 2)") is C.v-num(1)
  eval("(if (str= \"a\" \"b\") 1 2)") is C.v-num(2)
  
  #nested in second expr of if
  eval("(if true (+ 1 2) 2)") is C.v-num(3)
  eval("(if false (+ 1 2) 2)") is C.v-num(2)
  eval("(if true (++ \"a\" \"b\") \"c\")") is C.v-str("ab")
  eval("(if false (++ \"a\" \"b\") \"c\")") is C.v-str("c")
  eval("(if true (and true false) true)") is C.v-bool(false)
  eval("(if false (and true false) true)") is C.v-bool(true)
  
  #nested in third expr of if
  eval("(if true 2 (+ 1 2))") is C.v-num(2)
  eval("(if false 2 (+ 1 2))") is C.v-num(3)
  eval("(if true \"c\" (++ \"a\" \"b\"))") is C.v-str("c")
  eval("(if false \"c\" (++ \"a\" \"b\"))") is C.v-str("ab")
  eval("(if true true (and true false))") is C.v-bool(true)
  eval("(if false false (and true false))") is C.v-bool(false)

  #nested if in second/third expr
  eval("(if true (if false 1 2) 3)") is C.v-num(2)
  eval("(if false 3 (if false 1 2))") is C.v-num(2)
  
  #different types in if
  eval("(if true 3 true)") is C.v-num(3)
  eval("(if false 3 true)") is C.v-bool(true)
  eval("(if true (+ 3 4) (and true false))") is C.v-num(7)
  eval("(if false (+ 3 4) (and true false))") is C.v-bool(false)
  
  #more nested if
  eval("(+ 1 (if true 3 4))") is C.v-num(4)
  eval("(+ (if true 3 4) 1)") is C.v-num(4)
  eval("(++ \"a\" (if true \"b\" \"c\"))") is C.v-str("ab")
  eval("(num= 1 (if true 2 3))") is C.v-bool(false)
  eval("(str= \"a\" (if true \"a\" \"c\"))") is C.v-bool(true)
  eval("(and true (if true false true))") is C.v-bool(false)
  eval("(or false (if true false true))") is C.v-bool(false)
  
  #ERROR CHECKING
  
  #+
  eval("(+ 1 \"str\")") raises-satisfies
    _ == C.err-bad-arg-to-op(C.op-plus, C.v-str("str"))
  eval("(+ \"str\" 1)") raises-satisfies
    _ == C.err-bad-arg-to-op(C.op-plus, C.v-str("str"))
  eval("(+ \"a\" \"b\")") raises-satisfies
    _ == C.err-bad-arg-to-op(C.op-plus, C.v-str("a"))
  eval("(+ 1 true)") raises-satisfies
    _ == C.err-bad-arg-to-op(C.op-plus, C.v-bool(true))
  eval("(+ true 1)") raises-satisfies
    _ == C.err-bad-arg-to-op(C.op-plus, C.v-bool(true))
  eval("(+ true false)") raises-satisfies
  _ == C.err-bad-arg-to-op(C.op-plus, C.v-bool(true))
  
  #++
  eval("(++ 1 \"str\")") raises-satisfies
  _ == C.err-bad-arg-to-op(C.op-append, C.v-num(1))
  eval("(++ \"str\" 1)") raises-satisfies
    _ == C.err-bad-arg-to-op(C.op-append, C.v-num(1))
  eval("(++ 1 2)") raises-satisfies
   _ == C.err-bad-arg-to-op(C.op-append, C.v-num(1))
  eval("(++ 1 true)") raises-satisfies
  _ == C.err-bad-arg-to-op(C.op-append, C.v-num(1))
  eval("(++ true 1)") raises-satisfies
  _ == C.err-bad-arg-to-op(C.op-append, C.v-bool(true))
  eval("(++ true false)") raises-satisfies
  _ == C.err-bad-arg-to-op(C.op-append, C.v-bool(true))
  
  #str=
  eval("(str= 1 \"str\")") raises-satisfies
  _ == C.err-bad-arg-to-op(C.op-str-eq, C.v-num(1))
  eval("(str= \"str\" 1)") raises-satisfies
    _ == C.err-bad-arg-to-op(C.op-str-eq, C.v-num(1))
  eval("(str= 1 2)") raises-satisfies
   _ == C.err-bad-arg-to-op(C.op-str-eq, C.v-num(1))
  eval("(str= 1 true)") raises-satisfies
  _ == C.err-bad-arg-to-op(C.op-str-eq, C.v-num(1))
  eval("(str= true 1)") raises-satisfies
  _ == C.err-bad-arg-to-op(C.op-str-eq, C.v-bool(true))
  eval("(str= true false)") raises-satisfies
  _ == C.err-bad-arg-to-op(C.op-str-eq, C.v-bool(true))
  
  #num=
  eval("(num= 1 \"str\")") raises-satisfies
  _ == C.err-bad-arg-to-op(C.op-num-eq, C.v-str("str"))
  eval("(num= \"str\" 1)") raises-satisfies
    _ == C.err-bad-arg-to-op(C.op-num-eq, C.v-str("str"))
  eval("(num= \"a\" \"b\")") raises-satisfies
    _ == C.err-bad-arg-to-op(C.op-num-eq, C.v-str("a"))
  eval("(num= 1 true)") raises-satisfies
    _ == C.err-bad-arg-to-op(C.op-num-eq, C.v-bool(true))
  eval("(num= true 1)") raises-satisfies
    _ == C.err-bad-arg-to-op(C.op-num-eq, C.v-bool(true))
  eval("(num= true false)") raises-satisfies
  _ == C.err-bad-arg-to-op(C.op-num-eq, C.v-bool(true))
  
  #and
  eval("(and true 1)") raises-satisfies
  _ == C.err-if-got-non-boolean(C.v-num(1))
  eval("(and 1 true)") raises-satisfies
  _ == C.err-if-got-non-boolean(C.v-num(1))
  eval("(and \"a\" true)") raises-satisfies
  _ == C.err-if-got-non-boolean(C.v-str("a"))
  eval("(and true \"a\")") raises-satisfies
  _ == C.err-if-got-non-boolean(C.v-str("a"))
  
  #or
  eval("(or false 1)") raises-satisfies
  _ == C.err-if-got-non-boolean(C.v-num(1))
  eval("(or 1 true)") raises-satisfies
  _ == C.err-if-got-non-boolean(C.v-num(1))
  eval("(or \"a\" true)") raises-satisfies
  _ == C.err-if-got-non-boolean(C.v-str("a"))
  eval("(or false \"a\")") raises-satisfies
  _ == C.err-if-got-non-boolean(C.v-str("a"))
  
  #if
   eval("(if 1 2 3)") raises-satisfies
  _ == C.err-if-got-non-boolean(C.v-num(1))
  eval("(if \"a\" 2 3)") raises-satisfies
  _ == C.err-if-got-non-boolean(C.v-str("a"))
  eval("(if (+ 1 2) 2 3)") raises-satisfies
  _ == C.err-if-got-non-boolean(C.v-num(3))
  eval("(if (++ \"a\" \"b\") 2 3)") raises-satisfies
  _ == C.err-if-got-non-boolean(C.v-str("ab"))
  
  #nested errors
  eval("(+ 1 (if 1 2 3))") raises-satisfies
  _ == C.err-if-got-non-boolean(C.v-num(1))
  eval("(+ (if 1 2 3) 1)") raises-satisfies
  _ == C.err-if-got-non-boolean(C.v-num(1))
  eval("(+ 1 (num= true false))") raises-satisfies
  _ == C.err-bad-arg-to-op(C.op-num-eq, C.v-bool(true))
  eval("(+ (num= true false) 1)") raises-satisfies
  _ == C.err-bad-arg-to-op(C.op-num-eq, C.v-bool(true))
  eval("(+ 1 (str= true false))") raises-satisfies
  _ == C.err-bad-arg-to-op(C.op-str-eq, C.v-bool(true))
  eval("(+ 1 (+ true false))") raises-satisfies
  _ == C.err-bad-arg-to-op(C.op-plus, C.v-bool(true))
  eval("(+ 1 (++ true false))") raises-satisfies
  _ == C.err-bad-arg-to-op(C.op-append, C.v-bool(true))
  eval("(+ 1 (and 1 2))") raises-satisfies
  _ == C.err-if-got-non-boolean(C.v-num(1))
  eval("(+ 1 (or 1 2))") raises-satisfies
  _ == C.err-if-got-non-boolean(C.v-num(1))
end