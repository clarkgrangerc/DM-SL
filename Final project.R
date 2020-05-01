library(tidyverse)
library(LICORS)
library(factoextra)
library(reshape2)

ad = filter(loan, loan_status != "Current")
ad = filter(ad, application_type != "Joint App")
ad = filter(ad, term != "36 months")

ab= ad[c(1:20000),]

ab= ab[, -c(96)]
data = ab[,c() ]


summary(a$loan_status)
tab(ab$loan_status)
table(ab$home_ownership, ab$home)


ab = mutate(ab, loan_status1 = ifelse(ab$loan_status =="Fully Paid",1,ifelse(ab$loan_status =="Charged off", 2, ifelse(ab$loan_status =="In Grace Period", 3, ifelse(ab$loan_status =="Late (16-30 days)", 4, ifelse(ab$loan_status =="Default",5,6))))))

ab = mutate(ab, emp = ifelse(ab$emp_length =="< 1 year",0,ifelse(ab$emp_length =="1 year", 1, ifelse(ab$emp_length =="2 years", 2, ifelse(ab$emp_length =="3 years", 3, ifelse(ab$emp_length =="4 years",4,
                                                                                                                                                                               ifelse(ab$emp_length =="5 years",5, ifelse(ab$emp_length =="6 years",6,ifelse(ab$emp_length =="7 years",7,ifelse(ab$emp_length =="8 years",8,ifelse(ab$emp_length =="9 years",9,ifelse(ab$emp_length =="10+ years",10,99))))))))))))
ab= mutate(ab, empl_length = factor(ab$emp_length))
ab= mutate(ab, home = as.numeric(ab$home))


#########Separating the working data from main data
data= ab[, c(3,7,9,14,15,19,22,23,25,28,32,42,99,98,96)]
data= mutate(data, loan_purpose = factor(data$purpose))
data= mutate(data, loan_purpose = as.numeric(data$loan_purpose))
data= mutate(data, delinq = ifelse(loan_status1 == 1, 1,0))
data2= melt(data[, -c(3,5,6, 15)], id.vars = "delinq")
ggplot(data = data2, aes(x=factor(delinq), y=value)) + geom_boxplot()+ facet_wrap(~variable, scales = "free") 


####### Creating a dataset for scaling

X= data[, -c(3,5,6,15,16)]
X = scale(X, center = TRUE, scale = TRUE)

############Running k means clustering
clust1 = kmeans(X, centers = 2, nstart = 50)

table(data$delinq, clust1$cluster)

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

clust4= kmeans(PCA, centers= 2,  nstart = 50) 
table(data$delinq, clust4$cluster)





memory.limit(size = 16000 )  


write.csv(ab, "D:/Casual_inference/Research Project/Data/IPUMS microdata/ loan.csv", row.names = TRUE)
