library(tidyverse)
library(mosaic)
library(class)
library(FNN)
library(foreach)
library(class)
library(jtools)
library(knitr)
library(margins)


#### Reading the data
on = read.csv('online_news.csv')
summary(on)
###option to read directly from website
on = read.csv("https://raw.githubusercontent.com/jgscott/ECO395M/master/data/online_news.csv")

###### Adding Viral Binary Variable and Log Shares Variable to the dataset
on$viral = ifelse(on$shares > 1400, 1, 0)
summary(on$viral)
on$lshares =log(on$shares)

##############################################################
### AVG Accuracy model # 0 Null model for comparison (Accuraccy)
n = nrow(on)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train
train_cases = sample.int(n, n_train, replace=FALSE)
test_cases = setdiff(1:n, train_cases)
on_train = on[train_cases,]
null_m=table(on_train$viral)
null_m
ACC_null=null_m[1]/count(on_train)
ACC_null



###############################################################
#### Approach no. 1 = models with shares as dependent variable 

m1 = lm(shares ~ n_tokens_title + n_tokens_content + num_hrefs + 
          num_self_hrefs + num_imgs + num_videos + 
          average_token_length + num_keywords + data_channel_is_lifestyle +
          data_channel_is_entertainment + data_channel_is_bus + 
          data_channel_is_socmed + data_channel_is_tech +
          data_channel_is_world + self_reference_avg_sharess +
         is_weekend + global_rate_negative_words + global_rate_positive_words + title_subjectivity,data=on)
summary(m1)

m2 = lm(shares ~ n_tokens_title + n_tokens_content + num_hrefs + 
          num_self_hrefs + num_imgs + 
          average_token_length + num_keywords + data_channel_is_lifestyle +
          data_channel_is_entertainment + data_channel_is_bus + 
          data_channel_is_socmed + data_channel_is_tech +
          data_channel_is_world + self_reference_avg_sharess +
          is_weekend,data=on)
summary(m2)


m0 = lm(shares~ 1, data=on)
ms1 = step(m0, direction='forward',
                  scope=~(n_tokens_title + n_tokens_content + num_hrefs + 
                            num_self_hrefs + num_imgs + num_videos + 
                            average_token_length + num_keywords + data_channel_is_lifestyle +
                            data_channel_is_entertainment + data_channel_is_bus + 
                            data_channel_is_socmed + data_channel_is_tech +
                            data_channel_is_world + self_reference_avg_sharess +
                            is_weekend + global_rate_negative_words + global_rate_positive_words + title_subjectivity)^2)
summary(ms1)


##### AVG accuracy for Linear Model #1 built manually

lm_shares = do(100)*{
  #	resample data with replacement
    # Split into training and testing sets
  n = nrow(on)
  n_train = round(0.8*n)  # round to nearest integer
  n_test = n - n_train
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  on_train = on[train_cases,]
  on_test = on[test_cases,]
  y_test   = on$viral[test_cases]
  
    m1 = lm(shares ~ n_tokens_title + n_tokens_content + num_hrefs + 
            num_self_hrefs + num_imgs + num_videos + 
            average_token_length + num_keywords + data_channel_is_lifestyle +
            data_channel_is_entertainment + data_channel_is_bus + 
            data_channel_is_socmed + data_channel_is_tech +
            data_channel_is_world + self_reference_avg_sharess +
            is_weekend + global_rate_negative_words + global_rate_positive_words + title_subjectivity,data=on_train)
  
  pred_test = predict(m1, on_test)
  yhat_test = ifelse((pred_test>1400),yes=1,no=0)
  1-sum(yhat_test != y_test)/n_test 
  
}
ACC_m1=colMeans(lm_shares)
ERR_m1=1-ACC_m1

##### AVG accuracy for Linear Model #2 built using KNN with shares
X = dplyr::select(on, n_tokens_title, n_tokens_content, num_hrefs, 
                  num_self_hrefs, num_imgs, num_videos, 
                  average_token_length, num_keywords, self_reference_avg_sharess) 
y = on$shares

k_grid = seq(1, 100, by=5)
err_grid = foreach(k = k_grid,  .combine='c') %do% {
  knn_shares = do(5)*{
    n = length(y)
    n_train = round(0.8*n)
    n_test = n - n_train
    train_ind = sample.int(n, n_train)
    X_train = X[train_ind,]
    X_test = X[-train_ind,]
    y_train = y[train_ind]
    y_test = y[-train_ind]
    y_test_valid=on$viral[-train_ind]
    
    # scale the training set features
    scale_factors = apply(X_train, 2, sd)
    X_train_sc = scale(X_train, scale=scale_factors)
    
    # scale the test set features using the same scale factors
    X_test_sc = scale(X_test, scale=scale_factors)
    
    # Fit two KNN models (notice the odd values of K)
    knn_m2= knn.reg(train=X_train_sc, test= X_test_sc, y=y_train, k=k)
    
   # Calculating classification errors
    phat_test = knn_m2$pred
    yhat_test = ifelse((phat_test>1400),1 , 0)
    sum(yhat_test != y_test_valid)/n_test 
    
  } 
  colMeans(knn_shares)
}
acc_k=1-err_grid
ACC_km2=max(acc_k)
ACC_km2
knngraph <- data.frame(K=c(k_grid), acc=c(acc_k))
colnames(knngraph) <- c("k","AVG_ACC")
k_min = knngraph$k[which.max(knngraph$AVG_ACC)]


