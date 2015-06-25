package mthandin.mt;
import java.io.*; 
import java.util.HashMap;
import java.util.Map;


public class Counter {

	public String file;

	public Map<Integer, Integer> counts = new HashMap<>();

	public Map<Integer, String> numToWord = new HashMap<>();

	public Map<String, Integer> wordToNum = new HashMap<>();

	public Map<Bi, Integer> bicounts;

	public int ntokens = 0;

	public int ntypes = 2;

	public Counter(String file){
		try {
			this.file = file;
			FileReader input = new FileReader(this.file);
			BufferedReader r = new BufferedReader(input);
			this.counts = new HashMap<>();
			String curr = r.readLine();
			String[] currArray;
			Integer newcode = 0;
			Integer currcode;
			this.wordToNum.put("***STOP***", -1);
			this.numToWord.put(-1, "***STOP***");
			this.counts.put(-1, 1);
			this.ntokens++;
			while (curr != null){
				currArray = curr.split(" ");
				for(String word : currArray){
					this.ntokens++;
					currcode = this.wordToNum.get(word);
					if (currcode == null) {
						this.ntypes++;
						this.counts.put(newcode, 1);
						this.wordToNum.put(word, newcode);
						this.numToWord.put(newcode, word);
						newcode++;
					} else {
						this.counts.put(currcode, this.counts.get(currcode) + 1);
					}
				}
				this.counts.put(-1, this.counts.get(-1) + 1);
				this.ntokens++;
				curr = r.readLine();
			}
			r.close();
		} catch (FileNotFoundException e) {
			System.out.println("File not found");
		} catch (IOException e) {
			System.out.println("IO Exception");
		}
	}
	
	public class Bi{
		
		public Integer w1;
		public Integer w2;
		
		public Bi(Integer w1, Integer w2){
			this.w1 = w1;
			this.w2 = w2;
		}
		
		@Override
		public boolean equals(Object o){
			Bi that = (Bi) o;
			return (this.w1.equals(that.w1) && this.w2.equals(that.w2));
		}
		
		@Override
		public int hashCode(){
			return this.w1.hashCode() + this.w2.hashCode();
		}
	}

	public void getBicounts(){
		try{
			this.bicounts = new HashMap<>();
			BufferedReader r = new BufferedReader(new FileReader(file));
			String line = r.readLine();
			String[] words;
			Integer w1, w2;
			w1 = -1;
			Integer currCount;
			Bi curr;
			while (line != null){
				words = line.split(" ");
				for (String word: words){
					w2 = this.wordToNum.get(word);
					curr = new Bi(w1, w2);
					currCount = this.bicounts.get(curr);
					if (currCount == null){
						currCount = 0;
					} 
					this.bicounts.put(curr, currCount + 1);
					w1 = w2;
				}
				w2 = -1;
				curr = new Bi(w1, w2);
				currCount = this.bicounts.get(curr);
				if (currCount == null){
					currCount = 0;
				}
				this.bicounts.put(curr, currCount + 1);
				w1 = w2;
				line = r.readLine();
			}
			r.close();
		} catch (IOException e){
			System.out.println("problem with file");
		}
	}
}


