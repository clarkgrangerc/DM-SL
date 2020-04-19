library(ggplot2)
library(tidyverse)
library(dplyr)
library(foreach)
library(mosaic)
library(LICORS)
library(factoextra)
library(reshape2)

rm(list = ls(all.names = TRUE))
getwd()

rm(all)

#### Reading data files
wine= read.csv("wine.csv")


head(wine)

red = filter(wine, color == "red")
white = filter(wine, color == "white")

summary(red)
summary(white)

#### box plots for both colors against different variables
wine2= melt(wine[,-c(12,14)], id.vars = "color")
ggplot(data = wine2, aes(x=factor(color), y=value)) + geom_boxplot()+ facet_wrap(~variable, scales = "free") 
  

## SCaling of data
X = wine[,-(12:13)]
X = scale(X, center = TRUE, scale = TRUE)

### calculating means and sd
mu = attr(X,"scaled:center")
sigma = attr(X, "scaled:scale")

### clustering with kmeans 2 clusters
clust1 = kmeans(X, centers = 2, nstart = 25)

clust1$center[1,]*sigma + mu
error1 = table(wine$color, clust1$cluster) 




qplot(fixed.acidity, volatile.acidity, data=wine, color=factor(clust1$cluster))
qplot(fixed.acidity, residual.sugar, data=wine, color=factor(clust1$cluster))
qplot(chlorides, residual.sugar, data=wine, color=factor(clust1$cluster))
qplot(total.sulfur.dioxide,chlorides, data=wine, color=factor(wine$color), shape = factor(clust1$cluster))+ggtitle("Cluster Plot with Wine Color and Differentiating features")


eclust(X, "kmeans", k = 2)


error1

er = cro(wine$color, clust1$cluster)
er
### clustering with kmeans++ initialization
clust2 = kmeanspp(X, k=2, nstart=50)

error2 = table(wine$color, clust2$cluster)
error2
clust1$withinss
clust2$withinss

sum(clust1$withinss)
sum(clust2$withinss)

clust1$tot.withinss
clust2$tot.withinss

##### clustering for wine quality

### creating a binary variable for quality
wine = mutate(wine, QL = ifelse(quality > 5, 1, 0))


hist(wine$quality, xlab = "Wine Quality", main = "Histogram of Wine Qualities")

clust_ql= kmeans(X, centers=7, nstart=30)
error_ql =table(wine$quality, clust_ql$cluster)
error_ql  
err_ql = table(wine$QL, clust1$cluster)
err_ql


clu = kmeanspp(X, k=7, nstart = 30)
table(wine$quality, clu$cluster)


### weighted kmeans
Y= data.frame(X)
Y= mutate(Y , chlorides = chlorides*1.05, total.sulfur.dioxide = total.sulfur.dioxide*1.05, sulphates = 1.05*sulphates)
clust4= kmeans(Y, centers = 2, nstart = 50)
table(wine$color, clust4$cluster)
eror3


###Hiearchial clusters
x_dist = dist(X, method = 'euclidean')
h1 = hclust(x_dist, method ='average')
c1 = cutree(h1, 5)
error4 = table(wine$color, c1)
error4

rm(error,error1,error2,error3, error4, error5, error6, error7)

plot(h1, cex=0.3)

ggplot(final) + geom_point(aes(x=residual.sugar, y=chlorides,col=factor(color)),alpha = 0.4, size = 3.5) + 
  geom_point(aes(density))

ggplot(final, aes(residual.sugar, chlorides, col = factor(color)), alpha = 0.4, size = 3.5)+ geom_point(col = factor(c1))

h2= hclust(x_dist, method = "complete")
c2 = cutree(h2,6)
final = cbind(final, c2)
error4= table(final$color, final$c2)
summary(factor(c1))

h3= hclust(x_dist, method = "average")
c3= cutree(h3, 2)
final = cbind(final, c3)
error5 = table(final$color, final$c3)
error5

h4= hclust(x_dist, method = "centroid")
c4 = cutree(h4, 2)
final= cbind(final, c4)
error6 = table(final$color, final$c4)
error6

##### PCA method####### 

Y = wine[, -c(12,13,14)]
pairs(Y)
wine_pc = prcomp(Y, scale.=TRUE)

summary(wine_pc)
plot(wine_pc)

fviz_screeplot(wine_pc, addlabels = TRUE, ylim = c(0, 35), main = "% of Variation Explained by each PCAs")

fviz_pca_var(wine_pc, col.var="contrib",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE, title = "Variables Contribution in first two PCAs " )


biplot(wine_pc)
loadings =wine_pc$rotation
scores = wine_pc$x
qplot(scores[,1], scores[,2], color= wine$color, xlab='Component 1', ylab='Component 2')

qplot(scores[,1], scores[,2], color= wine$quality, shape= factor(wine$quality), xlab='Component 1', ylab='Component 2')

autoplot(prcomp(Y), data = wine, color = 'color')

#### PCA graph against color of wine
fviz_pca_ind(wine_pc, geom.ind = "point", pointshape = 21, 
             pointsize = 2, 
             fill.ind = wine$color,
             col.ind = "black", 
             palette =  c("red", "grey"), 
             addEllipses = TRUE,
             label = "var",
             col.var = "black",
             repel = TRUE,
             legend.title = "Color") +
  ggtitle("2D PCA-plot for Wine Colors") +
  theme(plot.title = element_text(hjust = 0.5))

####clustering with PCA values
PCA = scale(scores, center = TRUE, scale = TRUE)
clustpc = kmeans(PCA, centers = 2, nstart = 50)
errorr2 = table(wine$color, clustpc$cluster)
errorr2

clustquality = kmeans(PCA, centers= 7, nstart = 50)
errorclquality = table(wine$quality, clustquality$cluster)
errorclquality

pander

color = data.frame(cbind(wine$color, scores))
color = mutate(color, V1 = ifelse(V1 ==2, 1,0))
lm1 = glm(V1 ~ PC1+PC2+PC3+PC4+PC5+PC6, data= color, family = binomial(link = "logit"))
color = mutate(color, pred = predict(lm1, color[,-1], type = "response"))
color = mutate(color, pred= ifelse(pred > 0.5, 1, 0))
color= color[,-13]

error = table(color$V1, color$pred)
error
summary(lm1)

#### Running a logit regression with PCA

n = nrow(color)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train


logit_color = do(300)*{
      train_cases = sample.int(n, n_train, replace=FALSE)
      test_cases = setdiff(1:n, train_cases)
      color_train = color[train_cases,]
      color_test = color[test_cases,]
      lm1 = glm(V1 ~ PC1+PC2+PC3+PC4+PC5+PC6, data= color_train, family = binomial(link = "logit"))

      yhat= predict(lm1, color_test, type="response")
      yhat = ifelse(yhat>0.5, 1, 0)
      error_rate = (length(which(yhat != color_test$V1))/length(yhat))}
errorrate = mean(error_rate, na.rm = FALSE)



