provide *
provide-types *

import lists as L
import sets as S
import shared-gdrive("parse.arr", "0BwTSVb9gEh9-Q2xyQkFfb2VQaE0") as P

data Expr:
  | e-num(value :: Number)
  | e-bool(value :: Boolean)
  | e-op(op :: Operator, left :: Expr, right :: Expr)
  | e-if(cond :: Expr, consq :: Expr, altern :: Expr)

  | e-lam(param :: String, arg-type :: Type, body :: Expr)
  | e-app(func :: Expr, arg :: Expr)
  | e-id(name :: String)

  | e-rec(fields :: List<FieldExpr>)
  | e-lookup(rec :: Expr, field-name :: String)
  | e-extend(rec :: Expr, field-name :: String, new-value :: Expr)
  | e-with(rec :: Expr, rec-type :: Type, body :: Expr)

  | e-let(name :: String, expr :: Expr, body :: Expr)
  | e-hole
end

data FieldExpr:
  | e-field(field-name :: String, value :: Expr)
end

data Binding:
  | binding(name :: String, expr :: Expr)
end

data Operator:
  | op-plus
  | op-num-eq
end

data Type:
  | t-num
  | t-bool
  | t-fun(arg-type :: Type, return-type :: Type)
  | t-rec(field-types :: List<FieldType>)
end

data FieldType:
  | t-field(field-name :: String, field-type :: Type)
end

data CalcLocalsError:
  | err-with-not-a-record(with-type :: Type)
end

fun<A> has-duplicates(lst :: List<A>) -> Boolean:
  S.list-to-list-set(lst).to-list().length() <> lst.length()
end

fun check-binds(binds :: List<Binding>) -> List<Binding>:
  if binds.length() == 0:
    raise("Let must have at least one binding")
  else if has-duplicates(map(_.name, binds)):
    raise("Let can't have duplicate identifier names")
  else:
    binds
  end
end

fun check-params(params :: List<String>) -> List<String>:
  if has-duplicates(params):
    raise("Lambda can't have duplicate parameter names")
  else:
    params
  end
end

fun check-fields(fields :: List<FieldExpr>) -> List<FieldExpr>:
  if has-duplicates(map(_.field-name, fields)):
    raise("Record can't have duplicate field names")
  else:
    fields
  end
end

keywords = [list:
  "true", "false", "+", "num=", "if", "lam", "let", "and", "or",
  "record", "lookup", "extend", "with", "@"]

fun check-id(id :: String):
  if keywords.member(id): raise(id + " used as identifier") else: id end
end

p-id = P.p-map(check-id, P.p-id)

fun p-const(sym):
  P.p-sym(sym, nothing)
end

fun p-expr(expr):
  P.p-expect("expression", P.p-oneof([list:
        P.p-map(e-num, P.p-num),
        P.p-sym("true", e-bool(true)),
        P.p-sym("false", e-bool(false)),
        P.p-list3(e-op,
          P.p-oneof([list:
              P.p-sym("+", op-plus),
              P.p-sym("num=", op-num-eq)]),
          p-expr, p-expr),
        P.p-list4(
          lam(_, cond, consq, altern): e-if(cond, consq, altern) end,
          P.p-sym("if", nothing), p-expr, p-expr, p-expr),
        P.p-headed-list(
          lam(_, fields): e-rec(check-fields(fields)) end,
          P.p-sym("record", nothing),
          P.p-list2(e-field, p-id, p-expr)),
        P.p-list3(
          lam(_, e, f): e-lookup(e, f) end,
          P.p-sym("lookup", nothing),
          p-expr,
          p-id),
        P.p-list4(
          lam(_, e, f, v): e-extend(e, f, v) end,
          P.p-sym("extend", nothing),
          p-expr,
          p-id,
          p-expr),
        P.p-list4(
          lam(_, r, t, b): e-with(r, t, b) end,
          P.p-sym("with", nothing),
          p-expr,
          p-type,
          p-expr),
        for P.p-tuple3(_ from p-const("lam"),
                     arg from p-arg,
                    body from p-expr):
          e-lam(arg.name, arg.arg-type, body)
        end,
        for P.p-tuple3(_ from p-const("let"),
                bindings from P.p-list(p-binding),
                    body from p-expr):
          when bindings.length() <> 1:
            raise("In this assignment, all `let`s have one binding.")
          end
          e-let(bindings.get(0).name, bindings.get(0).expr, body)
        end,
        P.p-sym("@", e-hole),
        P.p-list2(e-app, p-expr, p-expr),
        P.p-map(e-id, p-id)]))(expr)
end

fun p-arg(expr):
  P.p-expect("function argument declaration",
    for P.p-list3(name from P.p-id,
                     _ from p-const(":"),
              arg-type from p-type):
      {name: name, arg-type: arg-type}
    end)(expr)
end

fun p-binding(expr):
  P.p-expect("binding for `let`",
    P.p-list2(lam(name, e): {name: name, expr: e} end,
      P.p-id, p-expr))(expr)
end

fun p-type(expr):
  P.p-expect("type", P.p-oneof([list:
        P.p-sym("Num", t-num),
        P.p-sym("Bool", t-bool),
        for P.p-headed-list(_ from P.p-sym("Record", nothing),
                            fields from P.p-list2(t-field, p-id, p-type)):
          t-rec(fields)
        end,
        for P.p-list3(arg-type from p-type,
                              _ from p-const("->"),
                    return-type from p-type):
          t-fun(arg-type, return-type)
        end
      ]))(expr)
end

fun parse(str :: String) -> Expr:
  p-expr(P.read-s-exp(str)).value
end