#include "PBGLGraph.hpp"
// Construct a graph with the vertices container as a vector

int main()
{
  //Create a graph
  Graph<VertexProperties, EdgeProperties> g;

  const VertexProperties Bob("Bob");

  g.AddVertex(Bob);

  // Program completed
  return 0;
}
