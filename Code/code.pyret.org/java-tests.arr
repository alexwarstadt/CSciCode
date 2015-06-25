import shared-gdrive("java-definitions.arr", "0By8FB99CQCH9SHJyR05ZemZtaVU") as C
import eval from my-gdrive("java-code.arr")

is-err-class-not-found = C.is-err-class-not-found
is-err-method-not-found = C.is-err-method-not-found
is-err-unbound-id = C.is-err-unbound-id
is-err-type-mismatch = C.is-err-type-mismatch
is-err-this-outside-of-method = C.is-err-this-outside-of-method
is-err-non-object = C.is-err-non-object
is-err-field-not-found = C.is-err-field-not-found

check:
  eval("(program (classes) 3)") is C.v-num(3)
end

#####SWEEP######

check "1: fields with same name are determined by static type decl":
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields (x Num)) " + 
                 "(methods)) " + 
               "(class B extends A " + 
                 "(fields (x Num)) " +
                 "(methods (method Num set-x (Num n) (set this x n))))) " + 
      "(let (A my-A-B (new B)) " + 
        "(do (set my-A-B x 100) " + 
            "(+ (call my-A-B set-x 10) " + 
               "(get my-A-B x)))))") 
    is C.v-num(110)
end

check "2: methods with same name chosen from dynamic type / overriding":
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields) " + 
                 "(methods (method Num add-something (Num n) (+ 1 n)))) " + 
               "(class B extends A " +
                 "(fields) " + 
                 "(methods (method Num add-something (Num n) (+ 10 n))))) " + 
      "(let (A my-A-B (new B)) " + 
    "(call my-A-B add-something 100)))") 
    is C.v-num(110)
end

check "3: recursion":
  eval(
    "(program (classes " + 
               "(class Nat-num extends Object " + 
                 "(fields) " + 
                 "(methods (method Num count (Num dummy) 0))) " + 
               "(class Zero extends Nat-num " +
                 "(fields) " + 
                 "(methods (method Num count (Num dummy) 0) " + 
                          "(method Not-zero add1 (Num dummy) " +
                            "(let (Not-zero a (new Not-zero)) " +
                              "(do (set a rest this) a)))))" +
               "(class Not-zero extends Nat-num " +
                 "(fields (rest Nat-num)) " + 
                 "(methods (method Num count (Num dummy) " +
                            "(+ 1 (call (get this rest) count 0))) " +
                          "(method Not-zero add1 (Num dummy) " +
                            "(let (Not-zero a (new Not-zero)) " +
                              "(do (set a rest this) a))))))" +
    "(let (Nat-num five (call (call (call (call (call (new Zero) " +
                          "add1 0) add1 0) add1 0) add1 0) add1 0)) " + 
        "(call five count 0)))") 
    is C.v-num(5)
end

check "4: mutation, and access parent fields":
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields (x Num)) (methods)) " + 
               "(class B extends A " +
                 "(fields (y Num)) (methods))) " + 
      "(let (B b1 (new B)) " + 
        "(let (B b2 (new B)) " + 
    "(do (set b1 x 1) (set b2 x 10) (set b1 x 100) (+ (get b2 x) (get b1 x))))))") 
    is C.v-num(110)
end

check "5: mutation within a method":
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields (x Num)) " + 
                 "(methods)) " + 
               "(class B extends A " +
                 "(fields (y Num)) " +
                 "(methods (method Num set-x (Num n) (set this x n))))) " + 
      "(let (B b1 (new B)) " + 
        "(let (B b2 (new B)) " + 
          "(do (call b1 set-x 1) (call b2 set-x 10) (call b1 set-x 100) " + 
              "(+ (get b2 x) (get b1 x))))))") 
    is C.v-num(110)
end

