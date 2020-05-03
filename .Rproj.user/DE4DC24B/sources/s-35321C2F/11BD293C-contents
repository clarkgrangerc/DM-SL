library(tidyverse)
library(LICORS)
library(factoextra)
library(reshape2)
library(foreach)
library(mosaic)
library(arules)

loan <- read.csv('loanadj.csv')
data = filter(loan, loan_status != "Current")

k = 
data(AdultUCI)

summary(data)
tab(ab$loan_status)
table(ab$home_ownership, ab$home)


data = mutate(data, loan_status1 = ifelse(data$loan_status =="Fully Paid",1,ifelse(data$loan_status =="Charged off", 2, ifelse(data$loan_status =="In Grace Period", 3, ifelse(data$loan_status =="Late (16-30 days)", 4, ifelse(data$loan_status =="Default",5,6))))))

data = mutate(data, emp_year = ifelse(data$emp_length =="< 1 year",0,ifelse(data$emp_length =="1 year", 1, ifelse(data$emp_length =="2 years", 2, ifelse(data$emp_length =="3 years", 3, ifelse(data$emp_length =="4 years",4,
                                                                                                                                                                               ifelse(data$emp_length =="5 years",5, ifelse(data$emp_length =="6 years",6,ifelse(data$emp_length =="7 years",7,ifelse(data$emp_length =="8 years",8,ifelse(data$emp_length =="9 years",9,ifelse(data$emp_length =="10+ years",10,11))))))))))))
data= mutate(data, home = factor(data$home_ownership))
data= mutate(data, home = as.numeric(data$home))
data= mutate(data, loan_purpose = factor(data$purpose))
data= mutate(data, loan_purpose = as.numeric(data$loan_purpose))
data= mutate(data, delinq = ifelse(loan_status1 == 1, 1,0))
data= mutate(data, term1 = factor(data$term))
data= mutate(data, term1 = as.numeric(data$term1))
data = mutate(data, verify = ifelse( verification_status == "Verified" & verification_status =="Source Verified", 1,2))
data[is.na(data)]= 0
data = mutate(data, app_type = ifelse( application_type == "	Joint App", 1,2))


#########Separating the working data from main data
data1= data[, -c(1,3,6,7,8,9,11,12,13,14,25,58,67)]
data= mutate(data, loan_purpose = factor(data$purpose))
data= mutate(data, loan_purpose = as.numeric(data$loan_purpose))
data2= melt(data[, -c(3,5,6, 15)], id.vars = "delinq")
ggplot(data = data2, aes(x=factor(delinq), y=value)) + geom_boxplot()+ facet_wrap(~variable, scales = "free") 


####### Creating a dataset for scaling

X= data1[, -c(59,61,62)]
X = scale(X, center = TRUE, scale = TRUE)

length(which(is.na(X)))

############Running k means clustering
clust1 = kmeans(X, centers = 2, nstart = 50)

table(data1$delinq, clust1$cluster)

############ Running k++ means clustering
clust2 = kmeanspp(X, k=6, nstart = 50)
table(data$loan_status1, clust2$cluster)

########## Hiearchial clusters
x_dist = dist(X, method = 'euclidean')
clust3 = hclust(x_dist, method ='average')
c1 = cutree(clust3, 6)
table(data$loan_status1, c1)

plot(clust3, cex=0.3)


########### PCA method

x_pc = prcomp(X, scale.=TRUE)
biplot(x_pc)
scores = x_pc$x
PCA= scale(scores, center = TRUE, scale = TRUE)
summary(x_pc)
plot(x_pc)

clust4= kmeans(PCA, centers= 2,  nstart = 50) 
table(data1$delinq, clust4$cluster)




############ Running a logit model on PCA
#### Running a logit regression with PCA

color = data.frame(cbind(data1$delinq, scores))
summary(color)
n= nrow(color)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train



logit_color = do(300)*{
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  color_train = color[train_cases,]
  color_test = color[test_cases,]
  lm1 = glm( V1 ~ PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10+PC11+PC12+
             PC13+PC14+PC15+PC16+PC17+PC18+PC19+PC20+PC21+PC22+PC23+PC24+PC25, data= color_train, family = binomial(link = "logit"))
  
  yhat= predict(lm1, color_test, type="response")
  yhat = ifelse(yhat>0.5, 1, 0)
  error_rate = (length(which(yhat != color_test$V1))/length(yhat))}

errorrate = mean(logit_color$result, na.rm = FALSE)


################### Using only charged off and time paid lones

data2 = filter(data, loan_status == "Fully Paid" | loan_status == "Charged Off")
summary(data2)
Y= data2[, -c(1,3,6,7,8,9,11,12,13,14,25,34,67, 70, 71, 72, 73, 74)]
Y = scale(Y, center = TRUE, scale=TRUE) 

y_pc = prcomp(Y, scale. = TRUE)
score_Y= y_pc$x


color1 = data.frame(cbind(data2$delinq, score_Y))

n= nrow(color1)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train


logit_color2 = do(300)*{
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  color_train = color1[train_cases,]
  color_test = color1[test_cases,]
  lm1 = glm( V1 ~ PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10+PC11+PC12+
               PC13+PC14+PC15+PC16+PC17+PC18+PC19+PC20+PC21+PC22+PC23+PC24+PC25, data= color_train, family = binomial(link = "logit"))
  
  yhat= predict(lm1, color_test, type="response")
  yhat = ifelse(yhat>0.5, 1, 0)
  error_rate = (length(which(yhat != color_test$V1))/length(yhat))}
errorrate = mean(logit_color2$result, na.rm = FALSE)




rm(ab, ad)


memory.limit(size = 16000 )  


write.csv(ab, "D:/Casual_inference/Research Project/Data/IPUMS microdata/ loan.csv", row.names = TRUE)
