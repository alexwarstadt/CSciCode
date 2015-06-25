import shared-gdrive("interp-state-definitions.arr", "0BwTSVb9gEh9-dU41NklRaEJISWM") as C


import eval from my-gdrive("interp-state-code.arr")

err-if-got-non-boolean = C.err-if-got-non-boolean
err-bad-arg-to-op = C.err-bad-arg-to-op
err-unbound-id = C.err-unbound-id
err-arity-mismatch = C.err-arity-mismatch
err-not-a-function = C.err-not-a-function
err-not-a-record = C.err-not-a-record
err-field-not-found = C.err-field-not-found

#SWEEP.......

check "1: and short-circuits":
  eval("(let ((x 1))" + 
         "(do (and false " + 
                  "(do (set x 2) true))" + 
         "x))") 
    is C.v-num(1)
end

check "2: extend evaluates record first":
  eval("(let ((x 1))" + 
         "(lookup (extend (record (a (do (set x 2))))" + 
                 "b" + 
                 "(do (set x (+ x 1)))) b))") is C.v-num(3)
end

check "3: side effects in arguments effect later arguments":
  eval("(let ((a \"str\"))" + 
         "((lam(x y z) (++ \"x:\" (++ x (++ \" y:\" (++ y (++ \" z:\" z))))))" +
           "(do (set a (++ a \"i\")))" + 
           "(do (set a (++ a \"n\")))" +
           "(do (set a (++ a \"g\")))))") 
    is C.v-str("x:stri y:strin z:string")
end

check "4: side effects on recursive calls":
  eval("(let ((a 0))" +
         "((rec-lam count (x)" + 
           "(if (num= x 0) " +
             "a " + 
             "(do (set a (+ a 1)) (count (+ x -1))))) " + 
         "5))")
    is C.v-num(5)
end

check "5: shadowing different from mutation":
  eval("(let ((a 1)) " + 
         "(let ((f (lam (x) (set a (+ a x))))) " + 
           "(let ((a 2)) " + 
             "(f 3))))") 
    is C.v-num(4)
end

check "6: mutate with field; not the same as extend":
  eval("(let ((a (record (x 1)))) " + 
         "(+ (with a (do (set x 3) (+ x x))) " + 
            "(with a (lookup (extend a x (+ x 1)) x))))")
 is C.v-num(8)
end

check "7: set fields in lambda":
  eval("(let ((a (record (x 1)))) ((lam (y) (with y (set x 2))) a))") is C.v-num(2)
end

check "8: mutate a recursive function":
  eval("((rec-lam REC (m n) (if (num= m 0) n (do (set REC (lam (x y) (+ x y))) (REC m n)))) 1 6)") is C.v-num(7)
end

check "9: recursive function defined and applied within recursive function":
  eval("((rec-lam minus-x (x y z)" +
            "(if (num= x 0) " +
                "z " + 
                "(minus-x (+ x -1) " +
                         "0 " +
                         "(+ ((rec-lam minus-y (y z) " +
                              "(if (num= y 0) " +
                                  "z " +
                                  "(minus-y (+ y -1) (+ z 1)))) " +
                              "y " + 
                              "z) " +
                            "1)))) " +
             "5 10 0)")
      is C.v-num(15)
end

check "10: recursive function id alternating between recursive functions":
  eval("((rec-lam F1 (x y) (if (num= x 0) y (do ((rec-lam F2 (x y) (if (num= x 0) y (F1 (+ x -1) (+ y 100)))) (+ x -1) (+ y 1))))) 10 0)") is C.v-num(505)
end