check "6: construct an object inside an object, methods with side effects":
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields (x Num)) " + 
                 "(methods (method A set-and-ret (Num n) " +
                            "(do (set this x n) this)))) " + 
               "(class B extends Object " +
                 "(fields (y A) (2y A)) " +
                 "(methods (method A set-y-and-2y (Num n) " +
                            "(do (set this y (call (new A) set-and-ret n)) " +
                            "(set this 2y (call (new A) set-and-ret (+ n n)))))))) " + 
      "(let (B b1 (new B)) " + 
        "(+ (do (call b1 set-y-and-2y 50) (get (get b1 y) x)) " +
        "(get (get b1 2y) x))))") 
    is C.v-num(150)
end

check "no classes":
  eval("(program (classes) 100)") is C.v-num(100)
  eval("(program (classes) (+ 100 50))") is C.v-num(150)
  eval("(program (classes) (let (Num x 100) x))") is C.v-num(100)
  eval("(program (classes) (let (Num x 100) (let (Num x 200) x)))") is C.v-num(200)
  eval("(program (classes) (do 100 200 300))") is C.v-num(300)
end

check "no classes, errors":
  eval("(program (classes) this)") raises-satisfies C.is-err-this-outside-of-method
  eval("(program (classes) (set 1 x 2))") raises-satisfies C.is-err-non-object
  eval("(program (classes) (get 1 x))") raises-satisfies C.is-err-non-object
  eval("(program (classes) (call 1 x 2))") raises-satisfies C.is-err-non-object
  eval("(program (classes) x)") raises-satisfies C.is-err-unbound-id
end

check "covariance/contravariance are good":
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields) " + 
                 "(methods (method A does (Num dummy) this))) " + 
               "(class B extends A " +
                 "(fields) " +
                 "(methods (method B does (Num dummy) this)))) " + 
    "1)") is C.v-num(1)
  
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields) " + 
                 "(methods (method A does (B arg) this))) " + 
               "(class B extends A " +
                 "(fields) " +
                 "(methods (method A does (A arg) arg)))) " + 
    "1)") is C.v-num(1)
  
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields) " + 
                 "(methods (method A does (B arg) arg))) " + 
               "(class B extends A " +
                 "(fields) " +
                 "(methods (method A does (A arg) arg)))) " + 
    "1)") is C.v-num(1)
  
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields) " + 
                 "(methods (method A does (B arg) this))) " + 
               "(class B extends A " +
                 "(fields) " +
                 "(methods (method B does (A arg) this)))) " + 
    "1)") is C.v-num(1)
  
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields) " + 
                 "(methods (method A does (D arg) this) (method A does2 (D arg) this))) " + 
               "(class B extends A " + 
                 "(fields) " + 
                 "(methods (method B does2 (C arg) this) (method B does (C arg) this))) " +
               "(class C extends B " + 
                 "(fields) " + 
                 "(methods (method C does (B arg) this) (method C does2 (B arg) this))) " +
               "(class D extends C " +
                 "(fields) " +
                 "(methods (method D does2 (A arg) this) (method D does (A arg) this)))) " + 
    "1)") is C.v-num(1)
end








