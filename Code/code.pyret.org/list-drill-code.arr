
### List Drill (code file) ###


provide *



fun sum-of(l :: List<Number>) -> Number:
  doc: "Find the sum of a list of numbers."
  cases (List<Number>) l:
    | empty => 0
    | link(hd, tl) => hd + sum-of(tl)
  end
end

fun<A> alternating(l :: List<A>) -> List<A>:
  doc: ```Extract every-other element from a list,
          starting with the first element. For instance,
          alternating([list: 1, 2, 3, 4]) is [list: 1, 3]```
    cases (List<A>) l: 
      | empty => empty
      | link(first, tl) =>
        cases (List<A>) tl:
          | empty => link(first, empty)
          | link(_, tltl) => link(first, alternating(tltl))
        end
    end
end

fun sum-alternating(l :: List<Number>) -> Number:
  doc: ```Sum every other number in a list,
          starting with the first element.```
  cases (List<Number>) l:
    | empty => 0
    | link(first, tl) =>
      cases (List<Number>) tl:
        | empty => first
        | link(_, tltl) => first + sum-alternating(tltl)
      end
    end
end

fun concat-alternating(l :: List<String>) -> String:
  doc: ```Concatenate together every other string in a list,
          starting with the first element.```
  cases (List<String>) l:
    | empty => ""
    | link(first, tl) =>
      cases (List<String>) tl:
        | empty => first
        | link(_, tltl) => first + concat-alternating(tltl)
      end
    end
end


# There's a "crypto" game for kids where a message is hidden among a
# bunch of red, green, and blue letters written on a white background.
# You have three color filters -- one in each color -- and when you hold
# it over the letters, the letters of that color "dissapear" because
# they blend in with the background, but the letters of the other colors
# remain visible. If you pick the right filter, the remaining visible
# letters spell out the "hidden" message.              

# Implement the two functions, `encode` and `decode`, that generate and
# decipher messages like this. `encode` should take a plaintext message
# and a color, and obfuscate the message so that it can only be revealed
# by that color. `decode` does the opposite: it takes an obfuscated
# message and a color and produces the original message. (In other words,
# `decode` says what you would see if you were to hold up a color filter
# to the message.)


data Color: Red | Green | Blue end

data Code:
  | item(letter :: String, color :: Color)
end

type Message = List<Code>

fun decode(msg :: Message, lens-color :: Color) -> String:
  cases (Message) msg:
    | empty => ""
    | link(hd, tl) => 
      cases (Color) hd.color:
        | Red => 
          cases (Color) lens-color:
            | Red => decode(tl, lens-color)
            | else => hd.letter + decode(tl, lens-color)
          end
        | Green =>
          cases (Color) lens-color:
            | Green => decode(tl, lens-color)
            | else => hd.letter + decode(tl, lens-color)
          end
        | Blue =>
          cases (Color) lens-color:
            | Blue => decode(tl, lens-color)
            | else => hd.letter + decode(tl, lens-color)
          end
      end
  end
end




fun encode(msg :: String, decoder :: Color) -> Message:
  fun encode-helper(msg1 :: List<String>) -> Message:
    cases (List<String>) msg1:
      | empty => empty
      | link(hd, tl) => 
        cases (Color) decoder:
          | Red => link(item("x", Red), link(item(hd, Green), encode-helper(tl)))
          | Green => link(item("x", Green), link(item(hd, Blue), encode-helper(tl)))
          | Blue => link(item("x", Blue), link(item(hd, Green), encode-helper(tl)))
        end
    end
  end
  encode-helper(string-explode(msg))
end