check "rec-lam":
  eval("((rec-lam not-recursive (x) (+ x 1)) 3)") is C.v-num(4)
  eval("((rec-lam no-args () (+ 2 1)))") is C.v-num(3)
  eval("((rec-lam triangle-num (x) (if (num= x 0) 0 (+ x (triangle-num (+ x -1))))) 5)") is C.v-num(15)
  eval("((rec-lam repeat (str n) (if (num= n 0) \"\" (++ str (repeat str (+ n -1))))) \"a\" 5)") is C.v-str("aaaaa")
  eval("((rec-lam repeat (str n) (if (num= n 0) str (++ str (repeat str (+ n -1))))) \"a\")") raises-satisfies C.is-err-arity-mismatch
  eval("((rec-lam problem (m n) (do (set problem 1) (problem m n))) 1 2)") raises-satisfies C.is-err-not-a-function
  eval("((rec-lam repeat (str n) (if (num= n 0) str (do (set repeat (lam (x) x)) (++ str (repeat str (+ n -1)))))) \"a\" 5)") raises-satisfies C.is-err-arity-mismatch
end

check "set":
  eval("(let ((a 1)) (set a 2))") is C.v-num(2)
  eval("(let ((a 1)) (set a true))") is C.v-bool(true)
  eval("(let ((a 1)) ((lam (x) (+ x 1)) 1))") is C.v-num(2)
  eval("(let ((a 1)) (with (set a (record (x 1) (y 2))) (+ x y)))") is C.v-num(3)

end

check "do":
  eval("(do false)") is C.v-bool(false)
  eval("(do (and true false))") is C.v-bool(false)
  eval("(do 1 (+ 1 2))") is C.v-num(3)
  eval("(do (let ((x 1)) 3) (set x 3))") raises-satisfies C.is-err-unbound-id
  eval("(let ((x 1) (y 2)) (do (set x 10) (set y 11) (+ x y)))") is C.v-num(21)
  eval("(let ((x (record (a 1)))) (do (extend x b 2) (with x (+ b a))))") raises-satisfies C.is-err-unbound-id
  eval("(let ((x (record (a 1)))) (with (do (extend x b 2)) (+ a b)))") is C.v-num(3)
  eval("(let ((x (record (a 1)))) (with (do (extend x b 2)) (do (set b 3) (+ a b))))") is C.v-num(4)
  eval("(let ((a 1) (b 2) (c 3)) (do (set a 10) (set b 20) (set c 30)))") is C.v-num(30)
  eval("(let ((a 1) (b 2) (c 3)) (do (set a 10) (set b 20) (set c 30) (+ a (+ b c))))") is C.v-num(60)
end

check "left to right evaluation":
  
  #plus
  eval("(let ((a 1)) (+ (do (set a 2) 3) a))") is C.v-num(5)
  eval("(let ((a 1)) (+ a (do (set a 2) 3)))") is C.v-num(4)
  eval("(let ((a true)) (+ (do (set a 1) 10) a))") is C.v-num(11)
  eval("(let ((a true)) (+ a (do (set a 1) 10)))") raises-satisfies C.is-err-bad-arg-to-op
  
  #str-append
  eval("(let ((a \"a\")) (++ (do (set a \"b\") \"c\") a))") is C.v-str("cb")
  eval("(let ((a \"a\")) (++ a (do (set a \"b\") \"c\")))") is C.v-str("ac")
  
  #num=
  eval("(let ((a 1)) (num= (do (set a 3) 3) a))") is C.v-bool(true)
  eval("(let ((a 1)) (num= a (do (set a 3) 3)))") is C.v-bool(false)
  
  #str=
  eval("(let ((a \"a\")) (str= (do (set a \"c\") \"c\") a))") is C.v-bool(true)
  eval("(let ((a \"a\")) (str= a (do (set a \"c\") \"c\")))") is C.v-bool(false)
  
  #and
  eval("(let ((a true)) (and (do (set a false) true) a))") is C.v-bool(false)
  eval("(let ((a true)) (and a (do (set a false) true)))") is C.v-bool(true)
  
  #or
  eval("(let ((a false)) (or (do (set a true) false) a))") is C.v-bool(true)
  eval("(let ((a false)) (or a (do (set a true) false)))") is C.v-bool(false)
  
  #if
  eval("(let ((a 1)) (if (do (set a 2) true) a 0))") is C.v-num(2)
  
  #record
  eval("(let ((a 1)) (with (record (x (set a (+ a 1))) (y (set a (+ a 1))) (z (set a (+ a 1)))) a))") is C.v-num(4)
  eval("(let ((a 1)) (let ((b (record (x (do 1 2 3 4)) (y (do (set a (+ a 1)) (set a (+ a 1))))))) (with b (+ x a))))") is C.v-num(7)
  eval("(let ((a (record (x 1) (y 2)))) (with (record (x (set a 1))) (lookup a x)))") raises-satisfies C.is-err-not-a-record
  
  #function application
  eval("(let ((a 1)) ((lam (x y z) (+ x (+ y z))) (set a (+ a 1)) (set a (+ a 1)) (set a (+ a 1))))") is C.v-num(9)
  
  #with
  eval("(let ((a 1)) (with (do (set a 100) (record (x 5))) (+ x a)))") is C.v-num(105)
  
  #extend
  eval("(let ((a 1)) (do (extend (record (x (set a 3)) (y (set a 4))) z (set a (+ a 1))) a))") is C.v-num(5)
