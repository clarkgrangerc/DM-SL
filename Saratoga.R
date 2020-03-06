library(tidyverse)
library(mosaic)
library(ggplot2)
library(foreach)
library(class)
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
Housing$buildingvalue= Housing$price-Housing$landValue
Housing$lotSize = Housing$lotSize+0.000001
Housing$Livingperlotsize = Housing$livingArea/Housing$lotSize
Housing$bathperbed = Housing$bathrooms/Housing$bedrooms
Housing$C_air= ifelse(Housing$centralAir == "Yes", 1, 0)
Housing$new_c= ifelse(Housing$newConstruction == "Yes", 1, 0)
Housing$heating_electric = ifelse(Housing$heating == "electric", 1, 0)
Housing$heating_hotair = ifelse(Housing$heating == "hot air", 1, 0)
Housing$heating_watersteam = ifelse(Housing$heating == "hot water/steam", 1, 0)

## scatter plot of variables to see the relation 
ggplot(data = Housing, aes(x=livingArea, y=))+geom_point()+stat_smooth(method = "lm", formula = y ~ x + I(x^2), size = 1)
ggplot(data = Housing, aes(x=lotSize, y=price))+geom_point()+stat_smooth(method = "lm", formula = y ~ x + I(x^2), size = 1)


### Splitting the data into train and test set
n = nrow(Housing)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train



### Defining the rmse function 

rmse = function(y, yhat) {
  sqrt( mean( (y - yhat)^2 ) )}



### Professor'sMedium model Test with 250 iterations

Mean_medium = do(1000)*{
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  Housing_train = Housing[train_cases,]
  Housing_test = Housing[test_cases,]
  
  lm_medium = lm(price ~ lotSize + age + livingArea + pctCollege + bedrooms + 
                   fireplaces + bathrooms + rooms + heating + fuel + centralAir, data=Housing_train)
  
  yhat_test = predict(lm_medium, Housing_test)
  rmse(Housing_test$price, yhat_test)} 
mean(Mean_medium$result, na.rm = TRUE)




###Best Linear model with 500 iterations

Mean_rmse = do(1000)*{
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  Housing_train = Housing[train_cases,]
  Housing_test = Housing[test_cases,]
  
  lmbase = lm(price ~ landValue+lotSize+ livingArea+ bedrooms+ bathrooms+ extrarooms + centralAir + heating + age+ newConstruction+ 
                fireplaces + fuel + age+ pctCollege , data=Housing_train)
                
                
                ### Option 1 Livingperlotsize + lotSize+ centralAir + heating + extrarooms + 
                    ## age + bedrooms +  bathperbed , data = Housing)
    
  
  yhat_test = predict(lmbase, Housing_test)
  rmse(Housing_test$price, yhat_test)} 

mean(Mean_rmse$result, na.rm = TRUE)


### plotting Predicted values vs Actual


mean_predvalues= colMeans(Mean_rmse)
plot(Housing_test$buildingvalue, mean_predvalues)
mean(Mean_rmse$result, na.rm = TRUE)




###finding out the best fit through step function

Fullmodel = lm(price ~ (landValue + Livingperlotsize + lotSize+ centralAir + heating + extrarooms + bathrooms + rooms+ livingArea +  
                 age + bedrooms + pctCollege + fireplaces + fuel + heating + bathperbed)^2 , data = Housing)

emptymodel = lm(price~1 ,data = Housing)
auto_lm=step(emptymodel, scope = formula(Fullmodel), direction = "both", trace = 1)

summary(auto_lm)



### Nearest K Values Model
### we use the same data

X=dplyr::select(Housing, landValue, lotSize, livingArea, bedrooms, bathrooms, extrarooms, age, new_c, heating_watersteam, heating_hotair, heating_electric, 
                  fireplaces, age, C_air)
y=Housing$price


k_grid = seq(75, 225, by=1)
err_grid = foreach(k = k_grid,  .combine='c') %do% {
  out = do(500)*{
    train_ind = sample.int(n, n_train, replace = FALSE)
    X_train = X[train_ind,]
    X_test = X[-train_ind,]
    y_train = y[train_ind]
    y_test = y[-train_ind]
    
    # scale the training set features
    scale_factors = apply(X_train, 2, sd)
    X_train_sc = scale(X_train, scale=scale_factors)
    
    # scale the test set features using the same scale factors
    X_test_sc = scale(X_test, scale=scale_factors)
    
    # Fit KNN models
    knn_try = knn(train=X_train_sc, test= X_test_sc, cl=y_train, k=k)
    # Calculating errors
    ###knn_pred = data.frame(knn_try)
    knn_pred = as.numeric(levels(knn_try))[as.integer(knn_try)]
    error=rmse(y_test, knn_pred)
  }   }

knn_error=do.call(cbind.data.frame, err_grid)
colnames(knn_error) = paste("K", k_grid, sep = "")
Mean_knn_rmse=data.frame(colMeans(knn_error))
colnames(Mean_knn_rmse) = ("RMSE")



