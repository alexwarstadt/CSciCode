package finalexam
import scala.collection.mutable.Queue

/**
 * a graph is defined by its sets of edges and vertices.
 */
class Graph() {
  
  var vertices: Set[Vertex] = Set()
  var edges: Set[Edge] = Set()
  
  /**
   * adds a new vertex to the graph
   * @param vertex, the vertex to be added
   */
  def addVertex(vertex: Vertex) {
    vertices = vertices + vertex
    for (v <- vertex.connections){
      this.addEdge(new Edge(vertex, v))
    }
  }
  
  /**
   * adds a new edge to the graph out of distinct vertices already contained in the graph
   * @param edge, the edge to be added to the graph. 
   */
  def addEdge(edge: Edge){
    if (edge.v1 == edge.v2){
      throw new IllegalArgumentException
    }
    
    edges = edges + edge
    edge.v1.connections = edge.v1.connections + edge.v2
    edge.v2.connections = edge.v2.connections + edge.v1
  }
}



object Graph {
  
  /**
   * calculates a possible exam schedule, if one exists
   * @param graph the graph of classes
   * @param source the class used as the source for the search
   * @returns None if there is no possible schedule, Some pair containing all the classes with slot one and two, respectively
   */
  def examSlot(graph: Graph, source: Vertex): Option[(Set[Vertex], Set[Vertex])] = {
    if (!graph.vertices.contains(source)){
      for (v <- graph.vertices){
      }
      throw new IllegalArgumentException
    }
    source.setSlotOne()
    val Q: Queue[Vertex] = new Queue()
    Q += source
    var u: Vertex = null
    var slotOne: Set[Vertex] = Set()
    var slotTwo: Set[Vertex] = Set()
    while (!Q.isEmpty){
      u = Q.dequeue()
      u.getSlot match {
        case 1 => slotOne = slotOne + u
        case 2 => slotTwo = slotTwo + u
      }
      for (v <- u.connections) {
        v.getSlot match {
          case 0 => u.getSlot match {
            case 1 => v.setSlotTwo()
            case 2 => v.setSlotOne()
            }
            Q += v
          case _ => if (v.getSlot == u.getSlot){
            return None
          }
        }
      }
    }
    return Some(slotOne, slotTwo)
  }
  
  def main(args: Array[String]) {
    val g = new Graph()
    val v1: Vertex = new Vertex("cs018")
    val v2: Vertex = new Vertex("cs022")
    val v3: Vertex = new Vertex("cs032")
    val v4: Vertex = new Vertex("cs173")
    val v5: Vertex = new Vertex("cs016")
    g.addVertex(v1)
    g.addVertex(v2)
    g.addVertex(v3)
    g.addVertex(v4)
    g.addVertex(v5)
    g.addEdge(new Edge(v1, v2))
    g.addEdge(new Edge(v2, v5))
    g.addEdge(new Edge(v2, v3))
    g.addEdge(new Edge(v3, v4))
    
    //There IS an acceptable schedule, 5 vertices, graph equivalent to one in assignment sheet
    println(examSlot(g, v1) == Some(Set(v1, v3, v5), Set(v2, v4)))
    
    val g1 = new Graph()
    val (v6, v7, v8, v9) = (new Vertex("v6"), new Vertex("v7"), new Vertex("v8"), new Vertex("v9"))
    g1.addVertex(v6)
    g1.addVertex(v7)
    g1.addVertex(v8)
    g1.addEdge(new Edge(v6, v7))
    g1.addEdge(new Edge(v7, v8))
    g1.addEdge(new Edge(v6, v8))
    
    //No possible schedule. Graph is three interconnected vertices.
    println(examSlot(g1, v6) == None)
    
    val g2 = new Graph()
    val (va, vb, vc, vd) = (new Vertex("va"), new Vertex("vb"), new Vertex("vc"), new Vertex("vd"))
    g2.addVertex(va)
    g2.addVertex(vb)
    g2.addVertex(vc)
    g2.addVertex(vd)
    g2.addEdge(new Edge(va, vb))
    g2.addEdge(new Edge(vb, vc))
    g2.addEdge(new Edge(vc, vd))
    g2.addEdge(new Edge(va, vd))
    
    //graph is four vertices in a "square"
    println(examSlot(g2, va) == Some((Set(va, vc), Set(vb, vd))))
    
    
    val g3 = new Graph()
    val (va3, vb3) = (new Vertex("va3"), new Vertex("vb3"))
    g3.addVertex(va3)
    
    //throws error when both vertices in edge are the same
    try{g3.addEdge(new Edge(va3, va3))}catch{case e: IllegalArgumentException => println("true") }
    
    //graph has one vertex
    println(examSlot(g3, va3) == Some((Set(va3), Set())))
    
    //throws error with source not in graph
    try{examSlot(g3, vb3)}catch{case e: IllegalArgumentException => println("true") }
  }
}