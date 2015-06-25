provide *
provide-types *

import shared-gdrive("type-checker-definitions.arr", "0By8FB99CQCH9dWV4R0RoRHVLTk0") as C

fun type-check(e :: String) -> C.Type:
  doc: "parses and type checks the expression"
  type-of(C.parse(e))
end

fun type-of(e :: C.Expr) -> C.Type:
  doc: "returns the type of the given expression"
  type-of-help(e, empty)
end

fun type-of-help(e :: C.Expr, nv :: C.TEnv) -> C.Type:
  doc: "do the recursive part of type-of with the updated environments"
  cases (C.Expr) e:
    | e-op(op, left, right) => op-help(op, left, right, nv)
    | e-un-op(op, expr) => un-op-help(op, expr, nv)
    | e-if(cond, consq, altern) => if-help(cond, consq, altern, nv)
    | e-let(name, expr, body) => 
      expr-type = type-of-help(expr, nv)
      type-of-help(body, link(C.type-cell(name, expr-type), nv))
    | e-lam(param, arg-type, body) =>
      return-type = type-of-help(body, link(C.type-cell(param, arg-type), nv))
      C.t-fun(arg-type, return-type)
    | e-app(func, arg) => app-help(func, arg, nv)
    | e-id(name) => lookup(name, nv)
    | e-num(value) => C.t-num
    | e-bool(value) => C.t-bool
    | e-empty(elem-type) => C.t-list(elem-type)
  end
end


fun op-help(op :: C.Operator, left :: C.Expr, right :: C.Expr, nv :: C.TEnv) -> C.Type:
  doc: "type check binary operator expressions"
  left-type = type-of-help(left, nv)
  right-type = type-of-help(right, nv)
  cases (C.Operator) op:
    | op-plus => 
      if C.is-t-num(left-type):
        if C.is-t-num(right-type):
          C.t-num
        else:
          raise(C.tc-err-bad-arg-to-op(op, right-type))
        end
      else:
        raise(C.tc-err-bad-arg-to-op(op, left-type))
      end
    | op-num-eq => 
      if C.is-t-num(left-type):
        if C.is-t-num(right-type):
          C.t-bool
        else:
          raise(C.tc-err-bad-arg-to-op(op, right-type))
        end
      else:
        raise(C.tc-err-bad-arg-to-op(op, left-type))
      end
    | op-link =>
      cases (C.Type) right-type:
        | t-list(t) => 
          if t == left-type:
            C.t-list(t)
          else:
            raise(C.tc-err-bad-arg-to-op(op, left-type))
          end
        | else => raise(C.tc-err-bad-arg-to-op(op, right-type))
      end
  end
end

fun un-op-help(op :: C.UnaryOperator, expr :: C.Expr, nv :: C.TEnv) -> C.Type:
  doc: "type check unary operator expressions"
  expr-type = type-of-help(expr, nv)
  cases (C.Type) expr-type:
    | t-list(t) =>
      cases (C.UnaryOperator) op:
        | op-first => t
        | op-rest => C.t-list(t)
        | op-is-empty => C.t-bool
      end
    | else => raise(C.tc-err-bad-arg-to-op(op, expr-type))
  end
end

fun if-help(cond :: C.Expr, consq :: C.Expr, altern :: C.Expr, nv :: C.TEnv) -> C.Type:
  doc: "type check if expressions"
  cond-type = type-of-help(cond, nv)
  if C.is-t-bool(cond-type):
    consq-type = type-of-help(consq, nv)
    altern-type = type-of-help(altern, nv)
    if consq-type == altern-type:
      consq-type
    else:
      raise(C.tc-err-if-branches(consq-type, altern-type))
    end
  else:
    raise(C.tc-err-if-got-non-boolean(cond-type))
  end
end

fun app-help(func :: C.Expr, arg :: C.Expr, nv :: C.TEnv) -> C.Type:
  doc: "type check function app expressions"
  func-type = type-of-help(func, nv)
  arg-type = type-of-help(arg, nv)
  cases (C.Type) func-type:
    | t-fun(param-type, return-type) =>
      if arg-type == param-type:
        return-type
      else:
        raise(C.tc-err-bad-arg-to-fun(func-type, arg-type))
      end
    | else => raise(C.tc-err-not-a-function(func-type))
  end
end

fun lookup(name :: String, nv :: C.TEnv) -> C.Type:
  doc: "find the value associated with the given identifier name"
  cases (C.Env) nv:
    | empty => raise(C.tc-err-unbound-id(name))
    | link(hd, tl) => 
      if hd.name == name:
        hd.var-type
      else:
        lookup(name, tl)
      end
  end
end
