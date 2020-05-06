library(ggplot2)
library(tidyverse)
library(dplyr)
library(foreach)
library(mosaic)
library(reshape2)
library(data.table)
library(Metrics)
library(MASS)


covid = read.csv("covid2zargham.csv")
covid = filter(covid, !is.na(cases))

ggplot(covid)+ geom_point(mapping = aes(days_since_first_infection1, cases))
covid$cases_per_100thous = covid$cases/ ((covid$ET_Total_Population)/100000)


ggplot(covid)+ geom_point(mapping = aes(days_since_first_infection1, cases_per_100thous))
sum(is.na(glmdata2))

covid$ln_cases = log(covid$cases)
covid$ln_pop = log(covid$ET_Total_Population)
covid$ln_households = log(covid$totalhouseholds)

summary(covid)

###### Linear Regressions

lm1 = lm(ln_cases ~ days_since_first_infection1+ ln_pop+Density.per.square.mile.of.land.area...Population+
           stayhome+restaurant.dine.in+ workplaces_percent_change_from_baseline, data = covid)

summary(lm1)

lm2 = lm(ln_cases ~ ., data = covid[, -c(1:4,6,80:89)])
summary(lm2)

###### PCA and Linear Regression

X= covid[,-c(1:6,88,86,81)]
X= scale(X, center = TRUE, scale = TRUE)

x_pc = prcomp(X)
scores = x_pc$x
summary(x_pc)

pcadata = data.frame(cbind(covid$ln_cases, scores))

fviz_pca_var(x_pc, col.var="contrib",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE, title = "Variables Contribution in first two PCAs " )

lm3 = lm(V1 ~., data = pcadata[,-c(27:81)])
summary(lm3)
yhat = predict(lm3)
rmse(covid$ln_cases, yhat)

getwd()
result = data.frame(cbind(yhat, covid$cases, covid$days_since_first_infection1))

ggplot(result)+ geom_point(mapping = aes(V3, yhat))
write.csv(final, "C:/Users/zargh/Documents/GitHub/DM-SL/Assignment4/covid.csv", row.names = TRUE)
######GLM Negative binomial model
glm = read.csv("covidglm.csv")
covid2= covid2[,-c(35:36)]
X = glm[,c(14:84)]
X = scale(X, center = TRUE, scale = TRUE)

glmdata = cbind(glm[,c(1:13)], X)
glmdata$ln_cases = log(glmdata$cases)
colnames(glmdata)
glmdata$state.x = factor(glmdata$state.x)
glmdata = data.frame(glmdata)
glmdata2 = glmdata[,-c(1:3)]
summary(glmdata)
lm4 = glm.nb(cases ~ ., 
             data =glmdata2, control = glm.control(maxit = 10), link = log)
summary(lm4)
yhat = predict(lm4,type = "response")
rmse(glmdata2$cases, yhat)

orig = data.frame(cbind(yhat, glmdata2$cases, glmdata2$days_since_first_infection1))
ggplot(orig)+ geom_point(mapping = aes(V3, yhat))

sum(is.infinite(glm1$winter_tmmx))

n = nrow(glm1)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train




glmcovid = do(300)*{
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  glm_train = glm1[train_cases,]
  glm_test = glm1[test_cases,]
  lm4 = glm.nb(cases ~ .-deaths, data = glm_train ,control = glm.control(maxit = 50), link = log)
  
  yhat= predict(lm4, glm_test, type="response")
  error_rate = rmse(glm_test$cases, yhat)}

errorrate = mean(glmcovid$result, na.rm = FALSE)


glm1 = glm[-c(1:3)]

#####################################################
####### Lassso function #########################
####################################################
scx = as.matrix(glm1[,-1])
scy = glm1$cases
library(mpath)

sclasso = cv.glmregNB(scx, scy, family= "negbin", alpha=0.05, maxit.theta =200, trace=FALSE)
sclasso$call

plot.glmreg()
plot(sclasso)
AICc(sclasso)
coef =sclasso$beta
mode(scx)


lm3 = glm.nb(cases ~ days_since_first_infection1+Tests.per.100thousand+stayhome+
               Unemployment_rate_2018+Total_age18to64+E_TRANSPORTATION_Total_Workers_Over_16_Drove_Alone+
               E_Total_Pop_POVERTY_STATUS_Below_100_Percent+winter_tmmx+Density.per.square.mile.of.land.area...Population+
               Density.per.square.mile.of.land.area...Housing.units+totalhouseholds+ET_Total_Population+Housing.units+
               workplaces_percent_change_from_baseline, data = glm1,control = glm.control(maxit = 50), link = log)
