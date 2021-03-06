####Green buildings case####

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

greenbuildings = read.csv("greenbuildings.csv", header=TRUE)
greenbuildings = na.omit(greenbuildings)
gb = greenbuildings[which(greenbuildings$leasing_rate != 0),]
gb$size = gb$size/1000

#############################################################
#####APPROACH 1 fitting Linear models and step selection ############
#############################################################

#### Null model####
m0 = lm(Rent~1, data=gb)
summary(m0)

#### Manual built model####
m1  = lm(Rent ~ . -CS_PropertyID-LEED-Energystar
          -Precipitation-cd_total_07-hd_total07, data=gb)
summary(m1)
margins(m1)

#### Manual model allowing interactions ####
m2  = lm(Rent ~ (. -CS_PropertyID-LEED-Energystar
                 -Precipitation-cd_total_07-hd_total07)^2, data=gb)
summary(m2)
margins(m2)


#### Step selection ####
m3 = step(m0, scope=formula(m1), dir="forward")
summary(m3)
formula(m3)

m4 = step(m0, scope=formula(m2), dir="forward")
summary(m4)
formula(m4)
marm4=margins(m4)


# Compare out of sample performance
n = nrow(gb)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train
rmse_lm = do(50)*{
    # re-split into train and test cases with the same sample sizes
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  gb_train = gb[train_cases,]
  gb_test = gb[test_cases,]
  
  # Fit to the training data
  # use `update` to refit the same model with a different set of data
  lm1 = update(m1, data=gb_train)
  lm2 = update(m2, data=gb_train)
  lm3 = update(m3, data=gb_train)
  lm4 = update(m4, data=gb_train)
  
  # Predictions out of sample
  yhat_test1 = predict(lm1, gb_test)
  yhat_test2 = predict(lm2, gb_test)
  yhat_test3 = predict(lm3, gb_test)
  yhat_test4 = predict(lm4, gb_test)
  
  c(rmse(gb_test$Rent, yhat_test1),
    rmse(gb_test$Rent, yhat_test2),
    rmse(gb_test$Rent, yhat_test3),
    rmse(gb_test$Rent, yhat_test4))
}
rmse.lm=colMeans(rmse_lm)
aic.lm=AIC(m1,m2,m3,m4)
bic.lm=BIC(m1,m2,m3,m4)

AIC=aic.lm$AIC
BIC=bic.lm$BIC
DF=bic.lm$df

a=cbind(rmse.lm,AIC,BIC,DF)
colnames(a)<-c("RMSE","AIC","BIC","DF")
row.names(a) <- c("Model 1: Manual built","Model 2: Interactions
                        ","Model 3: Manual built + step","Model 4: Interactions + step")
table1=kable(a, digits=2, padding = 2)%>%
  kable_styling()
table1

##############################################################
####### APPROACH 2 Lasso Regression and Regularization #######
##############################################################
rmse_lasso = do(10)*{
  # re-split into train and test cases with the same sample sizes
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  gb_train = gb[train_cases,]
  gb_test = gb[test_cases,]
  x_train= sparse.model.matrix(Rent ~ (.-CS_PropertyID-LEED-Energystar)^2, data=gb_train)[,-1] # do -1 to drop intercept!
  x_test= sparse.model.matrix(Rent ~ (.-CS_PropertyID-LEED-Energystar)^2, data=gb_test)[,-1]
  y=gb_train$Rent

###### CV Lasso best model ######
cvm5= cv.gamlr(x_train, y, nfold=10,  verb=TRUE)

# plot the out-of-sample deviance as a function of log lambda
# Q: what are the bars associated with each dot? 
  plasso=plot(cvm5, bty="n")
  
  ## CV min deviance selection
  scb.min = coef(cvm5, select="min")
  lambda=log(cvm5$lambda.min)
  coef.lasso=sum(scb.min!=0) 
  
  yhat_test5 = as.numeric(predict(cvm5, x_test, select="min"))
  
  c(rmse(gb_test$Rent,yhat_test5),lambda,coef.lasso)
}
info.lasso=colMeans(rmse_lasso)
lambda1=info.lasso[2]
coef.lasso1=info.lasso[3]


info.lasso=as.data.frame(info.lasso)
colnames(info.lasso)<-c("Lasso Model")
row.names(info.lasso) <- c("RMSE","Log Lambda",
                        "Number of coefficients")
table2=kable(info.lasso)%>%
  kable_styling()  
table2



##############################################################
####### APPROACH 3 Tree model,random forest and boosting######
##############################################################

#### Create the subsample for training an testing ####
n = nrow(gb)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train

############################  
###### 3.A. Tree model #####
rmse_tree = do(50)*{
# re-split into train and test cases with the same sample sizes
train_cases = sample.int(n, n_train, replace=FALSE)
test_cases = setdiff(1:n, train_cases)
gb_train = gb[train_cases,]
gb_test = gb[test_cases,]

m6= rpart(Rent ~ .-CS_PropertyID-LEED-Energystar, method="anova",data=gb_train,
              control=rpart.control(minsplit=5, cp=1e-6, xval=10))
nm6 = length(unique(m6$where))

# calculate the cv error + 1 standard error
# the minimum serves as our threshold
err1se = m6$cptable[,'xerror'] + m6$cptable[,'xstd']
errth = min(err1se)

# now find the largest simplest tree that beats this threshold
m6$cptable[,'xerror'] - errth
stree=min(which(m6$cptable[,'xerror'] - errth < 0)) 
bestm6 = m6$cptable[stree,'CP']

###### Cross validation tree model ####
cvm6 = prune(m6, cp=bestm6)
length.btree=length(unique(cvm6$where))
plot(cvm6)
text(cvm6)

yhat_test6 = predict(cvm6, gb_test)
c(rmse(gb_test$Rent,yhat_test6),length.btree)
}
info.trees=colMeans(rmse_tree)
####################################
##### 3.B. Random Forest Model #####
m7 = randomForest(Rent ~ .-CS_PropertyID-LEED-Energystar,
                  data = gb_train, mtry = 5, ntree=500)
plot(m7)
yhat_test7 = predict(m7, gb_test)
rmse.rf=rmse(gb_test$Rent,yhat_test7)
varImp(m7) 
varImpPlot(m7,type=2)

####################################
##### 3.C. Boosting Model #########

m8 = gbm(Rent ~ .-CS_PropertyID-LEED-Energystar,
         data = gb_train,n.trees=5000, shrinkage=.05)
yhat_test8= predict(m8, gb_test, n.trees=5000)
summary(m8)
rmse.boost=rmse(gb_test$Rent,yhat_test8)

table3=as.data.frame(c(info.trees[1],rmse.rf,rmse.boost))
colnames(table3)<-c("RMSE")
row.names(table3) <- c("Tree model","Random Forest",
                           "Boosting")
table3=kable(table3)%>%
  kable_styling()  
table3





