static global void array(
int* input,
const unsigned int input_size)
{
unsigned int index = blockIdx.x * blockDim.x + threadIdx.x;

while (index < input_size)
{
input[index] = 1 // apply something on the array
index += blockDim.x * gridDim.x;
}
}