provide {eval: eval} end

import shared-gdrive("java-definitions.arr", "0By8FB99CQCH9SHJyR05ZemZtaVU") as C
import sets as S
import string-dict as D
import option as O

fun compile(prog :: C.JProgramSrc) -> C.JProgram:
  C.validate-program(prog) # Check for cycles in classes & such.
  
  fun make-j-class(src-class :: C.JClassSrc) -> C.JClass:
    
    fun compile-method(meth :: C.JMethodSrc) -> C.JMethod:
      new-env = link(C.t-env-cell(meth.arg, meth.arg-type), empty)
      body-comp = rec-compile(meth.body, new-env, new-env, prog.classes, some(src-class.name), true)
      check-subtype(prog.classes, body-comp.ty, meth.ret-type)
      C.j-method(meth.name, meth.arg, body-comp.ex)
    end
                    
    C.j-class(
      src-class.name, 
      src-class.superclass, 
      src-class.fields.map(lam(src-field): C.j-field(src-field.name, src-field.field-type) end), 
      src-class.methods.map(compile-method))
  end
  
  check-co-ntra-variance(prog.classes)
  classes = prog.classes.map(make-j-class)
  C.j-program(classes, rec-compile(prog.psvm, empty, empty, prog.classes, none, true).ex)
end



fun op-find-class(name :: String, classes :: List<C.JClassSrc>) -> Option<C.JClassSrc>:
  cases (List<C.JClassSrc>) classes:
    | empty => none
    | link(hd, tl) => 
      if hd.name == name:
        some(hd)
      else:
        op-find-class(name, tl)
      end
  end
end


fun check-co-ntra-variance(classes :: List<C.JClassSrc>) -> Nothing:
  
  fun check-method(meth :: C.JMethodSrc, op-cla ::  Option<C.JClassSrc>) -> Nothing:
    fun help(methods :: List<C.JMethodSrc>) -> Nothing:
      cases (List<C.JMethodSrc>) methods:
        | empty => check-method(meth, op-find-class(op-cla.value.superclass, classes))
        | link(hd, tl) => 
            if hd.name == meth.name:
            check-subtype(classes, meth.ret-type, hd.ret-type)
            check-subtype(classes, hd.arg-type, meth.arg-type)
          else:
            help(tl)
          end
      end
    end
    cases (Option) op-cla:
      | none => nothing
      | some(_) => help(op-cla.value.methods) 
    end
  end
  
  fun check-field(field :: C.JFieldSrc, op-cla :: Option<C.JClassSrc>) -> Nothing:
    fun help(fields :: List<C.JFieldSrc>) -> Nothing:
      cases (List<C.JFieldSrc>) fields:
        | empty => check-field(field, op-find-class(op-cla.value.superclass, classes))
        | link(hd, tl) => 
          if hd.name == field.name:
            check-subtype(classes, field.field-type, hd.field-type)
          else:
            help(tl)
          end
      end
    end
    cases (Option) op-cla:
      | none => nothing
      | some(_) => help(op-cla.value.fields) 
    end
  end
  
  
  classes.map(lam(cla): cla.methods.map(lam(meth): check-method(meth, op-find-class(cla.superclass, classes)) end) end)
  classes.map(lam(cla): cla.fields.map(lam(field): check-field(field, op-find-class(cla.superclass, classes)) end) end)
  nothing
end



data Comp:
  | comp(ex :: C.JExpr, ty :: C.JType)
end




