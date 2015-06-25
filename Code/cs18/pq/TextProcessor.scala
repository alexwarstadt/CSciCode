package hw06
import java.io.BufferedReader
import java.io.FileReader
import scala.collection.mutable.LinkedHashMap
import scala.util.control.Breaks
import java.io.IOException
import java.io.FileNotFoundException

/**
 * @constructor - creates a textprocessor
 */
class TextProcessor {
  
  /**
   * wrapper function for docStatsHelp. Prints word, #of appearances, 
   * and frequency of 10 most frequent words in inputted file
   * @param file - the path to the file containing the text to be inputted
   */
  def docStats(file : String) : Unit = {
    print(this.docStatsHelp(file))
  }
  
  
  
  
  
  
  
  
  /**
   * @param - file: the path to the file containing the text to be inputted
   * @returns - a string listing the word, #of appearances, 
   * and frequency of 10 most frequent words in file
   */
  private def docStatsHelp(file : String) : String = {
    var toReturn : String = "word\t#\tfreq"
    try {
    val r : BufferedReader = new BufferedReader(new FileReader(file))
    var text : String = ""
    var current : String = r.readLine
    while (current != null){
      text += current
      current = r.readLine()
    }
    
    var words : Array[String] = text.split("[\\s\\W]+")
    
    val table : LinkedHashMap[String, Int] = new LinkedHashMap[String, Int]()
    for (word : String <- words) {
      val v : Option[Int] = table.get(word)
      v match {
        case None => table.put(word, 1)
        case Some(n) => table.update(word, n + 1)
      }
    }
    
    val queue : PQueue[String, Int] = new PQueue[String, Int](words.length)
    for ((s, i) <- table) {
      queue.insert(s, words.length - i)
    }
    
    for (i : Int <- 0 to 9) {
      queue.deleteMin match {
        case None => return toReturn
        case Some(s) => val Some(n) = table.get(s)
        if (!s.equals("")){
          toReturn += ("\n" + s + "\t" + n + "\t" + (100 * n / words.length).toDouble/100)
        }
      }
    }
    } catch {
      case e : IOException => toReturn = "file not found"
      case e : FileNotFoundException => toReturn = "there was a problem reading the file"
    }
    return toReturn
  }
}


/**
 * testing object
 */
object TextProcessor {
  
  def main(args : Array[String]) = {
    val tp : TextProcessor = new TextProcessor
    for (file <- args){
      println()
      tp.docStats(file)
    }
    
    println(tp.docStatsHelp("src/text-samples/gettysburg") == "word\t#\tfreq\nthat\t7\t0.03\na\t6\t0.03\nwe\t6\t0.03" + 
      "\nhere\t6\t0.03\nto\t5\t0.02\ncan\t5\t0.02\nand\t5\t0.02\nnation\t4\t0.02\nin\t3\t0.01\nnot\t3\t0.01")
       
    println(tp.docStatsHelp("src/hw06/lamb.txt") == "word\t#\tfreq\nthee\t12\t0.1\nLamb\t7\t0.06\nLittle\t6\t0.05" + 
      "\na\t5\t0.04\nmade\t4\t0.03\nwho\t4\t0.03\nI\t3\t0.02\nGave\t3\t0.02\nHe\t3\t0.02\nis\t3\t0.02")
       
      
    println(tp.docStatsHelp("src/text-samples/limecoconut") == "word\t#\tfreq\nthe\t22\t0.1\nlime\t11\t0.05\nin\t11\t0.05" + 
      "\nI\t10\t0.04\ncoconut\t10\t0.04\nput\t8\t0.03\nDoctor\t8\t0.03\nand\t7\t0.03\nsay\t6\t0.02\nthem\t6\t0.02")
      
    println(tp.docStatsHelp("src/text-samples/kubla") == "word\t#\tfreq")
    
    println(tp.docStatsHelp("klkld") == "file not found")
       
       
  }
}