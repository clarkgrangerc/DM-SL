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

covidzach2 = read.csv('covidzach2.csv', header=TRUE)

N = nrow(covidzach2)

X_all = model.matrix(~. - cases - deaths - county - state.x - fips.x - Tests.per.100thousand -1,
                     data=covidzach2)
# standardize the columns of covid2
feature_sd = apply(X_all, 2, sd)
X_std = scale(X_all, scale=feature_sd)

#Running PCA was necessary on this data set largely because of how many rows were strongly related or correlated. This colinearity is a problem when KNN is looking for close data points, because the identical columns make points seem "further away" than they really are. 
PCAs = prcomp(X_std, scale=TRUE)

## variance plot
plot(PCAs)
summary(PCAs)

# first few pcs
round(PCAs$rotation[,1:9],2) 


PCAsforKNN = PCAs$x[,1:9] #choosing how many PCAs to use for KNN took a little tuning. I changed it around a lot to try to find a lower Out-of-sample RMSE, and found that 8 PCAs yielded the best performance.

# now use LOOCV across a grid of values for K
k_grid = seq(1, 15, by=1)

registerDoMC(cores=4) 

# loop over the individual data points for leave-one-out
loop_rmse = foreach(i = 1:N, .combine='rbind') %dopar% {
  X_train = PCAsforKNN[-i,]
  X_test = PCAsforKNN[i,]
  y_train = covidzach2$cases[-i]
  y_test = covidzach2$cases[i]
  
  # fit the models: loop over k
  knn_mse_out = foreach(k = k_grid, .combine='c') %do% {
    knn_fit = knn.reg(X_train, X_test, y_train, k)
    (y_test - knn_fit$pred)^2  # return prediction
  }
  
  # return results from the loop over k
  knn_mse_out
}


knn_rmse = sqrt(colMeans(loop_rmse))


plot(k_grid, knn_rmse, xlab = K, ylab = RMSE) #k=4

#The minimum RMSE is at k=3 with 9 PCAs, where our RMSE is 1499.

#Other methods I tried for reducing RMSE further: I found that by excluding some random columns before running PCAs, I could get slighter better RMSE, so I tried using a lasso for selecting variables to use in my KNN. This proved unfruitful because when I included the variables from the lasso process, it yielded a higher RMSE. One thing I learned from the Lasso output was that population density was seemingly the most important variable for prediction, so I even tried multiplying the population density column by five before running KNN and this still did not yield a better RMSE.