check "co-/contravariance errors":
  eval(
    "(program (classes " + 
               "(class B extends Object " + 
                 "(fields) " + 
                 "(methods (method A does (Num dummy) this))) " + 
               "(class A extends B " +
                 "(fields) " +
                 "(methods (method B does (Num dummy) this)))) " + 
    "1)") raises-satisfies C.is-err-type-mismatch
  
  eval(
    "(program (classes " + 
               "(class B extends Object " + 
                 "(fields) " + 
                 "(methods (method A does (B arg) this))) " + 
               "(class A extends B " +
                 "(fields) " +
                 "(methods (method A does (A arg) arg)))) " + 
    "1)") raises-satisfies C.is-err-type-mismatch
  
  eval(
    "(program (classes " + 
               "(class B extends Object " + 
                 "(fields) " + 
                 "(methods (method A does (B arg) arg))) " + 
               "(class A extends B " +
                 "(fields) " +
                 "(methods (method A does (A arg) arg)))) " + 
    "1)") raises-satisfies C.is-err-type-mismatch
  
  eval(
    "(program (classes " + 
               "(class B extends Object " + 
                 "(fields) " + 
                 "(methods (method A does (B arg) this))) " + 
               "(class A extends B " +
                 "(fields) " +
                 "(methods (method B does (A arg) this)))) " + 
    "1)") raises-satisfies C.is-err-type-mismatch
  
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields) " + 
                 "(methods (method A does (D arg) this))) " + 
               "(class B extends A " + 
                 "(fields) " + 
                 "(methods (method A does (D arg) this))) " +
               "(class C extends B " + 
                 "(fields) " + 
                 "(methods (method A does (B arg) this))) " +
               "(class D extends C " +
                 "(fields) " +
                 "(methods (method D does (C arg) this)))) " + 
    "1)") raises-satisfies C.is-err-type-mismatch
  
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields) " + 
                 "(methods (method A does (D arg) this))) " + 
               "(class B extends A " + 
                 "(fields) " + 
                 "(methods (method A does (D arg) this))) " +
               "(class C extends B " + 
                 "(fields) " + 
                 "(methods (method C does (D arg) this))) " +
               "(class D extends C " +
                 "(fields) " +
                 "(methods (method A does (C arg) this)))) " + 
    "1)") raises-satisfies C.is-err-type-mismatch
end




check "field subtypes":
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields (x A)) " + 
                 "(methods)) " + 
               "(class B extends A " + 
                 "(fields (x A)) " + 
                 "(methods)) " +
               "(class C extends B " + 
                 "(fields (x C)) " + 
                 "(methods))) " + 
    "1)") is C.v-num(1)
  
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields (x A)) " + 
                 "(methods)) " + 
               "(class B extends A " + 
                 "(fields (x B)) " + 
                 "(methods)) " +
               "(class C extends B " + 
                 "(fields (x C)) " + 
                 "(methods))) " + 
    "1)") is C.v-num(1)
  
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields (x C)) " + 
                 "(methods)) " + 
               "(class B extends A " + 
                 "(fields (x B)) " + 
                 "(methods)) " +
               "(class C extends B " + 
                 "(fields (x A)) " + 
                 "(methods))) " + 
    "1)") raises-satisfies C.is-err-type-mismatch
  
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields (x C)) " + 
                 "(methods)) " + 
               "(class B extends A " + 
                 "(fields (x A)) " + 
                 "(methods)) " +
               "(class C extends B " + 
                 "(fields (x B)) " + 
                 "(methods))) " + 
    "1)") raises-satisfies C.is-err-type-mismatch
  
    eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields (x C) (y C)) " + 
                 "(methods)) " + 
               "(class B extends A " + 
                 "(fields (x A) (y A)) " + 
                 "(methods)) " +
               "(class C extends B " + 
                 "(fields (x B) (y B)) " + 
                 "(methods))) " + 
    "1)") raises-satisfies C.is-err-type-mismatch
end




