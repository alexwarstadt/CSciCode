import shared-gdrive("cps-definitions.arr", "0BwTSVb9gEh9-cEZCNWtmT1FxeHM") as C
import eval, eval-cps from my-gdrive("cps-code.arr")

is-err-if-got-non-boolean = C.is-err-if-got-non-boolean
is-err-bad-arg-to-op = C.is-err-bad-arg-to-op
is-err-unbound-id = C.is-err-unbound-id
is-err-not-a-function = C.is-err-not-a-function


check:
  
  fun test-cps(prog):
    eval(prog) is eval-cps(prog)
  end

  
  ############## SWEEP ###############

  #user defined functions
  test-cps("((fun (x) (x 1)) (fun (y) (+ y 1)))")

  #check "2: if does not evaluate both branches":
  test-cps("(if true 1 (+ true 1))")

  #check "3: nesting":
  test-cps("(+ (+ (if (if true false true) 1 0) (+ 1 2)) ((fun (x) (+ x 1)) 2))")

  #check "4: static scope":
  test-cps("(let ((a 1)) (let ((b (fun (x) (+ x a)))) (let ((a 100)) (b 2))))")

  #check "5: evaluation left to right":
  eval-cps("(+ (+ 1 true) a)") raises-satisfies is-err-bad-arg-to-op

  #check "6: condition evaluated first":
  eval-cps("(if (+ 1 2) 100 200)") raises-satisfies is-err-if-got-non-boolean

  #check "7: function definition inside function":
  test-cps("((fun (x) (+ 1 ((fun (y) (+ x y)) 10))) 100)")
  
  
  
  
  
  
  
  
  ############## END SWEEP ##############
  
  #simple expressions:
  test-cps("1")
  test-cps("true")
  test-cps("(+ 1 1)")
  test-cps("(num= 1 2)")
  test-cps("(if true 1 2)")
  test-cps("((fun (x) 1) 2)")
  test-cps("(let ((a 1)) a)")

  #check "function application":
  test-cps("((fun (x) 5) (+ 1 2))")
  test-cps("((fun (x) (+ x 1)) 4)")
  
  #nested stuff
  test-cps("((fun (x) (let ((a x)) (a a))) (fun (x) 3))")
  test-cps("(let ((a ((fun (x) (+ x 2)) 3))) ((fun (x) (num= x 0)) a))")
  
  #same id used
  test-cps("((fun (y) ((fun (x) ((fun (x) (+ x y)) (+ x y))) 17)) 18)")
  test-cps("(let ((x (fun (x) (x 2)))) ((fun (y) (x y)) (fun (y) 2)))")
  test-cps("(let ((a 1)) (let ((a 2)) a))")
  
  #errors
  eval-cps("((fun(x) 5) (+ true true))") raises-satisfies is-err-bad-arg-to-op
  eval-cps("((fun(y) (+ x 1)) 2)") raises-satisfies is-err-unbound-id
  eval-cps("(1 2)") raises-satisfies is-err-not-a-function
  eval-cps("((+ 1 2) 2)") raises-satisfies is-err-not-a-function
  eval-cps("(if (if true false true) 1 (+ 1 true))") raises-satisfies is-err-bad-arg-to-op
  eval-cps("(+ 1 a)") raises-satisfies is-err-unbound-id
  eval-cps("(let ((a (fun (x) (+ x b)))) (let ((b 2)) (a 1)))") raises-satisfies is-err-unbound-id
  test-cps("(let ((a (fun (x) b))) 1)") #no error because function body not evaled
  
  #evaluation is left-to-right
  eval-cps("(+ (num= 1 true) (num= 1 false))") raises-satisfies is-err-bad-arg-to-op
  eval-cps("(num= (num= 1 true) a)") raises-satisfies is-err-bad-arg-to-op
  eval-cps("(if a (num= 1 true) (num= 1 false))") raises-satisfies is-err-unbound-id
  eval-cps("(+ (+ 1 (+ 1 (+ 1 a))) (+ 1 true))") raises-satisfies is-err-unbound-id
  
  #arg-value evaluated before function body
  eval-cps("(let ((a b)) (+ 1 true))") raises-satisfies is-err-unbound-id
  eval-cps("((fun (x) a) (+ 1 true))") raises-satisfies is-err-bad-arg-to-op
  
  
  
  
end















