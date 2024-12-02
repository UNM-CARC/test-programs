#include <stdio.h>
#include <stdlib.h>

void random_data( float *buffer, unsigned int size, int min, int max )
{
  int i;
  for( i = 0; i < size; i=i+1 )
    buffer[i]= min+((float)rand()/RAND_MAX)*(max-min);
}

void print_vector( float* buffer, unsigned int size )
{
  int i;
  for( i=0; i<size; i=i+1 )
    {
      printf("%d=%f\n", i, buffer[i]);
    }
  printf("\n");

}

void main()
{
  int vector_size = 10;
  unsigned int num_bytes = vector_size * sizeof(float);
  float *input_a = 0;
  input_a = (float *)malloc(num_bytes);
  
  random_data(input_a, vector_size, 5, 30);

  print_vector( input_a, vector_size );

}
