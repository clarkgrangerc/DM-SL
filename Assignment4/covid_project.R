library(tidyverse)
library(mosaic)
library(ggplot2)
library(class)
library(reshape2)
library(pander)
library(gamlr)
library(tidyverse)
library(foreach)
library(doMC)  # for parallel computing
library(FNN)

N = nrow(covidZach)


X_all = model.matrix(~. - cases - deaths - county - state.x - fips.x - 1,
                     data=covidZach)

# standardize the columns of covid2
feature_sd = apply(X_all, 2, sd)
X_std = scale(X_all, scale=feature_sd)

PCAs = prcomp(X_std, scale=TRUE)

## variance plot
plot(PCAs)
summary(PCAs)

# first few pcs
round(PCAs$rotation[,1:3],2) 


PCAsforKNN = PCAs$x[,1:8] #choosing how many PCAs to use for KNN took a little tuning. I changed it around a lot to try to find a lower Out-of-sample RMSE, and found that 8 PCAs yielded the best performance.

# now use LOOCV across a grid of values for K
k_grid = seq(1, 15, by=1)

registerDoMC(cores=4) 

# loop over the individual data points for leave-one-out
loop_rmse = foreach(i = 1:N, .combine='rbind') %dopar% {
  X_train = PCAsforKNN[-i,]
  X_test = PCAsforKNN[i,]
  y_train = covidZach$cases[-i]
  y_test = covidZach$cases[i]
  
  # fit the models: loop over k
  knn_mse_out = foreach(k = k_grid, .combine='c') %do% {
    knn_fit = knn.reg(X_train, X_test, y_train, k)
    (y_test - knn_fit$pred)^2  # return prediction
  }
  
  # return results from the loop over k
  knn_mse_out
}


knn_rmse = sqrt(colMeans(loop_rmse))


plot(k_grid, knn_rmse) #k=4

#The minimum RMSE is at k=4, where our RMSE is 1362








