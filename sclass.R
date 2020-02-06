library(mosaic)
sclass = read.csv('sclass.csv')
summary(sclass)

# Focus on 2 trim levels: 350 and 65 AMG
sclass350 = subset(sclass, trim == '350')
sclass65AMG = subset(sclass, trim == '65 AMG')

# Look at price vs mileage for each trim level
plot(price ~ mileage, data = sclass350)
plot(price ~ mileage, data = sclass65AMG)

##################### Problem 2 HW1 #####################

library(tidyverse)
library(FNN)
######Plots fot both trims
windows()
plot350 =ggplot(data = sclass350) + 
  geom_point(mapping = aes(x = mileage, y = price), color='blue')
plot350
plot65AMG =ggplot(data = sclass65AMG) + 
  geom_point(mapping = aes(x = mileage, y = price), color='blue')  
plot65AMG

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
# reorder the rows of the testing set by the mileage variable
# this isn't necessary, but it will allow us to make a pretty plot later
D_test350 = arrange(D_test350, mileage)
head(D_test350)

# Now separate the training and testing sets into features (X) and outcome (y)
X_train350 = select(D_train350, mileage)
y_train350 = select(D_train350, price)
X_test350 = select(D_test350, mileage)
y_test350 = select(D_test350, price)

#####
########## K -Nearest Neighbor Model##############
#####
# define a helper function for calculating RMSE
rmse = function(y, ypred) {
  sqrt(mean(data.matrix((y-ypred)^2)))
}

knn_output <- data.frame(K=c(),rmse=c())

for(i in c(3:nrow(X_train350))){
  knn_Gen = knn.reg(train = X_train350, test = X_test350, y = y_train350, k=i)
  ypred_knn350 = knn_Gen$pred
  knn_rmse =rmse(y_test350,ypred_knn350)
  knn_output = rbind(knn_output,c(i,knn_rmse))
}
colnames(knn_output) <- c("k","RMSE")
k_min = knn_output$k[which.min(knn_output$RMSE)]

###########Graph rsme vs k ################
plot350_k= ggplot(data = knn_output)+
  geom_line(aes(x = k, y = RMSE))+
  geom_line(aes(x = k_min, y = RMSE), col = "red")
plot350_k

# Running the best Knn model 
#####

knn_best = knn.reg(train = X_train350, test = X_test350, y = y_train350, k=k_min)
ypred_knn350_best=knn_best$pred
rmse(y_test350, ypred_knn350_best)

####
# plot the fit
####
# attach the predictions to the test data frame
D_test350$ypred_knn350_best = ypred_knn350_best

p_test350 = ggplot(data = D_test350) + 
  geom_point(mapping = aes(x = mileage, y = price), color='lightgrey')+ 
  geom_path(aes(x = mileage, y = ypred_knn350_best), color='red')
p_test350 

