package finalexam

import scala.util.Sorting
import scala.collection.immutable.HashMap
import scala.collection.mutable.PriorityQueue
import scala.collection.mutable.Stack

// yay trees!
/**
 * This is a CS17-style Algebraic/Immutable BinaryTree 
 */
abstract class BinaryTree[T]
case class Node[T](zero: BinaryTree[T], one: BinaryTree[T]) extends BinaryTree[T]
case class Leaf[T](dat: T) extends BinaryTree[T]

object HuffmanTree {

  // set this to true to print out some helpful information!
  val PrintTree = false

  /**
   * generates a map from characters to their corresponding frequencies
   * in the input string
   * @param input the input string
   * @return the map from characters to frequencies for input
   */
  def countFreq(input: String): Map[Char,Int] = {
    // generate the frequency map of all the symbols that appear in input
    var count = HashMap[Char, Int]()

    for (i <- input) {
	  count.get(i) match {
	    case Some(x) => count += ((i, 1 + x))
        case None => count += ((i, 1))
	  }
    }
    
    return count
  }

  object Ord extends Ordering[(BinaryTree[Char], Int)] {
    def compare(x: (BinaryTree[Char], Int), y: (BinaryTree[Char], Int)): Int = y._2 - x._2
  }
  
  
  /**
   * Generates a prefix tree from a map of symbol frequencies.
   * @param freqmap a map from characters to positive integers
   * @return a prefix tree representing the encoding for the given characters 
   * and frequencies
   */
  def buildTree(freqmap: Map[Char,Int]): BinaryTree[Char] = {
    if (freqmap.size < 1){
      throw new IllegalArgumentException
    }
    val PQ: PriorityQueue[(BinaryTree[Char], Int)] = new PriorityQueue()(Ord)
    for ((c, i) <- freqmap){
      PQ += ((new Leaf[Char](c), i))
    }
    var t1: (BinaryTree[Char], Int) = null
    var t2: (BinaryTree[Char], Int) = null
    while (PQ.size > 1){
      t1 = PQ.dequeue
      t2 = PQ.dequeue
      PQ += ((new Node[Char](t1._1, t2._1), t1._2 + t2._2))
    }
	return PQ.dequeue._1
  }
  


  /**
   * Turns a Huffman encoding tree into a mapping from characters into their encoding
   * @param tr the encoding tree
   * @return a map from characters to their Huffman encoding 
   */
  def traverse(tr: BinaryTree[Char]): Map[Char, String] = {
    var toReturn: Map[Char, String] =  Map()
    tr match{
      case Leaf(dat) => return Map((dat, "0")) 
      case _ =>
    }
    def traverseHelper(tr: BinaryTree[Char], s: String) {
      tr match{
        case Leaf(dat) => toReturn = toReturn + ((dat, s))
        case Node(zero, one) => traverseHelper(zero, s + "0")
          traverseHelper(one, s + "1")
      }
    }
    traverseHelper(tr, "")
    return toReturn
  }

  /**
   * Makes an encoder object given the input string. This is basically glue
   * that uses the functionality you have provided in buildTree and traverse;
   * @param str the input string
   * @return the Encoder which will Huffman-encode str
   */
  def makeEncoder(str: String): Encoder = {
    // generate the huffman tree and push the bitstring into an Encoder
    val tr = buildTree(countFreq(str))
    val encodeMap = traverse(tr)

    if (PrintTree){
      encodeMap.foreach(x => println(x._1 + " => " + x._2))
    }

    // push the bitstring into an output object
    val o = new Encoder(tr)
    str.map(x => encodeMap(x).map(o.pushBit _))
    o
  }

  /**
   * wrapper that encodes a string. for detauls see makeEncoder
   * @param str the input string
   * @return the Huffman-encoded version of str
   */
  def encodeString(str: String): String = makeEncoder(str).toString

  /**
   * Tests whether encoding and subsequently decoding a string yields the original string
   * @param str the input string
   * @return true if decoding the encoded string equals the input string, false otherwise
   */
  def testTree(str: String): Boolean = {
    val encodedString = encodeString(str)
    val decodedString = (new Decoder(encodedString)).read()
    str == decodedString
  }
  
  def main(args: Array[String]) {
    
    
    //depth = 3
    var map1: Map[Char, Int] = Map(('a', 1), ('b', 4), ('c', 5), ('d', 5))
    println(buildTree(map1) == new Node(new Leaf('d'), new Node(new Leaf('c'), new Node(new Leaf('a'), new Leaf('b')))))
    println(traverse(buildTree(map1)) == Map(('d', "0"), ('c', "10"), ('a', "110"), ('b', "111")))
    
    //depth = 0
    map1 = Map()
    try {buildTree(map1)} catch {case e: IllegalArgumentException => println("true")}
    
    //depth = 1
    map1 = Map(('a', 10))
    println(buildTree(map1) == new Leaf('a'))
    println(traverse(buildTree(map1)) == Map(('a', "0")))
    
    
    println(testTree("this is a test"))
    println(testTree("thIs iS aNother tesT 1234567890)(*&^%$#@@!"))
    println(testTree("aaaaa"))
    try{
    println(testTree(""))
    }catch {case e: IllegalArgumentException => println("true")}
    
    
  }
}
