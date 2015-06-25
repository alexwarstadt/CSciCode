package finalexam

/**
 * This is a data structure which allows you to build up
 * characters into strings in the huffman encoding. It handles all the bit-level arithmetic
 */
class Encoder(tr: BinaryTree[Char]) {
  var out: String = ""
  var bitbuf: Int =  0
  var bitcount: Int =  0
  var charcount: Int =  0

  /**
   * adds a 1 or 0 to a given character, appends it to out if necessary
   * @param  ch the input character
   */
  def pushBit(ch: Char) {
    bitbuf = (bitbuf << 1) +
    (ch match {
        case '0' => 0
        case '1' => 1
      })

    bitcount  += 1

    if (bitcount == 7) {
      out += bitbuf.toChar
      bitbuf   = 0
      bitcount = 0
      charcount += 1
    }
  }

  /**
   * generates a string from the input binary tree
   * @param tr the Binary tree that is being encoded
   */
  def treeString(tr: BinaryTree[Char]): String = {
    tr match {
      case Node(left, right) => "n" + treeString(left) + treeString(right)
      case Leaf(dat) => "l" + dat
    }
  }

  override def toString(): String =
    (treeString(tr) + charcount + "|" + bitcount + "|") +
    out + (bitbuf << (7 - bitcount)).toChar
}

