library(ggplot2)
library(tidyverse)
library(dplyr)
library(foreach)
library(mosaic)
library(LICORS)
library(factoextra)
library(reshape2)
library(data.table)
library(MASS)
library(NBZIMM)

library(remotes)
install_github("nyiuab/NBZIMM", force=T, build_vignettes=T)

covid = read.csv("covidzargham.csv")
covid = filter(covid, !is.na(cases))

ggplot(covid)+ geom_point(mapping = aes(days_since_first_infection1, cases))
covid$cases_per_100thous = covid$cases/ ((covid$ET_Total_Population)/100000)


ggplot(covid)+ geom_point(mapping = aes(days_since_first_infection1, cases_per_100thous))
sum(is.na(covid$cases))

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
covid2 = covid[, c(1:12, 16:30, 34,35, 37, 40 ,81:89 ,54:78)]
covid2= covid2[,-c(35:36)]
X = covid2[,c(13:62)]
X = scale(X, center = TRUE, scale = TRUE)

glmdata = cbind(covid2[,c(1:12)], X)
glmdata$ln_cases = log(glmdata$cases)
colnames(glmdata)
glmdata = data.frame(glmdata)
summary(glmdata)
lm4 = glm.nb(cases ~.-fips.x-county-state.x-deaths-ln_cases-totalhouseholds, data =glmdata )
summary(lm4)
yhat = predict(lm4)
orig = data.frame(cbind(exp(yhat), glmdata$cases))
y = exp(yhat)
