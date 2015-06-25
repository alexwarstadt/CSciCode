package mthandin.mt;

public class Pair<T, S>{
	
	public T a;
	public S b;
	
	public Pair(T a, S b){
		this.a = a;
		this.b = b;
	}
	
	@Override
	public boolean equals(Object o){
		@SuppressWarnings("unchecked")
		Pair<T, S> that = (Pair<T, S>) o;
		return (this.a.equals(that.a) && this.b.equals(that.b));
	}
	
	@Override
	public int hashCode(){
		return this.a.hashCode() + this.b.hashCode();
	}
	
	@Override
	public String toString(){
		return this.a.toString() + " " + this.b.toString();
	}
}
