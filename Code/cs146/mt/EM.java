package mthandin.mt;
import java.io.*;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.ArrayList;
import java.util.List;

public class EM {
	
	List<List<Integer>> eCorpus;
	List<List<Integer>> fCorpus;
	
	Map<Pair<Integer, Integer>, Float> Nefs = 
			new HashMap<Pair<Integer, Integer>, Float>();
	
	Map<Pair<Integer, Integer>, Float> TAUefs = 
			new HashMap<Pair<Integer, Integer>, Float>();
	
	Map<Integer, Float> Nedots = new HashMap<Integer, Float>();
	
	Map<Integer, String> numToWorde = new HashMap<Integer, String>();
	
	Map<String, Integer> wordToNume = new HashMap<String, Integer>();
	
	Map<Integer, String> numToWordf = new HashMap<Integer, String>();
	
	Map<String, Integer> wordToNumf = new HashMap<String, Integer>();
	
	double lastpk = 1;
	
	double currpk = 2;
	
	
	
	
	
	public EM(String eFile, String fFile){

		this.wordToNume.put("", 0);
		this.numToWorde.put(0, "");
		try{
			String file = eFile;
			Map<Integer, String> n2w = this.numToWorde;
			Map<String, Integer> w2n = this.wordToNume;
			Integer nextCode;
			Integer currCode;
			String[] words;
			for (int i=0; i<2; i++){
				List<List<Integer>> lines = new ArrayList<List<Integer>>();
				BufferedReader r = new BufferedReader(new FileReader(file));
				nextCode = 1;
				String line = r.readLine();
				while (line != null){
					words = line.split(" ");
					List<Integer> integers = new ArrayList<Integer>(words.length);
					if (i == 0){integers.add(0);}
					for (String w: words){
						currCode = w2n.get(w);
						if (currCode == null){
							w2n.put(w, nextCode);
							n2w.put(nextCode, w);
							currCode = nextCode;
							nextCode++;
						}
						integers.add(currCode);
					}
					lines.add(integers);
					line = r.readLine();
				}
				if (i == 0){ this.eCorpus = lines; } 
				else { this.fCorpus = lines; }
				r.close();
				file = fFile;
				n2w = this.numToWordf;
				w2n = this.wordToNumf;
			}
		} catch (IOException e){
			System.out.println("file not found");
		}
	}
	
	
	public class EFSentence {
		
		List<Integer> e;
		List<Integer> f;
		
		public EFSentence(List<Integer> e, List<Integer> f){
			this.e = e;
			this.f = f;
		}
		
		public void eStep(){
			float pk = 0;
			Float Nef;
			Float TAUef;
			//Float Nedot;
			Pair<Integer, Integer> ef;
			for (Integer k: this.f){
				for (Integer j: this.e){
					ef = new Pair<Integer, Integer>(j, k);
					TAUef = TAUefs.get(ef);
					if (TAUef == null){
						TAUef = new Float(1);
					}
					pk += TAUef;
				}
				for (Integer j: this.e){
					ef = new Pair<Integer, Integer>(j, k);
					Nef = Nefs.get(ef);
					TAUef = TAUefs.get(ef);
					//Nedot = Nedots.get(e);
					if (Nef == null){
						Nef = new Float(0);
					} if (TAUef == null){
						TAUef = new Float(1);
					//} if (Nedot == null){
						//Nedot = 0.;
					}
					Nef += TAUef/pk;
					Nefs.put(ef, Nef);
					//Nedots.put(j, Nedot + Nef);
				}
				currpk += Math.log(pk);
				pk = 0;
			}
		}
		
	}
	
	public void eStep(){
		Iterator<List<Integer>> e = eCorpus.iterator();
		Iterator<List<Integer>> f = fCorpus.iterator();
		EFSentence ef;
		while (e.hasNext() && f.hasNext()){
			ef = new EFSentence(e.next(), f.next());
			ef.eStep();
		}
	}
	
	public void mStep(){
		for (Pair<Integer, Integer> ef: this.Nefs.keySet()){
			Float nedot = this.Nedots.get(ef.a);
			if (nedot == null){ nedot = new Float(0); }
			nedot += this.Nefs.get(ef);
			this.Nedots.put(ef.a, nedot);
		}
		for (Pair<Integer, Integer> ef: this.Nefs.keySet()){
			this.TAUefs.put(ef, this.Nefs.get(ef)/this.Nedots.get(ef.a));
		}
	}
	
	public void converge(){
		while (Math.abs(1 - currpk/lastpk) > .01){
			System.out.println("converge");
			System.out.println(Math.abs(1 - currpk/lastpk));
			lastpk = currpk;
			currpk = 0;
			this.Nefs.clear();
			this.Nedots.clear();
			this.eStep();
			this.mStep();
		}
	}
	
	public static <V, K> void writeTable(Map<K, V> m, BufferedWriter w){
		String line;
		for (K k: m.keySet()){
			line = k.toString() + " " + m.get(k).toString() + "\n";
			try {
				w.write(line);
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public void trimTAUs(Float threshold){
		
		for (Pair<Integer, Integer> ef: this.Nefs.keySet()){
			if (this.TAUefs.get(ef) < threshold){
				this.TAUefs.remove(ef);
			}
		}
	}
	
	public void readTable(String file){
		try {
			BufferedReader r = new BufferedReader(new FileReader(file));
			String line = r.readLine();
			String[] parts;
			while (line != null){
				parts = line.split(" ");
				this.TAUefs.put(new Pair<Integer, Integer>(
						Integer.parseInt(parts[0]), Integer.parseInt(parts[1])), 
						Float.parseFloat(parts[2]));
				line = r.readLine();
			}
			r.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
	}
	

	public static void main(String[] args) {
		
		EM em = new EM(args[0], args[1]);
		
		em.converge();
		
		try {
			
			BufferedWriter TAUef = new BufferedWriter(new FileWriter("mt/data/TAUefs00001"));
			em.trimTAUs(new Float(.00001));
			writeTable(em.TAUefs, TAUef);
			
			TAUef.close();
			
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		em = new EM(args[1], args[0]);
		
		em.converge();
		
		try {
			
			BufferedWriter TAUef = new BufferedWriter(new FileWriter("mt/data/TAUfes00001"));
			
			em.trimTAUs(new Float(.00001));
			
			writeTable(em.TAUefs, TAUef);
			
			TAUef.close();
			
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		

	}

}
