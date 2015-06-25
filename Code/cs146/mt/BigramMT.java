package mthandin.mt;


public class BigramMT extends LanguageModel {

	Counter c;
	Unigram u;
	double alpha = 1.6;
	double beta = 100.;

	public BigramMT(String train){
		this.u = new Unigram(train);
		this.c = this.u.c;
		this.c.getBicounts();
	}

	@Override
	public double theta(String word, double dummy) {
		String w1 = word.split(" ")[0];
		String w2 = word.split(" ")[1];
		Integer w1num = c.wordToNum.get(w1);
		Integer w2num = c.wordToNum.get(w2);
		Integer nbi, nw1dot;
		if (w1num == null){
			nbi = 0;
			nw1dot = 0;
		} else {
			nw1dot = c.counts.get(w1num);
			if (w1num.equals(-1)){
				nw1dot--;
			}
			if (w2num == null){
				nbi = 0;
			} else {
				Counter.Bi bi = c.new Bi(w1num, w2num);
				nbi = c.bicounts.get(bi);
				
				if (nbi == null){
					nbi = 0;
				}
			} 
		}
		double thetaw2 = u.theta(w1, this.alpha);
		return (nbi + (beta * thetaw2))/(nw1dot + beta);
	}

	@Override
	double logPLine(String line, double beta) {
		double toReturn = 0;
		String[] words = line.split(" ");
		String w1 = "***STOP***";
		int i = 0;
		while (i < words.length){
			toReturn += Math.log(this.theta(w1 + " " + words[i], beta));
			w1 = words[i];
			i++;
		}
		return -1 * toReturn;
	}

	public static void main(String[] args) {
	}




}
