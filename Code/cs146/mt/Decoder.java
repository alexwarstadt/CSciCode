package mthandin.mt;

import java.util.Map;
import java.util.List;
import java.util.HashMap;
import java.io.*;
import langmod.*;

public abstract class Decoder {

	Map<Integer, Map<Integer, Float>> TAUefs = 
			new HashMap<Integer, Map<Integer, Float>>();
	
	EM em;



	public abstract List<String> decodeLine(String line);

	public void translate(String file, String output){
		try{
			BufferedReader r = new BufferedReader(new FileReader(file));
			BufferedWriter w = new BufferedWriter(new FileWriter(output));
			String line = r.readLine();
			List<String> tr;
			while (line != null){
				tr = this.decodeLine(line);
				for (String word: tr){
					w.write(word + " ");
				}
				w.write("\n");
				line = r.readLine();
			}
			r.close();
			w.close();
		} catch (IOException e){
			System.out.println("decoder.translate: problem with file");
		}
	}

	public double fScore(String translation, String actual){

		double nCorrect = 0;
		double nTotal = 0;
		double nShould = 0;

		try{
			BufferedReader tr = new BufferedReader(new FileReader(translation));
			BufferedReader ac = new BufferedReader(new FileReader(actual));
			String trline = tr.readLine();
			String acline = ac.readLine();
			String[] trwords;
			String[] acwords;
			boolean found = false;
			int i = 0;
			int j = 0;
			while (trline != null && acline != null){
				trwords = trline.split(" ");
				acwords = acline.split(" ");
				if (trwords.length < 11){
					nTotal += trwords.length;
					nShould += acwords.length;
					for (String w: trwords){
						i = 0;
						while (!found && i < acwords.length){
							if (acwords[i].equals(w)){
								nCorrect++;
								found = true;
							} else {
								i++;
							}
						}
						found = false;
					}
				}
				trline = tr.readLine();
				acline = ac.readLine();
			}
			tr.close();
			ac.close();
		} catch (IOException e){
			System.out.println(e.getStackTrace());
		}

		return 2 * (nCorrect/nTotal) * (nCorrect/nShould) / 
				((nCorrect/nTotal) + (nCorrect/nShould));

	}



}