### K vs RMSE graph
boxplot(knn_error, ylim=c(60000,100000))
abline(h=59000, col= "red")

min(Mean_knn_rmse$RMSE)
which.min(apply(Mean_knn_rmse,MARGIN=1,min))

plot1 =plot(k_grid, Mean_knn_rmse$RMSE)

  ##ggplot
  ggplot(stack(Mean_knn_rmse), aes(x = RMSE, y = values)) +
  geom_point()

meanrm= cbind(Mean_knn_rmse, k_grid)  
  ggplot(meanrm, aes(x = k_grid, y = RMSE)) +
    geom_point()+geom_vline(xintercept= k_grid[meanrm$RMSE == min(meanrm$RMSE)] , col = "red")+
    geom_text(mapping = aes(x= 130, y = 80500, label= paste("K135")), angle = 0,)
  
  
### Model Comparison
  
### Predicted vs actual Plot for both models 
library(reshape2)
Test1= train_ind = sample.int(n, n_train, replace = FALSE)
    fulltrn = Housing[train_ind,]
    Xtra = X[train_ind,]
    Xtst = X[-train_ind,]
    fulltst = Housing[-train_ind,]
    ytrn = y[train_ind]
    actual = y[-train_ind]
    
    # scale the training set features
    scale_factors = apply(Xtra, 2, sd)
    Xtrasc = scale(Xtra, scale=scale_factors)
    
    # scale the test set features using the same scale factors
    Xtstsc = scale(Xtst, scale=scale_factors)
    
    knnmodel = knn(train=Xtrasc, test= Xtstsc, cl=ytrn, k=135)
    knnpredict = as.numeric(levels(knnmodel))[as.integer(knnmodel)]
    
    lmmodel = lm(price ~ lotSize+ livingArea+ bedrooms+ bathrooms+ extrarooms + centralAir + heating + age+ newConstruction+ 
                   fireplaces + fuel + age , data=fulltrn)
    lm_predict = predict(lmmodel, fulltst)
    
    RMSE_LM = rmse(fulltst$price, lm_predict)
    RMSE_Knn = rmse(actual, knnpredict)

PvAtest= melt(data.frame(cbind(actual, lm_predict, knnpredict)), "actual" )   
### Predicted vs Actual Plot    
ggplot(data= PvAtest)+ geom_point(mapping = aes(x=actual, y= value, color= variable), alpha = 0.3)+
  geom_abline(intercept= 0, slope=1,)
  

###Calculating squared errors for both models for same samples  
variance = do(100)*{{train_ind = sample.int(n, n_train, replace = FALSE)
    fulltrain = Housing[train_ind,]
    Xtrain = X[train_ind,]
    Xtest = X[-train_ind,]
    fulltest = Housing[-train_ind,]
    ytrain = y[train_ind]
    ytest = y[-train_ind]

    # scale the training set features
    scale_factors = apply(Xtrain, 2, sd)
    Xtrainsc = scale(Xtrain, scale=scale_factors)
    
    # scale the test set features using the same scale factors
    Xtestsc = scale(Xtest, scale=scale_factors)
    
    knnmodel = knn(train=Xtrainsc, test= Xtestsc, cl=ytrain, k=120)
    knnpred = as.numeric(levels(knnmodel))[as.integer(knnmodel)]
    
    lmmodel = lm(price ~ lotSize+ livingArea+ bedrooms+ bathrooms+ extrarooms + centralAir + heating + age+ newConstruction+ 
                   fireplaces + fuel + age , data=fulltrain)
    lm_pred = predict(lmmodel, fulltest)
}    
   modelcom = cbind(ytest, lm_pred, knnpred)
}   
 
####  
variance$lm_sqerror = (variance$ytest-variance$lm_pred)^2
variance$knn_sqerror = (variance$ytest-variance$knnpred)^2

variance <- within(variance, Percentile <- as.integer(cut(ytest, quantile(ytest, probs=0:20/20), include.lowest=TRUE)))

var = variance %>%
  group_by(Percentile)  %>%  # group the data points by model nae
  summarize(lm_rmse = sqrt(mean((lm_sqerror))), 
            knn_rmse = sqrt(mean((knn_sqerror))))

var$Percentile= (var$Percentile*5)-5
vardata = melt(var, "Percentile")

ggplotly(ggplot(data=vardata, aes(x=Percentile, y=value , fill = variable)) +
  geom_bar(stat="identity", position ="identity", alpha=.3 ))
  
library(plotly)
ggplotly(ggplot(variance)+geom_col(mapping= aes(x= ytest, y = lm_sqerror)))

write.csv(Housing, file = "Housing.csv")
write.csv(meanrm, file = "meanrm.csv")
write.csv(vardata, file = "vardata.csv")


base_linear = predict(lm_medium, test)
modified_linear =  predict(lmbase, test)
KNN = 

### Plots
plot(test$price, base_linear) 
abline(a=0, b=1)

plot(test$price, modified_linear)
abline(a=0, b=1)

base_linear_rmse= rmse(test$price, base_linear)
modified_linear = rmse(test$buildingvalue, modified_linear)
    