##### AVG accuracy for Linear Model #3 built using ln of shares 

lm_lshares = do(100)*{
  #	resample data with replacement
  # Split into training and testing sets
  n = nrow(on)
  n_train = round(0.8*n)  # round to nearest integer
  n_test = n - n_train
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  on_train = on[train_cases,]
  on_test = on[test_cases,]
  y_test   = on$viral[test_cases]
  
  
  m3 = lm(lshares ~ n_tokens_title + n_tokens_content + num_hrefs + 
            num_self_hrefs + num_imgs + num_videos + 
            average_token_length + num_keywords + data_channel_is_lifestyle +
            data_channel_is_entertainment + data_channel_is_bus + 
            data_channel_is_socmed + data_channel_is_tech +
            data_channel_is_world + self_reference_avg_sharess +
            is_weekend + global_rate_negative_words + global_rate_positive_words + title_subjectivity,data=on_train)
  
  pred_test = predict(m3, on_test)
  yhat_test = ifelse(pred_test>log(1400),1 ,0)
  #1-sum(yhat_test != y_test)/n_test ###Accuracy rate
  confusion_out = table(y = on_test$viral, yhat = yhat_test)
}
CM=colMeans(lm_lshares)
tp=CM[4]
tn=CM[1]
fp=CM[3]
fn=CM[2]
tpr = tp / (tp + fn)
tpr
fpr = fp / (fp + tn)
fpr
ACC_m3 = (tp+tn)/(tp+tn+fp+fn)
ACC_m3
ERR_m3=1-ACC_m3
ERR_m3


##Table of ACC for 4 models 
accdata = c(ACC_null,ACC_m1,ACC_km2,ACC_m3)
accdata1=t(as.data.frame(accdata))
colnames(accdata1) <- c("Accuracy Rate")
row.names(accdata1) <- c("Null Model","Linear Model","KNN Model","Linear Model (Log Shares)")
table1=kable(accdata1) 

####Table with Confusion matrix of my best Model  
CM_m3=as.data.frame(CM)
colnames(CM_m3)<-c("Linear Model Log (Shares)")
row.names(CM_m3) <- c("True Negative","False Negative","False Positive","True Positive")
table2=kable(CM_m3) 


###########################################################################3
options("jtools-digits" = 5)
export_summs(m3) ##, scale = TRUE)


###In-sample performance 
pred_fit = predict(m2, on_train)
yhat_fit = ifelse(pred_fit>log(1400),1 ,0)
confusion_in = table(y = on_train$viral, yhat = yhat_fit)
confusion_in
sum(diag(confusion_in))/sum(confusion_in) ###Accuracy rate


###Out of sample performance 
confusion_out = table(y = on_test$viral, yhat = yhat_test)
confusion_out
sum(diag(confusion_out))/sum(confusion_out) ###Accuracy rate


###############################################################
#### Approach no.2 = models with viral as dependent variable 
###### We work with the specification of model 1, but using Linear probability model,
##### a logit model and KNN for clasification

##### AVG accuracy for Linear Probability Model #4 built as a LPM model with y=viral

lpm_viral = do(100)*{
  #	resample data with replacement
  # Split into training and testing sets
  n = nrow(on)
  n_train = round(0.8*n)  # round to nearest integer
  n_test = n - n_train
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  on_train = on[train_cases,]
  on_test = on[test_cases,]
  
  
  m4 = lm(viral ~ n_tokens_title + n_tokens_content + num_hrefs + 
            num_self_hrefs + num_imgs + num_videos + 
            average_token_length + num_keywords + data_channel_is_lifestyle +
            data_channel_is_entertainment + data_channel_is_bus + 
            data_channel_is_socmed + data_channel_is_tech +
            data_channel_is_world + self_reference_avg_sharess +
            is_weekend + global_rate_negative_words + global_rate_positive_words + title_subjectivity,data=on_train)
  
  pred_test = predict(m4, on_test) #type='response'#)
  yhat_test = ifelse(pred_test> 0.5,1 ,0)
  1-sum(yhat_test != on_test$viral)/n_test ###Accuracy rate
  ###confusion_out = table(y = on_test$viral, yhat = yhat_test)
}
ACC_m4=colMeans(lpm_viral)


