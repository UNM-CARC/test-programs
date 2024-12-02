// OpenMP program to print Hello World
  
// OpenMP header
#include <omp.h>
  
#include <stdio.h>
#include <stdlib.h>
  
int main(int argc, char* argv[])
{
  
  // Beginning of parallel region
  #pragma omp parallel
  {
  
  printf("Hello World from thread %d of %d\n", omp_get_thread_num(), omp_get_max_threads() );
  }
  // Ending of parallel region
}
