library(tidyverse)
library(mosaic)
library(Hmisc)
library(ggplot2)

## Data Selection
rm(list = ls())
data(SaratogaHouses)
Housing= as.data.frame(SaratogaHouses)
summary(SaratogaHouses)

##Calculating the correaltion matrix for all variables
mydata = Housing[, c(1,2,3,4,5,6,7,8,9,10)]

mydata.rcorr = cor(mydata, method = c("spearman"))
round(mydata.rcorr, 2)

## Calculating two new variables , Extra rooms & Building value
Housing$extrarooms = Housing$rooms-Housing$bedrooms
Housing$buildingvalue = Housing$price-Housing$landValue

## scatter plot of variables to see the relation 
ggplot(data = Housing, aes(x=livingArea, y=))+geom_point()+stat_smooth(method = "lm", formula = y ~ x + I(x^2), size = 1)
ggplot(data = Housing, aes(x=lotSize, y=price))+geom_point()+stat_smooth(method = "lm", formula = y ~ x + I(x^2), size = 1)

### Base model based on the correlation and scatter plots
basemodel = lm(price ~ Livingperlotsize + livingArea+ lotSize+ bathrooms+ centralAir + heating + extrarooms + 
                 age + bedrooms + pctCollege + fireplaces*livingArea , data = Housing)
summary(basemodel)

### Testing the model on out of sample data

n = nrow(Housing)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train
train_cases = sample.int(n, n_train, replace=FALSE)
test_cases = setdiff(1:n, train_cases)
Housing_train = Housing[train_cases,]
Housing_test = Housing[test_cases,]

lmbase = lm(price ~ lotSize + age + livingArea + pctCollege + bedrooms + extrarooms +
                 fireplaces + bathrooms + heating + landValue, data=Housing_train)

yhat_test1 = predict(lmbase, Housing_test)

rmse = function(y, yhat) {
  sqrt( mean( (y - yhat)^2 ) )
}

rmse(Housing$price, yhat_test1)

## Creation of new composite variables
Housing$buildingvalue= Housing$price-Housing$landValue
Housing$lotSize = Housing$lotSize+0.00001
Housing$Livingperlotsize = Housing$livingArea/Housing$lotSize
Housing$avgroomsize = (Housing$livingArea)/(Housing$rooms)
Housing$bathperbed = Housing$bathrooms/Housing$bedrooms


###base model Test with 250 iterations
Mean_rmse = do(1000)*{
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  Housing_train = Housing[train_cases,]
  Housing_test = Housing[test_cases,]
  
  lmbase = lm(buildingvalue ~ extrarooms + bedrooms + bathperbed + 
                centralAir + lotSize + heating + Livingperlotsize + age + pctCollege + , data = Housing)
                
                
                ### Option 1 Livingperlotsize + lotSize+ centralAir + heating + extrarooms + 
                    ## age + bedrooms +  bathperbed , data = Housing)
    
  
  ## Option 1 -price ~ Livingperlotsize + lotSize+ bathrooms+ centralAir + heating + extrarooms + 
    ## age + bedrooms + pctCollege + fireplaces + fuel , data = Housing 
  
  yhat_test = predict(lmbase, Housing_test)
  rmse(Housing$price, yhat_test)} 
 
mean(Mean_rmse$result, na.rm = TRUE)

### Professor'sMedium model Test with 250 iterations

Mean_medium = do(1000)*{
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  Housing_train = Housing[train_cases,]
  Housing_test = Housing[test_cases,]
  
  lm_medium = lm(price ~ lotSize + age + livingArea + pctCollege + bedrooms + 
                   fireplaces + bathrooms + rooms + heating + fuel + centralAir, data=Housing_train)
  
  yhat_test = predict(lm_medium, Housing_test)
  rmse(Housing$price, yhat_test)} 

mean(Mean_medium$result, na.rm = TRUE)

###finding out the best fit through step function
###Housing$buildingvalue <- NULL
Fullmodel = lm(buildingvalue ~ (Livingperlotsize + lotSize+ centralAir + heating + extrarooms + 
                 age + bedrooms + pctCollege + fireplaces + fuel + fuel*heating + bathperbed)^2 , data = Housing)

emptymodel = lm(buildingvalue~1 ,data = Housing)
step(emptymodel, scope = formula(Fullmodel), direction = "both", trace = 1)