##### AVG accuracy for logistic Model #5 built as a logit model with y=viral
glm_viral = do(100)*{
  #	resample data with replacement
  # Split into training and testing sets
  n = nrow(on)
  n_train = round(0.8*n)  # round to nearest integer
  n_test = n - n_train
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  on_train = on[train_cases,]
  on_test = on[test_cases,]
  
    m5 = glm(viral ~ n_tokens_title + n_tokens_content + num_hrefs + 
            num_self_hrefs + num_imgs + num_videos + 
            average_token_length + num_keywords + data_channel_is_lifestyle +
            data_channel_is_entertainment + data_channel_is_bus + 
            data_channel_is_socmed + data_channel_is_tech +
            data_channel_is_world + self_reference_avg_sharess +
            is_weekend + global_rate_negative_words + global_rate_positive_words + title_subjectivity,data=on_train, family = binomial)
  
  pred_test = predict(m5, on_test,type='response')
  yhat_test = ifelse(pred_test> 0.5,1 ,0)
  ###1-sum(yhat_test != on_test$viral)/n_test ###Accuracy rate
  confusion_out = table(y = on_test$viral, yhat = yhat_test)
}
CM1=colMeans(glm_viral)
tp1=CM1[4]
tn1=CM1[1]
fp1=CM1[3]
fn1=CM1[2]
tpr1 = tp1 / (tp1 + fn1)
tpr1
fpr1 = fp1 / (fp1 + tn1)
fpr1
ACC_m5 = (tp1+tn1)/(tp1+tn1+fp1+fn1)
ACC_m5
ERR_m5=1-ACC_m5
ERR_m5


########## AVG accuracy for Model #6 built as a KNN model with y=viral
###Define subsample
##X = dplyr::select(on, n_tokens_title, n_tokens_content, num_hrefs, 
#                    num_self_hrefs, num_imgs, num_videos, 
 #                   average_token_length, num_keywords, data_channel_is_lifestyle,
  #                  data_channel_is_entertainment, data_channel_is_bus, 
   #                 data_channel_is_socmed, data_channel_is_tech,
    #                data_channel_is_world, self_reference_avg_sharess,
     #               is_weekend, global_rate_negative_words, global_rate_positive_words, title_subjectivity) 

X = dplyr::select(on, n_tokens_title, n_tokens_content, num_hrefs, 
                  num_self_hrefs, num_imgs, num_videos, 
                  average_token_length, num_keywords, self_reference_avg_sharess) 

y = on$viral


k_grid = seq(1, 100, by=5)
err_grid = foreach(k = k_grid,  .combine='c') %do% {
  knn_viral = do(2)*{
    n = length(y)
    n_train = round(0.8*n)
    n_test = n - n_train
    train_ind = sample.int(n, n_train)
    X_train = X[train_ind,]
    X_test = X[-train_ind,]
    y_train = y[train_ind]
    y_test = y[-train_ind]
    
    # scale the training set features
    scale_factors = apply(X_train, 2, sd)
    X_train_sc = scale(X_train, scale=scale_factors)
    
    # scale the test set features using the same scale factors
    X_test_sc = scale(X_test, scale=scale_factors)
    
    # Fit two KNN models (notice the odd values of K)
    knn_m5 = class::knn(train=X_train_sc, test= X_test_sc, cl=y_train, k=k)
    
    # Calculating classification errors
    sum(knn_m5 != y_test)/n_test
  } 
  colMeans(knn_viral)
}

acc_k6=1-err_grid
ACC_km6=max(acc_k6)
knngraph <- data.frame(K=c(k_grid), acc=c(acc_k6))

colnames(knngraph) <- c("k","AVG_ACC")
k_min = knngraph$k[which.max(knngraph$AVG_ACC)]
###########Graph ACC vs k ################
plotknn= ggplot(data = knngraph)+
  geom_line(aes(x = k, y = AVG_ACC))+
  geom_line(aes(x =k_min , y = AVG_ACC), col = "blue")+
  geom_line(aes(x= k, y = ACC_m4))+
  geom_line(aes(x= k, y = ACC_m5))+
  labs(title="KNN's Models for Viral ", 
       x="K",
       y = "ACC")
plotknn


######Comparison Table 

##Table of ACC for 3 Binary models 
accdata2 = c(ACC_m4,ACC_m5,ACC_km6)
accdata21=as.data.frame(accdata2)
colnames(accdata21) <- c("Accuracy Rate")
row.names(accdata21) <- c("Linear Probability Model","Logit Model","KNN Classification Model")
table3=kable(accdata21) 
table3

####Table with Confusion matrix of my best Model  
CM_m5=as.data.frame(CM1)
colnames(CM_m5)<-c("Logit Model")
row.names(CM_m5) <- c("True Negative","False Negative","False Positive","True Positive")
table4=kable(CM_m5) 
table4

###### Coefficients of our best model 
options("jtools-digits" = 5)
export_summs(m5) ##, scale = TRUE)

##### Average Marginal Effect 
margins_m5=margins(m5, type='response')
table5=kable(summary(margins_m5)) 
table5