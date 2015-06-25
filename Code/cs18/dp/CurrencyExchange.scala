package hw07

/**
 * @constructor for a CurrencyExchange with a preset table of exchange rates
 * @param rates - the table of exchange rates. Must be square and at least 1x1
 */
class CurrencyExchange(rates: Array[Array[Double]]) {
  
  if (rates.size < 1){
    throw new IllegalArgumentException
  }
  for (x <- rates){
    if(x.size != rates.size){
      throw new IllegalArgumentException
    }
  }
  
  //the array that holds the optimal sequences
  var seqs: Array[Array[Int]] = null
  
  
  
  
  /**
   * finds the greatest value that can be accrued after some number of transactions given
   * the exchange rates and starting value
   * @param initWesels - the starting value
   * @param numTrans - the number of transactions to be performed
   * @returns the maximum value after numTrans transactions starting with initWesels
   */
  def maxAmount(initWesels: Double, numTrans: Int): Double = {
    
    if (numTrans < 0 || initWesels < 0){
      throw new IllegalArgumentException
    }else if (numTrans == 0){
      return initWesels
    }
    
    val maxVals: Array[Array[Double]] = Array.ofDim[Double](numTrans + 1, rates.size)
    for (j <- 0 to numTrans){
      for (i <- 0 to rates.size - 1){
        maxVals(j)(i) = Double.NegativeInfinity
      }
    }

    seqs = Array.ofDim[Int](numTrans + 1, rates.size)
    
    maxVals(0)(0) = initWesels
    
    for (n <- 1 to numTrans){
      for (i <- 0 to rates.size - 1){
        for (j <- 0 to rates.size - 1){
          if (maxVals(n)(i) < rates(j)(i) * maxVals(n - 1)(j)){
            maxVals(n)(i) = rates(j)(i) * maxVals(n - 1)(j)
            seqs(n)(i) = j
          }
        }
      }
    }
    return maxVals(numTrans)(0)
  }
  
  
  
  
  
  
  
  /**
   * finds the optimal sequence of transactions of a given length, also given starting value and exchange rates
   * @param initWesels - the starting value
   * @param numTrans - the number of transactions to be performed
   * @returns a list containing the indices in the exchange rates tables of the sequence of currencies
   */
  def currencyPath(initWesels: Double, numTrans: Int): List[Int] = {
    var seq: List[Int] = List[Int]()
    
    this.maxAmount(initWesels, numTrans)
    
    var j: Int = 0
    for (i <- numTrans to 0 by -1){
      seq = j :: seq
      j = seqs(i)(j)
    }
    return seq
  }
  
}



/**
 * testing
 */
object CurrencyExchange {
  
  def main(args: Array[String]) {
    val ce: CurrencyExchange = new CurrencyExchange(Array(Array(1, .66, .77), Array(1.53, 1, 1.16), Array(1.3, .86, 1)))
    
    println(ce.maxAmount(100, 10) == (104.99698581288004))
    println(ce.currencyPath(100, 10) == List(0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0))
    println(ce.maxAmount(100, 3) == 101.3166)
    println(ce.currencyPath(100, 3) == List(0, 2, 1, 0))		//sequence involves all three currencies
    println(ce.currencyPath(100, 9) == List(0, 1, 0, 2, 1, 0, 1, 0, 1, 0))		//sequence does not involve repeating same pattern
    
    
    val ce1: CurrencyExchange = new CurrencyExchange(Array(Array(.9, .66, .77, .2), Array(.53, .89, .16, .9), Array(.3, .86, .31, .87), Array(.56, .34, .34, .23)))
    println(ce1.maxAmount(100, 20) == 12.157665459056936)		//value cannot increase
    println(ce1.maxAmount(0, 5) == 0)		//start with 0
    println(ce1.currencyPath(0, 5) == List(0, 0, 0, 0, 0, 0))		//start with 0
    println(ce1.maxAmount(100, 0) == 100)		//0 transactions
    println(ce1.currencyPath(100, 0) == List(0))		//0 transactions
    try{
      println(ce1.maxAmount(-1, 5))		//negative input value
    } catch {
      case e: IllegalArgumentException => println("true")		//negative input value
    }
    try{
      println(ce1.currencyPath(-1, 5))
    } catch {
      case e: IllegalArgumentException => println("true")
    }
    
    try{
    val ce0: CurrencyExchange = new CurrencyExchange(Array())		//rates table is empty
    } catch {
      case e: IllegalArgumentException => println("true")
    }
    
    try{
    val ce0: CurrencyExchange = new CurrencyExchange(Array(Array(2, 3, 4)))		//rates table is not square
    } catch {
      case e: IllegalArgumentException => println("true")
    }
  }
  
  
}