fun rec-compile(expr :: C.JExprSrc, dy-env :: C.TEnv, st-env :: C.TEnv, classes :: List<C.JClassSrc>, in-class :: Option<String>, dy :: Boolean) -> Comp:
  doc: "recursively compile JExprSrc data"
  cases (C.JExprSrc) expr:
      # Fields & Methods:
    | src-get-field(obj, field) => get-field-comp(obj, field, dy-env, st-env, classes, in-class, false)
    | src-set-field(obj, field, val) => set-field-comp(obj, field, val, dy-env, st-env, classes, in-class, false)
    | src-method-call(obj, meth, arg) => method-call-comp(obj, meth, arg, dy-env, st-env, classes, in-class, true)
      
      # Objects:
    | src-new(class-name :: String) =>
      find-class(class-name, classes)
      comp(C.j-new(class-name), C.t-obj(class-name))
    | src-this =>
      cases (Option<String>) in-class:
        | none => raise(C.err-this-outside-of-method)
        | some(s) => comp(C.j-this, C.t-obj(s))
      end
    | src-null(class-name :: String) => comp(C.j-null, C.t-obj(class-name))
      
      # Basic Language Stuff:
    | src-let(arg-type, arg, val, body) => let-comp(arg-type, arg, val, body, dy-env, st-env, classes, in-class, dy)
    | src-num(num) => comp(C.j-num(num), C.t-num)
    | src-plus(left, right) => plus-comp(left, right, dy-env, st-env, classes, in-class, dy)
    | src-do(exprs) => do-comp(exprs, dy-env, st-env, classes, in-class, dy)
    | src-id(var-name) =>
      if dy:
        t-lookup(var-name, dy-env)
      else:
        t-lookup(var-name, st-env)
      end
  end
end




fun find-class(name :: String, classes :: List<C.JClassSrc>) -> C.JClassSrc:
  cases (List<C.JClassSrc>) classes:
    | empty => 
      #if name == "Object":
       # C.src-class("Object")
     # else:
        raise(C.err-class-not-found(name))
      #end
    | link(hd, tl) => 
      if hd.name == name:
        hd
      else:
        find-class(name, tl)
      end
  end
end




fun find-method(name :: String, classes :: List<C.JClassSrc>, class-name :: String) -> Option<C.JFieldSrc>:
  cla = op-find-class(class-name, classes)
  cases (Option) cla:
    | none => none
    | some(c) => 
      fun help(methods :: List<C.JMethodSrc>) -> Option<C.JMethodSrc>:
        cases (List<C.JMethodSrc>) methods:
          | empty => find-method(name, classes, c.superclass)
          | link(hd, tl) => 
            if hd.name == name:
              some(hd)
            else:
              help(tl)
            end
        end
      end
      help(c.methods)
  end
end




fun find-field(name :: String, classes :: List<C.JClassSrc>, class-name :: String) -> Option<C.JFieldSrc>:
  cla = op-find-class(class-name, classes)
  cases (Option) cla:
    | none => none
    | some(c) => 
      fun help(fields :: List<C.JFieldSrc>) -> Option<C.JFieldSrc>:
        cases (List<C.JFieldSrc>) fields:
          | empty => find-field(name, classes, c.superclass)
          | link(hd, tl) => 
            if hd.name == name:
              some(hd)
            else:
              help(tl)
            end
        end
      end
      help(c.fields)
  end
end




fun get-field-comp(obj :: C.JExprSrc, field :: String, dy-env :: C.TEnv, st-env :: C.TEnv, classes :: List<C.JClassSrc>, in-class :: Option<String>, dy :: Boolean) -> Comp:
  doc: "compile get-field source code"
  obj-comp = rec-compile(obj, dy-env, st-env, classes, in-class, dy)
  if C.is-t-obj(obj-comp.ty):
    found-field = find-field(field, classes, obj-comp.ty.class-name)
    cases (Option) found-field:
      | none => raise(C.err-field-not-found(field))
      | some(f) => comp(C.j-get-field(obj-comp.ex, obj-comp.ty.class-name, field), f.field-type)
    end
  else:
    raise(C.err-non-object(obj-comp.ty))
  end
end



fun set-field-comp(obj :: C.JExprSrc, field :: String, val :: C.JExprSrc, dy-env :: C.TEnv, st-env :: C.TEnv, classes :: List<C.JClassSrc>, in-class :: Option<String>, dy :: Boolean) -> Comp:
  doc: "compile set-field source code"
  obj-comp = rec-compile(obj, dy-env, st-env, classes, in-class, dy)
  val-comp = rec-compile(val, dy-env, st-env, classes, in-class, dy)
  if C.is-t-obj(obj-comp.ty):
    found-field = find-field(field, classes, obj-comp.ty.class-name)
    cases (Option) found-field:
      | none => raise(C.err-field-not-found(field))
      | some(f) => 
        check-subtype(classes, val-comp.ty, f.field-type)
        comp(C.j-set-field(obj-comp.ex, obj-comp.ty.class-name, field, val-comp.ex), f.field-type)
    end
  else:
    raise(C.err-non-object(obj-comp.ty))
  end
