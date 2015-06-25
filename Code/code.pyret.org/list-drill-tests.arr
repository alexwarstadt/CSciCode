
### List Drill (test file) ###                                                  

import sum-of, alternating, sum-alternating, concat-alternating, decode, encode, item, Red, Green, Blue from my-gdrive("list-drill-code.arr")


# Write test cases for the 6 functions in the List Drill code file.
# See that file for descriptions of the functions and what they should
# do.

# For `encode` and `decode`:
# Notice that while there's only one way to decode a message, there
# are *many* ways to encode it. So make sure to test `encode` in a way
# that doesn't depend on exactly how your implementation works.

check "sum-of tests":
  sum-of([list: 1, 2]) is 3
  sum-of(empty) is 0 #base case
  sum-of([list: 10]) is 10 #single elt list
  sum-of([list: 1.1, 2.2, 3.3, 4.4, 5.5]) is 16.5 #non-integers
  sum-of([list: -1, 1, -1, 1]) is 0 #negatives
end

check "alternating tests":
  alternating(empty) is empty #base case
  alternating([list: 1]) is [list: 1] #single elt list
  alternating([list: "a", "b"]) is [list: "a"] #single elt output, list<String>
  alternating([list: 1, 2, 3, 4, 5, 6]) is [list: 1, 3, 5] #even # of elts
  alternating([list: [list: 1], [list: 2], [list: 3], [list: 4], [list: 5]]) is [list: [list: 1], [list: 3], [list: 5]] #odd # of elts, List<List>
end

check "sum-alternating tests":
  sum-alternating(empty) is 0 #base case
  sum-alternating([list: 1]) is 1 #single elt list
  sum-alternating([list: 1, 2]) is 1 #single elt output, list<String>
  sum-alternating([list: 1.1, 2.2, 3.3, 4.4, 5.5, 6.6]) is 9.9 #even # of elts, non-integer
  sum-alternating([list: -1, 2, -3, 4, -5]) is -9 #odd # of elts, negative
end

check "concat-alternating tests":
  concat-alternating(empty) is "" #base case
  concat-alternating([list: "a"]) is "a" #single elt list
  concat-alternating([list: "a", "b"]) is "a" #two elt list
  concat-alternating([list: "a", "b", "c", "d"]) is "ac" #even # elts
  concat-alternating([list: "a", "b", "c", "d", "e"]) is "ace" #odd # elts 
end

check "decode tests":
  decode(empty, Red) is "" #base case
  decode([list: item("h", Red), item("i", Red)], Red) is "" #only one color, matches lens-color
  decode([list: item("h", Red), item("i", Red)], Blue) is "hi" #lens-color not contained in non-empty msg
  decode([list: item("h", Red), item("i", Green)], Blue) is "hi" #lens-color not contained in non-empty msg, two colors
  decode([list: item("x", Blue), item("h", Green), item("i", Red), item("y", Blue)], Blue) is "hi" #multiple colors in msg, matches to lens-color at beginning and end of msg
  decode([list: item("h", Blue), item("x", Green), item("y", Green), item("i", Red)], Green) is "hi" #multiple colors in msg, matches to lens-color msg-medial
  decode([list: item("a", Red)], Red) is "" #one elt msg, matches lens-color
  decode([list: item("a", Red)], Blue) is "a" #one elt msg, doesn't match lens-color
end

check "encode tests":
  decode(encode("", Red), Red) is "" #empty message
  decode(encode("", Red), Blue) is "" #empty message
  decode(encode("h", Red), Red) is "h" #encode string of length 1
  decode(encode("hello", Red), Red) is "hello" #longer message
end