summary(lm3)
yhat= predict(lm3, type="response")
plot(glm1$cases, yhat)
rmse(glm1$cases, yhat)
summary(glm1)

#####################################################
####### Step      function #########################
####################################################

Y= as.matrix(glm1) 
colnames(glm1)[colSums(sd(glm1)) > 0]



X= as.data.frame(scale(glm1[, -c(1:2)]))
Y= cbind(glm1$cases, X)

m0 = glm.nb(glm$cases~1, data = Y, control = glm.control(maxit = 50), link = log)
lm0= glm.nb(glm$cases~., data = Y, control = glm.control(maxit = 50), link = log)

m3 = step(m0, scope=formula(lm0), dir="forward")


lm5= glm.nb(glm$cases ~ days_since_first_infection1+Tests.per.100thousand+stayhome+
         Unemployment_rate_2018+Total_age18to64+E_TRANSPORTATION_Total_Workers_Over_16_Drove_Alone+
         E_Total_Pop_POVERTY_STATUS_Below_100_Percent+winter_tmmx+Density.per.square.mile.of.land.area...Population+
         Density.per.square.mile.of.land.area...Housing.units+totalhouseholds+ET_Total_Population+Housing.units+
         workplaces_percent_change_from_baseline, data = Y,control = glm.control(maxit = 10), link = log)

summary(lm5)

###########################################################
############PCA Model ###################################
#########################################################

pc= prcomp(X, scale. = FALSE)
summary(pc)
scores= pc$x
Y= as.data.frame(cbind(glm1$case, scores[,-c(26:79)]))

n = nrow(Y)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train

glmcovid = do(300)*{
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  glm_train = Y[train_cases,]
  glm_test = Y[test_cases,]
  lm4 = glm.nb(V1 ~ ., data = glm_train ,control = glm.control(maxit = 50), link = log)
  
  yhat= predict(lm4, glm_test, type="response")
  error_rate = rmse(glm_test$V1, yhat)}

summary(lm4)
compare = cbind(yhat, glm_test)
errorrate = mean(glmcovid$result, na.rm = FALSE)

(days_since_first_infection1+Tests.per.100thousand+stayhome+Total_age0to17+E_Total_Pop_RACE_White+E_Total_Pop_in_Households_Householder_Parent+
    E_Total_Pop_Over_15_MARITAL_STATUS_Divorced+E_INDUSTRY_Accommodation_Food_Services+E_INDUSTRY_Public_Administration+ET_TRANSPORTATION_Total_Workers_Over_16+E_Total_Households_WITH_INCOME_WITH_Cash_Public_Asst+winter_tmmx+Density.per.square.mile.of.land.area...Population+Density.per.square.mile.of.land.area...Housing.units+
    EM_Total_Pop_Median_Age+ET_Total_Population+workplaces_percent_change_from_baseline)
###########################################################
glm = covid[,-c(1:3,5)]


lm5 = glm.nb(cases ~days_since_first_infection1 + Tests.per.100thousand+stayhome + Total_age0to17 + E_Total_Pop_RACE_White + E_Total_Pop_in_Households_Householder_Parent +
               E_Total_Pop_Over_15_MARITAL_STATUS_Divorced + E_INDUSTRY_Accommodation_Food_Services + E_INDUSTRY_Public_Administration + ET_TRANSPORTATION_Total_Workers_Over_16 + E_Total_Households_WITH_INCOME_WITH_Cash_Public_Asst + winter_tmmx + Density.per.square.mile.of.land.area...Population + Density.per.square.mile.of.land.area...Housing.units + 
               EM_Total_Pop_Median_Age + ET_Total_Population + workplaces_percent_change_from_baseline, data = glm , control =  glm.control(maxit = 100), link = log)

summary(lm5)


n = nrow(glm)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train

glmcovid = do(100)*{
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  glm_train = glm[train_cases,]
  glm_test = glm[test_cases,]
  lm4 = glm.nb(cases ~., data = glm_train)
  
  yhat= predict(lm4, glm_test, type="response")
  error_rate = rmse(glm_test$cases, yhat)}

###################################################################

X= scale(glm[,-c(1,9)])
Y= cbind(glm[,c(1,9)],X)
Y = as.data.frame(Y)

lm6 = glm.nb(cases ~., data = covid, control =  glm.control(maxit = 100), link = log)



summary(lm6)
yhat = predict(lm6, type = "response")
rmse(covid$cases, yhat)
