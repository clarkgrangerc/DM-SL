library(tidyverse)
library(LICORS)
library(factoextra)
library(reshape2)
library(foreach)
library(mosaic)
library(factoextra)
data= read.csv("datacomm.csv")
data = data[,-27]

#########################################
############## PCA #####################

X= data[, -101]
X = scale(data, center = TRUE, scale = TRUE)
x_pc = prcomp(data, scale.=TRUE)
plot(x_pc)
scores = x_pc$x

fviz_pca_var(x_pc, col.var="contrib",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE, title = "Variables Contribution in first two PCAs " )



crime= data.frame(cbind(data$ViolentCrimesPerPop, scores))


n= nrow(crime)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train

logit_color = do(300)*{
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  crime_train = crime[train_cases,]
  crime_test = crime[test_cases,]
  lm1 = glm( V1 ~ ., data= crime_train, family = binomial(link = "logit"))
  
  yhat= predict(lm1, crime_test, type="response")
  
  error_rate = sqrt(mean((crime_test$V1- yhat)^2))}

errorrate = mean(logit_color$result, na.rm = FALSE)

#################################################
#################################################

n= nrow(data)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train

logit_color2 = do(300)*{
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  data_train = data[train_cases,]
  data_test = data[test_cases,]
  lm1 = glm(ViolentCrimesPerPop ~ ., data= data_train, family = binomial(link = "logit"))
  
  yhat= predict(lm1, data_test,type="response")
  
  error_rate = sqrt(mean((data_test$ViolentCrimesPerPop- yhat)^2))}

errorrate1 = mean(logit_color2$result, na.rm = FALSE)


summary(x_pc)

biplot(x_pc)
scores = x_pc$x