package mthandin.mt;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.HashMap;


public class VeryDumb extends Decoder {


	public VeryDumb(){
		
	}
	
	public void MkVeryDumb(String eFile, String fFile) {
		
		this.em = new EM(fFile, eFile);
		this.em.converge();
		this.em.trimTAUs(new Float(.001));
		
		Map<Integer, Float> currMap = new HashMap<Integer, Float>();
		for (Pair<Integer, Integer> fe: this.em.TAUefs.keySet()){
			currMap = this.TAUefs.get(fe.a);
			if (currMap == null){
				currMap = new HashMap<Integer, Float>();
			}
			currMap.put(fe.b, this.em.TAUefs.get(fe));
			this.TAUefs.put(fe.a, currMap);
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
			for (String w: words){

				curr = this.em.wordToNume.get(w);
				if (curr == null){
					toReturn.add(w);
				} else {
					currMap = this.TAUefs.get(curr);
					Integer maxw = null;
					if (currMap != null){
						float maxtau = 0;
						for (Integer i: currMap.keySet()){
							if (currMap.get(i) > maxtau){ 
								maxtau = currMap.get(i);
								maxw = i;
							}
						}
						if (maxw != null){
							toReturn.add(this.em.numToWordf.get(maxw));
						} else {
							toReturn.add(w);
						}
					}
				}
			}
			return toReturn;
		}
	}



	public static void main(String[] args) {
		
		VeryDumb d = new VeryDumb();
		
		if (args.length == 3){
			d.MkVeryDumb(args[0], args[1]);
			d.translate(args[2], "mthandin/mt/data/VeryDumb-output");
		}
		if (args.length == 2){
			System.out.println(d.fScore(args[0], args[1]));
		}

		

		

		System.out.println("main");
		System.out.println();


	}

}
