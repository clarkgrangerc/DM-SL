library(mosaic)
library(tidyverse)
library(Metrics)
library(gamlr)
library(margins)
library(rpart)
library(caret)
library(knitr)
library(kableExtra)
library(randomForest)
library(gbm)
library(plotmo)
library(xtable)

data=read.csv("covid2zargham.csv")
names=read.table("names.txt")
cnames=names[,1] 
colnames(data)=cnames
#### Create the subsample for training an testing ####
x<- data[-c(1:5,35)]



## Random Forest and Boosting Trees

data=read.csv("covid2zargham.csv")
names=read.table("names.txt")
cnames=names[,1] 
colnames(data)=cnames


#### Create the subsample for training an testing ####
x<- data[-c(1:5,35)]
n = nrow(x)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train
# re-split into train and test cases with the same sample sizes
train_cases = sample.int(n, n_train, replace=FALSE)
test_cases = setdiff(1:n, train_cases)
x_train = x[train_cases,]
x_test = x[test_cases,]

######################################
############ Random Forest ###########
######################################
n = nrow(x)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train
train_cases = sample.int(n, n_train, replace=FALSE)
test_cases = setdiff(1:n, train_cases)
x_train = x[train_cases,]
x_test = x[test_cases,]

m2 = randomForest(cases100k ~ (.)^2,data= x_train, mtry = 5, ntree=1000,importance=T)
plot(m2)
yhat_test2 = predict(m2, x_test)

rrf=round(rmse(x_test$cases100k,yhat_test2))

b=varImp(m2,type=2)

################## PArtial Dependence ###############3
windows()
par(mfrow = c(3,3))
partialPlot(m2, x_train[,1:30],x.var =27, main="Population Density",xlab="",ylab="Cases per 100k")
partialPlot(m2, x_train[,1:30],x.var =1, main="Days Since First Case",xlab="",xlim=c(20,60))
partialPlot(m2, x_train[,1:30],x.var =21, main="Workers driving Alone",xlab="",xlim=c(.1,.4))
partialPlot(m2, x_train[,1:30],x.var =9, main="Population White Race",xlab="",ylab="Cases per 100k")
partialPlot(m2, x_train[,1:30],x.var =26, main="Summer Max Temperature",xlab="",xlim=c(50,90))
partialPlot(m2, x_train[,1:30],x.var =5, main="Unemployment Rate",xlab="",xlim=c(0.03,0.12))
partialPlot(m2, x_train[,1:30],x.var =17, main="Occupation Food and Services",xlab="",xlim=c(0.04,0.11),ylim=c(175,195),ylab="Cases per 100k")
partialPlot(m2, x_train[,1:30],x.var =7, main="Population Male Gender",xlab="",xlim=c(0.5,.60))
partialPlot(m2, x_train[,1:30],x.var =28, main="Median Age",xlab="")



####################################
##### Boosting Model ##############
###################################

m3 = gbm(cases100k ~ .,data = x_train,n.trees=5000, shrinkage=.05)
yhat_test3= predict(m3, x_test, n.trees=5000)
rb=round(rmse(x_test$cases100k,yhat_test3))

names(m3)
a=as.data.frame(summary(m3))
b=as.data.frame(a[,2])
xtable(a)