check "subtypes everywhere":
  
    eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields (x A)) " + 
                 "(methods)) " + 
               "(class B extends A " +
                 "(fields) " +
                 "(methods))) " + 
    "(set (new B) x (new A)))") satisfies C.is-v-object
  
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields) " + 
                 "(methods)) " + 
               "(class B extends A " +
                 "(fields (x A)) " +
                 "(methods))) " + 
    "(set (new A) x (new A)))") raises-satisfies C.is-err-field-not-found
  
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields (x A)) " + 
                 "(methods)) " + 
               "(class B extends A " +
                 "(fields) " +
                 "(methods))) " + 
    "(set (new A) x (new B)))") satisfies C.is-v-object
  
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields (x B)) " + 
                 "(methods)) " + 
               "(class B extends A " +
                 "(fields) " +
                 "(methods))) " + 
    "(set (new A) x (new A)))") raises-satisfies C.is-err-type-mismatch
  
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields (x A)) " + 
                 "(methods)) " + 
               "(class B extends A " +
                 "(fields) " +
                 "(methods))) " + 
      "(get (new A) x))") is C.v-null
  
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields) " + 
                 "(methods)) " + 
               "(class B extends A " +
                 "(fields (x A)) " +
                 "(methods))) " + 
    "(get (new A) x))") raises-satisfies C.is-err-field-not-found
  
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields) " + 
                 "(methods (method A does (A dummy) this))) " + 
               "(class B extends A " +
                 "(fields) " +
                 "(methods))) " + 
      "(call (new A) does (new B)))") satisfies C.is-v-object
  
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields) " + 
                 "(methods (method A does (B dummy) this))) " + 
               "(class B extends A " +
                 "(fields) " +
                 "(methods))) " + 
    "(call (new A) does (new A)))") raises-satisfies C.is-err-type-mismatch
  
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields) " + 
                 "(methods (method A does (B dummy) this))) " + 
               "(class B extends A " +
                 "(fields) " +
                 "(methods))) " + 
    "(call (new B) does (new A)))") raises-satisfies C.is-err-type-mismatch
  
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields) " + 
                 "(methods (method A does (A dummy) this))) " + 
               "(class B extends A " +
                 "(fields) " +
                 "(methods))) " + 
    "(call (new B) does (new B)))") satisfies C.is-v-object
  
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields) " + 
                 "(methods)) " + 
               "(class B extends A " +
                 "(fields) " +
                 "(methods (method A does (A dummy) this)))) " + 
    "(call (new A) does (new B)))") raises-satisfies C.is-err-method-not-found
end






check "subtype accesses inside methods":
  
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields (x Num)) " + 
                 "(methods)) " + 
               "(class B extends A " +
                 "(fields) " +
                 "(methods (method Num addn (Num n) (+ n (get this x)))))) " + 
    "(let (B b (new B)) (do (set b x 100) (call b addn 50))))") is C.v-num(150)
  
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields) " + 
                 "(methods (method Num addn (Num n) (+ n (get this x))))) " + 
               "(class B extends A " +
                 "(fields (x Num)) " +
                 "(methods))) " + 
    "(let (A a (new A)) (do (call b addn 50))))") raises-satisfies C.is-err-field-not-found
  
  eval(
    "(program (classes " + 
               "(class A extends Object " + 
                 "(fields) " + 
                 "(methods (method Num addn (Num n) (+ n (get this x))))) " + 
               "(class B extends A " +
                 "(fields (x Num)) " +
                 "(methods))) " + 
    "(let (A a (new B)) (do (call b addn 50))))") raises-satisfies C.is-err-field-not-found
  
  
end



check "list recursion":
  eval(
    "(program (classes " + 
               "(class List extends Object " + 
                 "(fields) " + 
                 "(methods (method Num sum (Num dummy) 0) " + 
                 "(method Link link (Num n) (let (Link l (new Link)) (do (set l first n) (set l rest this) l))))) " + 
               "(class Empty extends List " +
                 "(fields) " +
                 "(methods))" + 
               "(class Link extends List " +
                 "(fields (first Num) (rest List)) " +
                 "(methods (method Num sum (Num dummy) (+ (get this first) (call (get this rest) sum 0)))))) " + 
    "(call (call (call (call (call (new Empty) link 1) link 2) link 3) link 4) sum 0))") is C.v-num(10)
  
  
  eval(
    "(program (classes " + 
               "(class List extends Object " + 
                 "(fields) " + 
                 "(methods (method Num sum (Num dummy) 0) " + 
                 "(method Link link (Num n) (let (Link l (new Link)) (do (set l first n) (set l rest this) l))))) " + 
               "(class Empty extends List " +
                 "(fields) " +
                 "(methods))" + 
               "(class Link extends List " +
                 "(fields (first Num) (rest List)) " +
                 "(methods (method Num sum (Num dummy) (+ (get this first) (call (get this rest) sum 0)))))) " + 
    "(call (new Empty) sum 0))") is C.v-num(0)
  
end

