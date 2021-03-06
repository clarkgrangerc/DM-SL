library(ggplot2)
library(tidyverse)
library(dplyr)
library(foreach)
library(mosaic)
library(reshape2)
library(data.table)
library(Metrics)
library(MASS)
library(factoextra)

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

lm6 = glm.nb(cases ~. - fips.x-county-state.x, data = covid, control =  glm.control(maxit = 100), link = log)

covid= covid[,-c(1:3,5)]
n = nrow(covid)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train

glmcovid = do(50)*{
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  glm_train = covid[train_cases,]
  glm_test = covid[test_cases,]
  lm4 = glm.nb(cases ~., data = glm_train, control =  glm.control(maxit = 300))
  
  yhat= predict(lm4, glm_test, type="response")
  error_rate = rmse(glm_test$cases, yhat)}
errorrate = mean(glmcovid$result, na.rm = FALSE)


####################################################################
############## vGLM  with Total Cases ###############################
covid3= covid[, -c(1:3, 5, 37)]

m13 <- vglm(cases ~ ., family = pospoisson(), data = covid3)
yhat2 = predict(m13, type = 'response')
modelfit2= as.data.frame(cbind(yhat2, covid3$cases))


ggplot(modelfit2, mapping = aes(V2, V1))+geom_point()+geom_abline(slope = 1,intercept = 0)+
  coord_cartesian(xlim = c(0, 20000 + 10))

ggplot(covid, mapping = aes(days_since_first_infection1,cases1))+geom_point()
 

vglmerr2 = do(300)*{
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  glm_train = covid3[train_cases,]
  glm_test = covid3[test_cases,]
  lm5 = vglm(cases ~ ., family = pospoisson(), data = glm_train)
  
  yhat= predict(lm5, glm_test, type="response")
  error_rate = rmse(glm_test$cases, yhat)}
mean(vglmerr2$result, na.rm = FALSE)





















#################################################################
############ Zero trunucated model on total cases###############
library(VGAM)

m12 <- vglm(cases ~ .-cases1, family = pospoisson(), data = covid)
yhat = predict(m12, type = 'response')
modelfit1= as.data.frame(cbind(yhat, covid$cases))

summary(covid)

ggplot(modelfit1, mapping = aes(V2, V1))+geom_point()+geom_abline(slope = 1,intercept = 0)+
  coord_cartesian(xlim = c(0, 20000 + 10))

vglmerr = do(300)*{
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  glm_train = covid1[train_cases,]
  glm_test = covid1[test_cases,]
  lm5 = vglm(cases1 ~ ., family = pospoisson(), data = glm_train)
  
  yhat= predict(lm5, glm_test, type="response")
  error_rate = rmse(glm_test$cases1, yhat)}
mean(vglmerr$result, na.rm = FALSE)



#######################################################################
################ PCA #################################################
X= covid[,-1]
PCA = prcomp(X, scale. = TRUE)
summary(PCA)

fviz_pca_var(PCA, col.var="contrib",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),select.var = list(contrib=12),
             repel = TRUE, title = "Variables Contribution in first two PCAs " )


scores = PCA$x
scores= cbind(covid$cases, scores)
scores = as.data.frame(scores)
qplot(PC1,PC2, data=scores, color= V1)+scale_color_gradient(low = "grey", high= 'red')+ggtitle("Cluster Plot with Wine Color and Differentiating features")


#######################################################################
############## VGLM Model on PCA #####################################

covidvglmPCA = do(300)*{
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  glm_train = scores[train_cases,]
  glm_test = scores[test_cases,]
  lm5 = vglm(V1 ~ PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10+PC11+PC12+PC13+PC14+
             PC15+PC16, family = pospoisson(), data = glm_train)
  
  yhat= predict(lm5, glm_test, type="response")
  error_rate = rmse(glm_test$V1, yhat)}
errorrate = mean(covidvglmPCA$result, na.rm = FALSE)

########################################################################
################### Negative Binomial on PCA ##########################


covidglmPCA = do(300)*{
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  glm_train = scores[train_cases,]
  glm_test = scores[test_cases,]
  lm5 = glm.nb(V1 ~ PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10+PC11+PC12+PC13+PC14+
               PC15+PC16+PC17+PC18+PC19+PC20, data = glm_train, control =  glm.control(maxit = 300))
  
  yhat= predict(lm5, glm_test, type="response")
  error_rate = rmse(glm_test$V1, yhat)}

errorrate = mean(covidglmPCA$result, na.rm = FALSE)


#######################################################################
########################## Working with cases per 100K ################

covid3 = covid[, -c(1:5, 35)]
summary(covid3)
#######################################################################
####################### Simple Negative Binomial model ###############

n = nrow(covid3)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train

glmcovid = do(50)*{
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  glm_train = covid3[train_cases,]
  glm_test = covid3[test_cases,]
  lm4 = glm.nb(cases1 ~., data = glm_train, control =  glm.control(maxit = 300))
  
  yhat= predict(lm4, glm_test, type="response")
  error_rate = rmse(glm_test$cases1, yhat)}
errorrate = mean(glmcovid$result, na.rm = FALSE)

#######################################################################################
######################## Zero Truncated Neg Binomial Model ############################

colnames(covid)=cnames

m111 = vglm(cases100k ~ ., family = pospoisson(), data = covid3)
yhat = predict(m1, type = 'response')
modelfit= as.data.frame(cbind(yhat, covid3$cases1))

summary(m1)
ggplot(modelfit, mapping = aes(V2, V1))+geom_point()+geom_abline(slope = 1,intercept = 0)+
  coord_cartesian(xlim = c(0, 1000 + 10))

covidscale = scale(covid3[,-31])
covidscale = as.data.frame(cbind(covid3$cases1, covidscale))

vglmerr = do(300)*{
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  glm_train = covid3[train_cases,]
  glm_test = covid3[test_cases,]
  lm5 = vglm(cases1 ~ ., family = pospoisson(), data = glm_train)
  
  yhat= predict(lm5, glm_test, type="response")
  error_rate = rmse(glm_test$cases1, yhat)}
errorrate = mean(vglmerr$result, na.rm = FALSE)

################################################################################
############################### PCA ##########################################

Y= covid3[,-31]

PCA2 = prcomp(Y, scale. = TRUE)
summary(PCA2)

fviz_pca_var(PCA2, col.var="contrib",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),select.var = list(contrib=15),
             repel = TRUE, title = "Variables Contribution in first two PCAs " )


scores2 = PCA2$x
scores2= cbind(covid3$cases1, scores2)
scores2 = as.data.frame(scores2)
qplot(PC1,PC2, data=scores2, color= V1)+scale_color_gradient(low = "grey", high= 'red')+ggtitle("Scatterplot of Cases for Counties along first two PCs ")

library(xtable)
library(texreg)
library(kableExtra)
library(pander)
summary(m111)

d =summaryvglm(m111)
pander(d@coef3)
pander(d@pearson.resid)

extract.vglm(m111, include.loglik = FALSE,include.df = TRUE, include.nobs = TRUE)

xtable(d@coef3)
xtable(d@pearson.resid)