end

check "mutations in lambda don't happen until application":
  eval("(let ((a 1)) (let ((b (lam () (set a 100)))) a))") is C.v-num(1)
  eval("(let ((a 1)) (let ((b (lam () (set a 100)))) (b)))") is C.v-num(100)
  eval("(let ((a 1)) (let ((b (lam () (set a 100)))) (+ a (b))))") is C.v-num(101)
end

check "short circuit and/if/or":
  eval("(let ((a 1)) (do (and false (do (set a 2) true)) a))") is C.v-num(1)
  eval("(let ((a 1)) (if false (do (set a 2) true) a))") is C.v-num(1)
  eval("(let ((a 1)) (do (or true (do (set a 2) false)) a))") is C.v-num(1)
end

check "shadowing is not mutation":
  eval("(let ((a 1)) (let ((f (lam () (set a 100))) (a 10)) (+ (f) a)))") is C.v-num(110)
  eval("(let ((a 1)) (let ((a 10) (f (lam () (set a 100)))) (+ (f) a)))") is C.v-num(110)
  eval("(let ((a 1)) (do (+ (with (record (a 10)) (set a 100))  a)))") is C.v-num(101)
end




















check "OLD TESTS FROM INTERP-RECORD":

  #simple record
  eval("(record)") satisfies C.is-v-rec
  eval("(record (a 0))") satisfies C.is-v-rec
  eval("(record (a 0) (b 2))") satisfies C.is-v-rec
  eval("(record (a 0) (b \"hello\") (c true))") satisfies C.is-v-rec
  eval("(record (a (lam(x) (+ x 1))))") satisfies C.is-v-rec
  eval("(record (a (+ 2 3)))") satisfies C.is-v-rec
  eval("(record (a (record (b 2))))") satisfies C.is-v-rec
  eval("(record (a (record (a 2))))") satisfies C.is-v-rec

  #lookup
  eval("(lookup (record (a 0)) a)") is C.v-num(0)
  eval("(lookup (record (a 0) (b \"hello\") (c false)) a)") is C.v-num(0)
  eval("(lookup (record (a 0) (b \"hello\") (c false)) b)") is C.v-str("hello")
  eval("(lookup (record (a 0) (b \"hello\") (c false)) c)") is C.v-bool(false)
  eval("(lookup (record (a (lam(x) (+ x 1)))) a)") satisfies C.is-v-fun
  eval("(lookup (record (a (+ 2 3))) a)") is C.v-num(5)
  eval("(lookup (record (a (record (b 2)))) a)") satisfies C.is-v-rec
  eval("(lookup (record (a (record (a 2)))) a)") satisfies C.is-v-rec
  
  #lookup nested inside fun-app
  eval("((lookup (record (a (lam(x) (+ x 1)))) a) 4)") is C.v-num(5)
  eval("((lookup (record (a (lam(a) (+ a 1)))) a) 4)") is C.v-num(5)
  eval("((lam(x) (+ x 1)) (lookup (record (a 4) (b 3)) a))") is C.v-num(5)
  
  #lookup within lookups
  eval("(lookup (lookup (record (a (record (b 2)))) a) b)") is C.v-num(2)
  eval("(lookup (lookup (record (a (record (b 2))) (b 3)) a) b)") is C.v-num(2)
  eval("(lookup (lookup (record (a (record (a 2)))) a) a)") is C.v-num(2)
  
  #let
  eval("(let ((a 1)) (lookup (record (a 2)) a))") is C.v-num(2)
  eval("(let ((a (record (a \"one\") (b false))) (b 2)) (lookup a a))") is C.v-str("one")
  eval("(let ((a (record (x 1)))) (+ (lookup a x) (lookup a x)))") is C.v-num(2)
  eval("(let ((a 1)) (lookup (record (a (+ a a))) a))") is C.v-num(2)


  #lookup errors
  eval("(lookup 1 a)") raises-satisfies C.is-err-not-a-record
  eval("(lookup \"str\" a)") raises-satisfies C.is-err-not-a-record
  eval("((lam(x) (+ x 1)) (lookup (let ((a 4)) a) a))") raises-satisfies C.is-err-not-a-record
  eval("(lookup (lookup (record (a 1)) a) b)") raises-satisfies C.is-err-not-a-record
  eval("(let ((a (record (a \"one\") (b false))) (b 2)) (lookup b b))") raises-satisfies C.is-err-not-a-record
  eval("(lookup (record (a 1) (b 2)) c)") raises-satisfies C.is-err-field-not-found
  eval("(let ((a (record (a \"one\") (b false))) (b 2)) (lookup a c))") raises-satisfies C.is-err-field-not-found
  eval("(lookup (record (a (+ 1 false)) (b 1)) b)") raises-satisfies C.is-err-bad-arg-to-op
  
  
  #don't get to error b/c short circuit
  eval("(and false (lookup 1 a))") is C.v-bool(false)
  eval("(if true \"str\" (lookup (record (a 1) (b 2)) c))") is C.v-str("str")


  #with
  eval("(with (record (a 1) (b 2)) 3)") is C.v-num(3)
  eval("(with (record (a 1) (b 2)) (+ a b))") is C.v-num(3)
  eval("(with (record (a 1) (b 2)) a)") is C.v-num(1)
  eval("(with (record (a (record (c 10))) (b 2)) (lookup a c))") is C.v-num(10)
  eval("(with (record (a (lam(a) (and a true)))) (a false))") is C.v-bool(false)
  eval("(with (record (a 1)) (+ a a))") is C.v-num(2)
  
  #shadowing":
  eval("(let ((a 100) (b 200)) (with (record (a 1) (b 2)) a))") is C.v-num(1)
  eval("(let ((a 100) (b 200)) (+ (with (record (a 1) (b 2)) a) b))") is C.v-num(201)
  eval("(let ((a (record (c 100)))) (with (record (a (record (c 10))) (b 2)) (lookup a c)))") is C.v-num(10)
  eval("(let ((a (record (c 100)))) (with (record (a (record (c 10))) (b 2)) (lookup a c)))") is C.v-num(10)
  eval("(let ((a (lam(b) (or a true)))) (with (record (a (lam(a) (and a true)))) (a false)))") is C.v-bool(false)
  eval("(let ((a (lam(b) (or b true)))) (or (with (record (a (lam(a) (and a true)))) (a false)) (a false)))") is C.v-bool(true)
  eval("((lam(x) (with (record (x 5)) (+ x 1))) 100)") is C.v-num(6)
  
  #"funny bindings and nestings involving with":
  eval("(with (record (a 1) (b 2)) ((lam(a b) (+ (+ a a) b)) b a))") is C.v-num(5)
  eval("(with (record (a 1) (b 2)) (let ((a 10) (b 20)) (+ a b)))") is C.v-num(30)
  eval("(with (record (a 1) (b 2)) (+ (let ((a 10) (b 20)) (+ a b)) b))") is C.v-num(32)
  eval("((lam(x y) (++ x (with (record (x \"str1\")) (++ x y)))) \"str2\" \"str3\")") is C.v-str("str2str1str3")
  eval("(let ((b 100) (a (with (record (b 1)) (+ b 2)))) (+ a b))") is C.v-num(103)

  #"errors in with":
  eval("(with (record (a 1) (b 2)) c)") raises-satisfies C.is-err-unbound-id
  eval("(with (record (a (record (b 2)))) (lookup a c))") raises-satisfies C.is-err-field-not-found
  eval("(with (record (a (record (b 2))) (b 9)) (lookup b c))") raises-satisfies C.is-err-not-a-record
  eval("(+ (with (record (a 1) (b 2)) a) b)") raises-satisfies C.is-err-unbound-id
  eval("(with 1 2)") raises-satisfies C.is-err-not-a-record

  #"extend":
  eval("(extend (record) a 1)") satisfies C.is-v-rec
  eval("(lookup (extend (record) a 1) a)") is C.v-num(1)
  eval("(extend (record (a 1)) b 2)") satisfies C.is-v-rec
  eval("(extend (record (a 1)) a 2)") satisfies C.is-v-rec
  eval("(lookup (extend (record (a 1)) b 2) b)") is C.v-num(2)
  eval("(lookup (extend (record (a 1)) a 2) a)") is C.v-num(2)
  eval("(lookup (extend (extend (record (a 1)) b 2) c 3) a)") is C.v-num(1)
  eval("(let ((a (record (x 1)))) (lookup (extend a y 2) y))") is C.v-num(2)
  eval("(let ((a (record (x 1)))) (+ (lookup (extend a y 2) y) (lookup a x)))") is C.v-num(3)
  eval("(let ((a 2)) (lookup (extend (record (x 1)) y a) y))") is C.v-num(2)
  eval("(let ((a 2)) (lookup (extend (record (a 1)) y a) y))") is C.v-num(2)
  eval("(let ((a 2)) (lookup (extend (record (a 1)) a a) a))") is C.v-num(2)
  eval("(with (record (a 1) (b 2)) (lookup (extend (record (x 1)) y b) y))") is C.v-num(2)
  eval("(with (extend (record (a 1)) b 3) (+ a b))") is C.v-num(4)
  eval("(let ((a (record (x 1)))) (let ((b (extend a y 2))) (lookup b y)))") is C.v-num(2)
  eval("(let ((a (record (x 1)))) (lookup (let ((b (lam(x) (extend a y x)))) (b a)) y))") satisfies C.is-v-rec
  eval("(let ((a (record (x 1)))) (with (lookup (let ((b (lam(x) (extend a y x)))) (b a)) y) x))") is C.v-num(1)
  eval("(let ((a (record (x 1)))) (with (let ((b (lam(x) (extend a y x)))) (b a)) (lookup y x)))") is C.v-num(1)
  eval("(let ((a (record (x 1)))) (with (let ((b (lam(x) (extend a x x)))) (b a)) (lookup x x)))") is C.v-num(1)

  #"extend errors":
  eval("(extend 1 a 3)") raises-satisfies C.is-err-not-a-record
  eval("(let ((a (record (x 1)))) (let ((b (extend a y 2))) (lookup a y)))") raises-satisfies C.is-err-field-not-found
  eval("(let ((a (record (x 1)))) (+ (with (extend a y 2) x) y))") raises-satisfies C.is-err-unbound-id
  eval("(let ((a (record (x 1)))) (with (lookup (let ((b (lam(x) (extend a y x)))) (b a)) y) (lookup a y)))") raises-satisfies C.is-err-field-not-found
end













check "OLD TEST CASES!!!!!!!!":
  
  #lambda
  eval("(lam() 5)") satisfies C.is-v-fun
  eval("(lam(x) 5)") satisfies C.is-v-fun
  eval("(lam(x) (+ x 1))") satisfies C.is-v-fun
  eval("(lam(x y) (+ x y))") satisfies C.is-v-fun
  eval("(lam(x y z) (if x (+ y z) 10))") satisfies C.is-v-fun
  eval("(lam(x y z) 5)") satisfies C.is-v-fun
  
  #nested lambdas
  eval("(lam(x y) (lam(z) (+ (+ x y) z)))") satisfies C.is-v-fun
    
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