check "null":
  
  eval("(program (classes (class A extends Object (fields) (methods))) (null A))") is C.v-null 
  
  eval("(program (classes (class A extends Object (fields) (methods))) (+ (null A) 1))") raises-satisfies C.is-err-type-mismatch
  
  eval("(program (classes " + 
               "(class A extends Object " + 
                 "(fields) " +
                 "(methods (method A does (A a) this)))) " + 
    "(let (A a (new A)) (do (call a does (null A)))))") satisfies C.is-v-object
  
  eval("(program (classes " + 
               "(class A extends Object " + 
                 "(fields) " +
                 "(methods (method A does (A a) this)))) " + 
         "(call (null A) does (new A)))") raises-satisfies C.is-null-pointer-exception
  
  eval("(program (classes " + 
               "(class A extends Object " + 
                 "(fields (a A)) " +
                 "(methods (method A does (A a) this)))) " + 
         "(set (null A) a (new A)))") raises-satisfies C.is-null-pointer-exception
  
  eval("(program (classes " + 
               "(class A extends Object " + 
                 "(fields (a A)) " +
                 "(methods (method A does (A a) this)))) " + 
    "(set (new A) a (null A)))") is C.v-null
  
    eval("(program (classes " + 
               "(class A extends Object " + 
                 "(fields (a A)) " +
                 "(methods (method A does (A a) this)))) " + 
           "(get (null A) a))") raises-satisfies C.is-null-pointer-exception
  
  eval("(program (classes " + 
               "(class A extends Object " + 
                 "(fields (a A)) " +
                 "(methods (method A does (A a) this)))) " + 
    "(get (new A) a))") is C.v-null
  
end






check "fields, mutation, and let bindings are different":
  
  eval("(program (classes " + 
               "(class A extends Object " + 
                 "(fields (a Num)) " +
                 "(methods (method A does (A a) this)))) " + 
    "(let (Num a 10) (let (A my-a (new A)) (do (set my-a a 100) (get my-a a)))))") is C.v-num(100)
  
  eval("(program (classes " + 
               "(class A extends Object " + 
                 "(fields (x Num) (a A)) " +
                 "(methods (method A does (A a) this)))) " + 
    "(let (A a (new A)) (+ (let (A a (new A)) (do (set a x 100) (get a x))) (do (set a x 10) (get a x)))))") is C.v-num(110)
  
  eval("(program (classes " + 
               "(class A extends Object " + 
                 "(fields (x Num) (a A)) " +
                 "(methods (method A does (A a) this)))) " + 
    "(let (A a1 (new A)) (let (A a2 (new A)) (do (set a2 x 10) (set a1 a a2) (set a2 x 100) (get (get a1 a) x)))))") is C.v-num(100)
  
  eval("(program (classes " + 
               "(class A extends Object " + 
                 "(fields (x Num) (a A)) " +
                 "(methods (method A does (A a) this)))) " + 
    "(let (A a1 (new A)) (do (set a1 a a1) (set a1 x 100) (get (get (get (get (get (get a1 a) a) a) a) a) x))))") is C.v-num(100)
  
  
end

check "nested this":
    eval("(program (classes " + 
               "(class A extends Object " + 
                 "(fields (x Num) (a A)) " +
                 "(methods (method Num getx (Num dummy) (get this x))))) " + 
    "(let (A a1 (new A)) (let (A a2 (new A)) (do (set a1 x 10) (set a2 x 20) (set a1 a a2) (call (get a1 a) getx 0)))))") is C.v-num(20)
  
      eval("(program (classes " + 
               "(class A extends Object " + 
                 "(fields (x Num) (a A)) " +
                 "(methods (method Num getx (Num dummy) (get this x)) " +
                          "(method Num get-as-x (Num dummy) (call (get this a) getx 0))))) " + 
    "(let (A a1 (new A)) (let (A a2 (new A)) (do (set a1 x 10) (set a2 x 20) (set a1 a a2) (call a1 get-as-x 0)))))") is C.v-num(20)
end