end



fun method-call-comp(obj :: C.JExprSrc, meth :: String, arg :: C.JExprSrc, dy-env :: C.TEnv, st-env :: C.TEnv, classes :: List<C.JClassSrc>, in-class :: Option<String>, dy :: Boolean) -> Comp:
  doc: "compile method call source code"
  obj-comp = rec-compile(obj, dy-env, st-env, classes, in-class, dy)
  arg-comp = rec-compile(arg, dy-env, st-env, classes, in-class, dy)
  if C.is-t-obj(obj-comp.ty):
    found-method = find-method(meth, classes, obj-comp.ty.class-name)
    cases (Option) found-method:
      | none => raise(C.err-method-not-found(meth))
      | some(m) =>
        check-subtype(classes, arg-comp.ty, m.arg-type)
        comp(C.j-method-call(obj-comp.ex, m.name, arg-comp.ex), m.ret-type)
    end
  else:
    raise(C.err-non-object(obj-comp.ty))
  end
end



fun let-comp(arg-type :: C.JType, arg :: String, val :: C.JExprSrc, body :: C.JExprSrc, dy-env :: C.TEnv, st-env :: C.TEnv, classes :: List<C.JClassSrc>, in-class :: Option<String>, dy :: Boolean) -> Comp:
  doc: "compile let expressions"
  val-comp = rec-compile(val, dy-env, st-env, classes, in-class, dy)
  check-subtype(classes, val-comp.ty, arg-type)
  #I think instead this needs to be dynamic type. Think about it, or I need two environments......
  new-dy-env = link(C.t-env-cell(arg, val-comp.ty), dy-env)
  new-st-env = link(C.t-env-cell(arg, arg-type), st-env)
  body-comp = rec-compile(body, new-dy-env, new-st-env, classes, in-class, dy)
  comp(C.j-let(arg, val-comp.ex, body-comp.ex), body-comp.ty)
end




fun plus-comp(left :: C.JExprSrc, right :: C.JExprSrc, dy-env :: C.TEnv, st-env :: C.TEnv, classes :: List<C.JClassSrc>, in-class :: Option<String>, dy :: Boolean) -> Comp:
  doc: "compile plus expressions"
  left-comp = rec-compile(left, dy-env, st-env, classes, in-class, dy)
  right-comp = rec-compile(right, dy-env, st-env, classes, in-class, dy)
  if C.is-t-num(left-comp.ty):
    if C.is-t-num(right-comp.ty):
      comp(C.j-plus(left-comp.ex, right-comp.ex), C.t-num)
    else:
      raise(C.err-type-mismatch(C.t-num, right-comp.ty))
    end
  else:
    raise(C.err-type-mismatch(C.t-num, left-comp.ty))
  end
end






fun do-comp(exprs :: List<C.JExprSrc>, dy-env :: C.TEnv, st-env :: C.TEnv, classes :: List<C.JClassSrc>, in-class :: Option<String>, dy :: Boolean) -> Comp:
  doc: "compile do expressions"
  fun help(shadow exprs :: List<C.JExprSrc>, last-type :: C.JType, acc :: List<C.JExprSrc>) -> Comp:
    cases (List<C.JExprSrc>) exprs:
      | empty => comp(C.j-do(acc.reverse()), last-type)
      | link(hd, tl) =>
        hd-comp = rec-compile(hd, dy-env, st-env, classes, in-class, dy)
        help(tl, hd-comp.ty, link(hd-comp.ex, acc))
    end
  end
  help(exprs, C.t-num, empty)
end




fun t-lookup(id :: String, env :: C.TEnv) -> Comp:
  doc: "find an id in the type environment"
  cases (C.TEnv) env:
    | empty => raise(C.err-unbound-id(id))
    | link(hd, tl) =>
      if hd.name == id:
        comp(C.j-id(id), hd.var-type)
      else:
        t-lookup(id, tl)
      end
  end
end


















