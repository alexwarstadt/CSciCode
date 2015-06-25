package mthandin.mt;
import java.io.*;


public abstract class LanguageModel {
	
	public Counter c;
	
	public abstract double theta(String word, double alpha);
	
	
	public double logP(String file, double alpha){
		double toReturn = this.first(alpha);
		try {
			BufferedReader r = new BufferedReader(new FileReader(file));
			String line = r.readLine();
			while (line != null){
				toReturn += this.logPLine(line, alpha);
				line = r.readLine();
			}
			r.close();
		} catch (IOException e) {
			System.out.println("bad input file");
		}
		return toReturn;
	}
	
	
	public double first(double alpha){
		return 0;
	}
	
	
	abstract double logPLine(String line, double alpha);
	
	
	
	public double percentRight(String file, double alpha){
		double ncorrect = 0;
		double total = 0;
		try {
			BufferedReader r = new BufferedReader(new FileReader(file));
			String line1 = r.readLine();
			String line2;
			while (line1 != null){
				total++;
				line2 = r.readLine();
				if (this.logPLine(line1, alpha) < this.logPLine(line2, alpha)){
					ncorrect++;
				}
				line1 = r.readLine();
			}
			r.close();
		} catch (IOException e) {
			System.out.println("bad file");
		}
		return (ncorrect/total);
	}
	
	public double goldenSearch(String file){
		double phi = (Math.sqrt(5) - 1)/2.0;
		double x, y;
		double a = Math.pow(10, -9);
		double b = Math.pow(10, 9);
		if (this.logP(file, a) > this.logP(file, b)){
			a = b;
			b = Math.pow(10, -9);
		}
		while (Math.abs(a-b) > .01) {
			x = b - phi * (b - a);
			y = a + phi * (b - a);
			if (this.logP(file, x) > this.logP(file, y)){
				a = x;
			} else {
				b = y;
			}
		}
		return a;
		
	}
	
	
	
	
	
	
	

}
