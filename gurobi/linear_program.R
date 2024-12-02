install.packages('/opt/local/gurobi/810/linux64/R/gurobi_8.1-0_R_3.5.0.tar.gz')
library(gurobi)
model <- list()
model$A          <- matrix(c(1,2,3,1,1,0), nrow=2, ncol=3, byrow=T)
model$obj        <- c(1,1,2)
model$modelsense <- 'max'
model$rhs        <- c(4,1)
model$sense      <- c('<', '>')
model$vtype      <- 'B'
params <- list(OutputFlag=0)
result <- gurobi(model, params)
print('Solution:')
print(result$objval)
print(result$x)