fun check-subtype(classes :: List<C.JClassSrc>, ty1 :: C.JType, ty2 :: C.JType) -> Nothing:
  doc: ```Ensure that ty1 is a subtype of ty2.
          If it is not, raise a type-mismatch error.```
  fun is-subclass(class-name-1, class-name-2):
    if class-name-1 == class-name-2:
      true
    else if class-name-1 == "Object":
      false
    else:
      cls-1-opt = for find(cls from classes):
        cls.name == class-name-1
      end
      cases(Option) cls-1-opt:
        | none => raise(C.err-class-not-found(class-name-1))
        | some(cls) => is-subclass(cls.superclass, class-name-2)
      end
    end
  end
  if C.is-t-num(ty1) and C.is-t-num(ty2):
    nothing
  else if C.is-t-obj(ty1) and C.is-t-obj(ty2):
    when not(is-subclass(ty1.class-name, ty2.class-name)):
      raise(C.err-type-mismatch(ty2, ty1))
    end
  else:
    raise(C.err-type-mismatch(ty2, ty1))
  end
end


















fun interp-prog(prog :: C.JProgram) -> C.JVal:
  rec-interp(prog.psvm, empty, prog.classes, none)
end









fun rec-interp(expr :: C.JExpr, env :: C.Env, classes :: List<C.JClass>, in-obj :: Option<C.JVal>) -> C.JVal:
  doc: "recursively interpret compiled code"
  cases (C.JExpr) expr:
      # Fields & Methods:
    | j-get-field(obj, class-name, field) => get-field-interp(obj, class-name, field, env, classes, in-obj)
    | j-set-field(obj, class-name, field, val) => set-field-interp(obj, class-name, field, val, env, classes, in-obj)
    | j-method-call(obj, meth, arg) => method-call-interp(obj, meth, arg, env, classes, in-obj)
      
      # Objects:
    | j-new(class-name :: String) => C.v-object(class-name, make-field-sets(class-name, classes))
    | j-this =>
      cases (Option<C.JVal>) in-obj:
          #| none => won't get here because compiler raises this-outside-of-method
        | some(v) => v
      end
    | j-null => C.v-null
      
      # Basic Language Stuff:
    | j-let(arg, val, body) => let-interp(arg, val, body, env, classes, in-obj)
    | j-num(num) => C.v-num(num)
    | j-plus(left, right) => plus-interp(left, right, env, classes, in-obj)
    | j-do(exprs) => do-interp(exprs, env, classes, in-obj)
    | j-id(var-name) => v-lookup(var-name, env)
  end
end






fun get-field-interp(obj :: C.JExpr, class-name :: String, field :: String, env :: C.Env, classes :: List<C.JClassSrc>, in-obj :: Option<C.JVal>) -> C.JVal:
  doc: "interpret compiled get-field code"
  obj-v = rec-interp(obj, env, classes, in-obj)
  if C.is-v-null(obj-v):
    raise(C.null-pointer-exception)
  else:
    field-v = find-field-set(obj-v.field-sets, false, field, class-name).fields.get-value-now(field)
    field-v
  end
end




fun find-field-set(field-sets :: List<C.FieldSet>, found :: Boolean, field :: String, class-name :: String) -> C.FieldSet:
  cases (List<C.FieldSet>) field-sets:
      #| empty => raise(C.null-pointer-exception)   shouldn't get here because compilation raises field-not-found
    | link(hd, tl) => 
      if (hd.class-name == class-name) or found:
        if hd.fields.has-key-now(field):
          hd
        else:
          find-field-set(tl, true, field, class-name)
        end
      else:
        find-field-set(tl, false, field, class-name)
      end
  end
end
        
        
        



fun set-field-interp(obj :: C.JExpr, class-name :: String, field :: String, val :: C.JExpr, env :: C.Env, classes :: List<C.JClass>, in-obj :: Option<C.JVal>) -> C.JVal:
  doc: "interpret compiled set-field code"
  obj-v = rec-interp(obj, env, classes, in-obj)
  val-v = rec-interp(val, env, classes, in-obj)
  if C.is-v-null(obj-v):
    raise(C.null-pointer-exception)
  else:
    field-set = find-field-set(obj-v.field-sets, false, field, class-name)
    field-set.fields.set-now(field, val-v)
    val-v
  end
