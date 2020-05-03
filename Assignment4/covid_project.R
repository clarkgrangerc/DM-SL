library(tidyverse)
library(mosaic)
library(ggplot2)
library(class)
library(reshape2)
library(pander)
library(gamlr)
library(tidyverse)

# create a train/test split
N = nrow(covid)
N_train = floor(0.8*N)
train_ind = sample.int(N, N_train, replace=FALSE)

X_all = covid$days_since_first_infection1

# standardize the columns of covid
feature_sd = apply(X_all, 2, sd)
X_std = scale(X_all, scale=feature_sd)

# now use LOOCV across a grid of values for K
k_grid = seq(3, 51, by=2)

# loop over the individual data points for leave-one-out
loop_rmse = foreach(i = 1:N, .combine='rbind') %dopar% {
  X_train = X_all[-i,]
  X_test = X_all[i,]
  y_train = covid$cases[-i]
  y_test = covid$cases[i]
  
  # fit the models: loop over k
  knn_mse_out = foreach(k = k_grid, .combine='c') %do% {
    knn_fit = knn.reg(X_train, X_test, y_train, k)
    (y_test - knn_fit$pred)^2  # return prediction
  }
  
  # return results from the loop over k
  knn_mse_out
}



rmse = function(y, ypred) {
  sqrt(mean((y-ypred)^2))
}

k_grid = unique(round(exp(seq(log(N_train), log(2), length=100))))
rmse_grid_out = foreach(k = k_grid, .combine='c') %do% {
  knn_model = knn.reg(X_train_350, X_test_350, y_train_350, k = k)
  rmse(y_test_350, knn_model$pred)
}

rmse_grid_out = data.frame(K = k_grid, RMSE = rmse_grid_out)

# fit the model at the optimal k
knn_model = knn.reg(X_train, X_test, y_train, k = k_best)
rmse_best = rmse(y_test, knn_model$pred)