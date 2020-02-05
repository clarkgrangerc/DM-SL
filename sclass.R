library(mosaic)
sclass = read.csv('C:/Users/clark/OneDrive/UTEXAS/Spring20/Data Mining/sclass.csv')

# The variables involved
summary(sclass)

# Focus on 2 trim levels: 350 and 65 AMG
sclass350 = subset(sclass, trim == '350')
dim(sclass350)

sclass65AMG = subset(sclass, trim == '65 AMG')
summary(sclass65AMG)

# Look at price vs mileage for each trim level
plot(price ~ mileage, data = sclass350)
plot(price ~ mileage, data = sclass65AMG)

##################### Problem 2 HW1 #####################

library(tidyverse)
library(FNN)
######Plots fot both trims
ggplot(data = sclass350) + 
  geom_point(mapping = aes(x = mileage, y = price), color='blue')  
ggplot(data = sclass65AMG) + 
  geom_point(mapping = aes(x = mileage, y = price), color='blue')  

# Make a train-test split 350
N350 = nrow(sclass350)
N_train350 = floor(0.8*N350)
N_test350 = N350 - N_train350

# Make a train-test split 65 AMG
N65 = nrow(sclass65AMG)
N_train65 = floor(0.8*N65)
N_test65 = N65 - N_train65

####### 350 ###########

#####Train/test split
# randomly sample a set of data points to include in the training set
train_ind350 = sample.int(N350, N_train350, replace=FALSE)

# Define the training and testing set
D_train350 = sclass350[train_ind350,]
D_test350 = sclass350[-train_ind350,]

# optional book-keeping step:
# reorder the rows of the testing set by the KHOU (temperature) variable
# this isn't necessary, but it will allow us to make a pretty plot later
D_test350 = arrange(D_test350, price)
head(D_test350)

# Now separate the training and testing sets into features (X) and outcome (y)
X_train350 = select(D_train350, mileage)
y_train350 = select(D_train350, price)
X_test350 = select(D_test350, mileage)
y_test350 = select(D_test350, price)

#####
# Fit a few models for 350 A
#####

# linear and quadratic models
lm350 = lm(price ~ mileage, data=D_train350)
summary(lm350)
names(lm350)
plot(lm350$fitted.values)
#lm2 = lm(COAST ~ poly(KHOU, 2), data=D_train)

# KNN 10
knn10 = knn.reg(train = X_train350, test = X_test350, y = y_train350, k=10)
summary(knn10)
names(knn10)

#####
# Compare the models by RMSE_out
#####

# define a helper function for calculating RMSE
rmse = function(y, ypred) {
  sqrt(mean(data.matrix((y-ypred)^2)))
}

ypred_lm350 = predict(lm350, X_test350)
#ypred_lm2 = predict(lm2, X_test)
ypred_knn10 = knn10$pred

rmse(y_test350, ypred_lm350)
#rmse(y_test, ypred_lm2)
rmse(y_test350, ypred_knn10)




