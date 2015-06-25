package mthandin.mt;
/*import java.io.*; 
import java.util.HashMap;
import java.util.Map;*/

public class Unigram extends LanguageModel {
	
	public Unigram(String file){
		this.c = new Counter(file);
	}
	
	@Override
	public double first(double alpha){
		return this.theta("***STOP***", alpha);
	}



	public double theta(String w, double alpha){
		Integer wordcode = this.c.wordToNum.get(w);
		int Nw = 0;
		if (wordcode != null){
			Nw = this.c.counts.get(this.c.wordToNum.get(w));
		}
		return (Nw + alpha)/
				(this.c.ntokens + alpha*this.c.ntypes);
	}



	
	public double logPLine(String line, double alpha){
		double toReturn = 0;
		for (String w: line.split(" ")){
			toReturn += Math.log(this.theta(w, alpha));
		}
		toReturn += Math.log(this.theta("***STOP***", alpha));
		return -1 * toReturn;
	}
	


	public static void main(String[] args){
		String training, test, goodbad, heldOut;
		Unigram u;
		if (args.length == 4){
			training = args[0];
			test = args[1];
			goodbad = args[2];
			heldOut = args[3];
			u = new Unigram(training);
			System.out.println(u.logP(test, 1));
			double alpha = u.goldenSearch(heldOut);
			System.out.println(u.logP(test, alpha));
			System.out.println(u.percentRight(goodbad, alpha));
			System.out.println(alpha);
		} else {
			System.out.println("incorrect args");
		}
	}

}
