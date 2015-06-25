package mthandin.mt;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class NoisyChannel extends Decoder {

	BigramMT lm;

	public NoisyChannel(String eFile, String fFile) {

		this.em = new EM(eFile, fFile);
		this.em.converge();
		this.em.trimTAUs(new Float(.001));
		
		this.lm = new BigramMT(eFile);

		Map<Integer, Float> currMap = new HashMap<Integer, Float>();
		for (Pair<Integer, Integer> ef: this.em.TAUefs.keySet()){
			currMap = this.TAUefs.get(ef.b);
			if (currMap == null){
				currMap = new HashMap<Integer, Float>();
			}
			currMap.put(ef.a, this.em.TAUefs.get(ef));
			this.TAUefs.put(ef.b, currMap);
		}
	}

	@Override
	public List<String> decodeLine(String line) {
		String[] words = line.split(" ");
		if (words.length > 10){
			return Arrays.asList(words);
		} else {
			Integer curr;
			Map<Integer, Float> currMap;
			List<String> toReturn = new ArrayList<String>();
			String prev = "***STOP***";
			for (String w: words){

				curr = this.em.wordToNumf.get(w);
				if (curr == null){
					toReturn.add(w);
					prev = w;
				} else {
					currMap = this.TAUefs.get(curr);
					Integer maxw = null;
					float maxtau = 0;
					double currtau = 0;
					String currw;
					if (currMap != null){
						maxtau = 0;
						for (Integer i: currMap.keySet()){
							currw = this.em.numToWorde.get(i);
							if (currw == null){currw = w;}
							if (currw.equals("")){currw = "***STOP***";}
							currtau = (currMap.get(i)) * this.lm.theta(prev + " " + currw, 10.);
							if (currtau > maxtau){ 
								maxtau = (float) currtau;
								maxw = i;
							}
						}
						if (maxw != null){
							toReturn.add(this.em.numToWorde.get(maxw));
						} else {
							toReturn.add(w);
							if (!w.equals("")){prev = w;}
						}
					}

					prev = this.em.numToWorde.get(maxw);
				}
			}
			return toReturn;
		}
	}



	public static void main(String[] args) {

		NoisyChannel d = new NoisyChannel(args[0], args[1]);
		
		d.translate(args[2], "mthandin/mt/data/NoisyChannel-output");
		



	}

}
