package TopicMod;
import java.io.*;
import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class TopicMod {

	Map<Integer, String> n2w = new HashMap<Integer, String>();
	Map<String, Integer> w2n = new HashMap<String, Integer>();
	List<List<Integer>> corp = new ArrayList<List<Integer>>();
	List<List<Integer>> topics = new ArrayList<List<Integer>>();
	Map<Integer, Double[]> probs = new HashMap<Integer, Double[]>();
	Random random = new Random();
	int N = 50;
	int V;
	int C = 10;
	double alpha = .5;
	Map<Integer, Map<Integer, Integer>> Ndt = new HashMap<Integer, Map<Integer, Integer>>();
	Map<Integer, Map<Integer, Integer>> Ntw = new HashMap<Integer, Map<Integer, Integer>>(N);
	Map<Integer, Integer> Nddot = new HashMap<Integer, Integer>();
	Map<Integer, Integer> Ntdot = new HashMap<Integer, Integer>();


	public void makeCorp(String file){
		try{
			BufferedReader r = new BufferedReader(new FileReader(file));
			String line = r.readLine();
			String[] split;
			List<Integer> d=null;
			Integer wn;
			int newcode=0;
			while (line != null){
				
				split = line.split(" ");
				if (!line.startsWith(" ")&&!line.equals("")&&!line.equals(" ")){
					if (d!=null){ this.corp.add(d); }
					d = new ArrayList<Integer>();
				} else {
					for (String w: split){
						if (!w.equals("")){
							wn = this.w2n.get(w);
							if (wn == null){
								wn = newcode;
								newcode++;
								this.w2n.put(w, wn);
								this.n2w.put(wn, w);
							}
							d.add(wn);
						}
					}
				}
				line = r.readLine();
			}
			this.corp.add(d);
			this.V = newcode;
			r.close();
		} catch (IOException e){
			e.printStackTrace();
		}
	}



	public void initializeMaps(){
		
		//Ndt
		for (int d=0; d<this.corp.size(); d++){
			Map<Integer, Integer> map = new HashMap<Integer, Integer>(N);
			for (int t=0; t<N; t++){
				map.put(t,0);
			}
			this.Ndt.put(d, map);
		}
		
		//Ntw
		for (int t=0; t<N; t++){
			Map<Integer, Integer> map = new HashMap<Integer, Integer>(V);
			for (int w=0; w<V; w++){
				map.put(w,0);
			}
			this.Ntw.put(t, map);
		}
		
		//Nddot
		for (int d=0; d<this.corp.size(); d++){
			this.Nddot.put(d, 0);
		}
		
		//Ntdot
		for (int t=0; t<N; t++){
			this.Ntdot.put(t, 0);
		}
		
		//topics
		for (int d=0; d<this.corp.size(); d++){
			List<Integer> list = new ArrayList<Integer>(this.corp.get(d).size());
			for (int w=0; w<this.corp.get(d).size(); w++){
				list.add(0);
			}
			this.topics.add(list);
		}
	}






	public void gibbs(){
		this.gibbsIteration(true);
		for (int i=0; i<C-2; i++){
			this.gibbsIteration(false);
		}
		System.out.println("log likelihood = "+this.gibbsIteration(false));
	}




	public double gibbsIteration(boolean initialize){
		System.out.println("iteration");
		double loglikelihood=0;
		int d = 0;
		Integer Ndt, Nddot, Ntdot, Ntw;
		for (List<Integer> doc: this.corp){
			int pos = 0;
			List<Integer> docTops = new ArrayList<Integer>();
			for (Integer w: doc){
				double rand = this.random.nextDouble();
				double q = 0;
				double p =0;
				double pUS = 0;
				Map<Integer, Double> qs = new HashMap<Integer, Double>(N);
				int t=0;
				if (initialize){
					t = this.random.nextInt(N);
				} else{
					
					int lastT = this.topics.get(d).get(pos);
					
					Map<Integer, Integer> NdtInner, NtwInner;
					
					NdtInner = this.Ndt.get(d);
					NdtInner.put(lastT, NdtInner.get(lastT)-1);
					this.Ndt.put(d, NdtInner);
					
					NtwInner = this.Ntw.get(lastT);
					NtwInner.put(w, NtwInner.get(w)-1);
					this.Ntw.put(lastT, NtwInner);
				
					
					this.Nddot.put(d, this.Nddot.get(d)-1);
					this.Ntdot.put(lastT, this.Ntdot.get(lastT)-1);
					
					for (int top=0; top<N; top++){
						Ndt = this.Ndt.get(d).get(top);
						Ntw = this.Ntw.get(top).get(w);
						Nddot = this.Nddot.get(d);
						Ntdot = this.Ntdot.get(top);
						double Pdt = (Ndt.doubleValue() + this.alpha)/(Nddot.doubleValue() + this.N*this.alpha);
						double Ptw = (Ntw.doubleValue() + this.alpha)/(Ntdot.doubleValue() + this.V*this.alpha);
						p += Pdt*Ptw;
						qs.put(top, Pdt*Ptw);
					}
					
					loglikelihood += Math.log(p);

					for (int top=0; top<N; top++){
						q += qs.get(top)/p;
						if (q > rand){ 
							t=top; 
							break;
						}
					}
				}
				Map<Integer, Integer> NdtInner, NtwInner;
				
				NdtInner = this.Ndt.get(d);
				NdtInner.put(t, NdtInner.get(t)+1);
				this.Ndt.put(d, NdtInner);
				
				NtwInner = this.Ntw.get(t);
				NtwInner.put(w, NtwInner.get(w)+1);
				this.Ntw.put(t, NtwInner);
			
				
				this.Nddot.put(d, this.Nddot.get(d)+1);
				this.Ntdot.put(t, this.Ntdot.get(t)+1);

				
				this.topics.get(d).set(pos, t);
				//docTops.add(t);
				pos++;
			} 
			//if (initialize){ this.topics.add(docTops); }
			//else{ this.topics.set(d, docTops); }
			d++;
		}
		return loglikelihood;
	}


	public void getD(int doc){
		Map<Integer, Integer> NDt = this.Ndt.get(doc);
		Integer N17dot = this.Nddot.get(doc);
		for (int t=0; t<N; t++){
			Integer Ndt = NDt.get(t);
			if (Ndt == null){ Ndt=0; }
			System.out.println("P(T=" + t + " | D="+(doc+1)+") =\t" + 
					Ndt.doubleValue()/N17dot.doubleValue());
		}
	}




	public Map<Integer, Map<Integer, Double>> Pwt(){
		Map <Integer, Integer> Ndotw = this.Ndotw();
		Map <Integer, Map<Integer, Double>> Pwt = new HashMap<Integer, Map<Integer, Double>>();
		for (int t=0; t<N; t++){
			Map<Integer, Integer> wToNum = this.Ntw.get(t);
			Map<Integer, Double> newMap = new HashMap<Integer, Double>();
			for (Integer w: wToNum.keySet()){
				newMap.put(w, (wToNum.get(w).doubleValue() + 5)/(Ndotw.get(w).doubleValue() + N*5));
			}
			Pwt.put(t, newMap);
		}
		return Pwt;
	}

	public Map<Integer, Integer> Ndotw(){
		Map<Integer, Integer> toReturn = new HashMap<Integer, Integer>();
		for (int t=0; t<N; t++){
			Map<Integer, Integer> currMap = this.Ntw.get(t);
			for (int w: currMap.keySet()){
				Integer lastN = toReturn.get(w);
				if (lastN == null){ lastN = 0; }
				toReturn.put(w, lastN + currMap.get(w));
			}
		}
		return toReturn;
	}



	public void maxW(){
		Map<Integer, Map<Integer, Double>> Pwt = this.Pwt();
		for (int t=0; t<N; t++){
			List<Integer> best15 = new ArrayList<Integer>();
			Map<Integer, Double> wToProb = Pwt.get(t);
			for (int w: wToProb.keySet()){
				if (best15.isEmpty()){ best15.add(w); }
				else{
					Integer ww = best15.get(0);
					for (int i=0; i<15 && i<best15.size(); i++){
						if (wToProb.get(best15.get(i)) < wToProb.get(w)){
							best15.add(i, w);
							if (best15.size() > 15){ best15.remove(best15.size()-1); }
							break;
						}
					}
				}
			}
			String ws = "";
			for (int w: best15){
				ws += " " + this.n2w.get(w);
			}
			System.out.println("Topic " + t + ":" + ws);
		}
	}
	



	public static void main(String[] args){
		String data = args[0];
		TopicMod tm = new TopicMod();
		tm.makeCorp(data);
		tm.initializeMaps();
		tm.gibbs();
		tm.getD(16);
		tm.maxW();
	}







}