end



fun method-call-interp(obj :: C.JExpr, meth :: String, arg :: C.JExpr, env :: C.Env, classes :: List<C.JClass>, in-obj :: Option<C.JVal>) -> C.JVal:
  doc: "interpret compiled method call code"
  
  fun help-class(shadow classes :: List<C.JClass>, name :: String) -> C.JMethod:
    cases (List<C.JClass>) classes:
        #| empty => shouldn't get here because of compiler checks
      | link(hd, tl) =>
        if hd.name == name:
          help-method(hd.methods, hd.superclass)
        else:
          help-class(tl, name)
        end
    end
  end
  
  fun help-method(methods :: List<C.JMethod>, supercl :: String) -> C.JMethod:
    cases (List<C.JMethod>) methods:
      | empty => help-class(classes, supercl)
      | link(hd, tl) =>
        if hd.name == meth:
          hd
        else:
          help-method(tl, supercl)
        end
    end
  end
  
  obj-v = rec-interp(obj, env, classes, in-obj)
  arg-v = rec-interp(arg, env, classes, in-obj)
  if C.is-v-null(obj-v):
    raise(C.null-pointer-exception)
  else:
    jmeth = help-class(classes, obj-v.class-name)
    new-env = link(C.env-cell(jmeth.arg, arg-v), env)
    rec-interp(jmeth.body, new-env, classes, some(obj-v))
  end
end

fun make-field-sets(class-name :: String, classes1 :: List<C.JClass>) -> List<C.FieldSet>:
  fun help-class(classes2 :: List<C.JClass>) -> List<C.FieldSet>:
    fun make-fields(cla :: C.JClass) -> C.FieldSet:
      fields = [D.mutable-string-dict:]
      fun add-field(field :: C.JField) -> Nothing:
        cases (C.JType) field.field-type:
          | t-num => fields.set-now(field.name, C.v-num(0))
          | t-obj(_) => fields.set-now(field.name, C.v-null)
        end
      end
      cla.fields.map(add-field)
      C.field-set(cla.name, fields)
    end
    cases (List<C.JClass>) classes2:
      | empty => empty
      | link(hd, tl) =>
        if hd.name == class-name:
          link(make-fields(hd), make-field-sets(hd.superclass, classes1))
        else:
          help-class(tl)
        end
    end
  end
  help-class(classes1) 
end

fun let-interp(arg :: String, val :: C.JExpr, body :: C.JExpr, env :: C.Env, classes :: List<C.JClass>, in-obj :: Option<C.JVal>) -> C.JVal:
  val-v = rec-interp(val, env, classes, in-obj)
  new-env = link(C.env-cell(arg, val-v), env)
  rec-interp(body, new-env, classes, in-obj)
end


fun plus-interp(left :: C.JExpr, right :: C.JExpr, env :: C.Env, classes :: List<C.JClass>, in-obj :: Option<C.JVal>) -> C.JVal:
  l-val = rec-interp(left, env, classes, in-obj)
  r-val = rec-interp(right, env, classes, in-obj)
  C.v-num(l-val.num + r-val.num)
end

fun do-interp(exprs :: List<C.JExpr>, env :: C.Env, classes :: List<C.JClass>, in-obj :: Option<C.JVal>) -> C.JVal:
  cases (List<C.JExpr>) exprs:
      #| empty => doesn't get here, no recursive call if tl is empty and parser checks that "do" isn't empty
    | link(hd, tl) => 
      hd-val = rec-interp(hd, env, classes, in-obj)
      if is-empty(tl):
        hd-val
      else:
        do-interp(tl, env, classes, in-obj)
      end
  end
end

fun v-lookup(var-name :: String, env :: C.Env) -> C.JVal:
  cases (C.Env) env:
      #| empty => shouldn't get here, compiler raises unbound-id
    | link(hd, tl) =>
      if hd.name == var-name:
        hd.val
      else:
        v-lookup(var-name, tl)
      end
  end
end














fun eval(prog-text :: String) -> C.JVal:
  interp-prog(compile(C.parse(prog-text)))
end

















