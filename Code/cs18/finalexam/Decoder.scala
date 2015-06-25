package finalexam

/**
 * This class decodes a huffman-coded string created by an Encoder
 */
class Decoder(encodedString: String) {
  val in: Iterator[Char] = encodedString.iterator
  val tree: BinaryTree[Char] = parse(in)
  var charsleft: Int = getPipeDelimitedNumber(in)
  var bitcountdown: Int = getPipeDelimitedNumber(in)
  val advanceOnBit: Int = bitcountdown
  var bitbuf: Int = 0

  /**
   * eats a bit from a character iterator, advancing the bit buffer.
   * @param it character iterator for an encoded string
   * @return an optional integer indicating the bit in the string
   */
  def nextBit(it: Iterator[Char]): Option[Int] = {
    if (charsleft <= 0 && bitcountdown <= 0) {
      None
    } else {
      if (bitcountdown == advanceOnBit && !it.isEmpty) {
        bitbuf = it.next.toInt
        if (charsleft > 0) {
          charsleft -= 1
          bitcountdown += 7
        }
      }
      bitcountdown -= 1
      bitbuf <<= 1
      Some((bitbuf & 0x80) >> 7)
    }
  }

  /**
   * next layer up of abstraction for nextBit, decodes a character given an encoding
   * given in tr
   * @param it an iterator over the characters of the input string
   * @param tr a BinaryTree including the huffman encoding
   * @return a new integer indicating the data for the corresponding string if it exists.
   */
  def nextChar(it: Iterator[Char], tr: BinaryTree[Char]): Option[Int] = {
    tr match {
      case Leaf(ch) => Some(ch)
      case Node(zero, one) => 
      nextBit(it) match {
        case Some(1) => nextChar(it, one)
        case Some(0) => nextChar(it, zero)
        case _ => None
      }
    }
  }

  /**
   * parses the input string iterator
   * @return a decoding of the input string
   */
  def read(): String = {
    val it: Iterator[Char] = in
    var ret = ""
    var ch = nextChar(it, tree)

    while (ch != None) {
      ch match { 
        case Some(c) => ret += c.toChar 
        case _ => println("Error in HuffmanTree.DecodeObject.eatString.")
      }

      ch = nextChar(it, tree)
    }

    ret
  }

  /**
   * parses the huffman encoding at the start of the string
   * @param it an iterator over the characters of the input string
   * @return a BinaryTree representing the huffman encoding
   */
  def parse(it: Iterator[Char]): BinaryTree[Char] = {
    it.next match {
      case 'n' => new Node(parse(it), parse(it))
      case 'l' => new Leaf(it.next)
    }
  }
  
  /**
   * helper method to find a pipe delimiter  (the first one)
   * @param it an iterator over the characters of the input string
   * @return the index of the pipe delimiater 
   */
  def getPipeDelimitedNumber(it: Iterator[Char]): Int = {
    var ret: Int = 0
    var ch: Char = it.next
    while (ch != '|') {
      ret = ret * 10 + (ch.toInt - 48)
      ch = it.next
    }

    ret
  }
}
