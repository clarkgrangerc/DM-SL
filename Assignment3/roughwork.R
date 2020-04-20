library(ggplot2)
library(LICORS)  # for kmeans++
library(foreach)
library(mosaic)
library(cluster)
library(simEd)
library(factoextra)


social_marketing= read.csv('social_marketing.csv', header=TRUE)
summary(social_marketing)

ggplot(social_marketing, aes(x= chatter))+ geom_boxplot()

ggplot(data = social_marketing, aes(x = variable, y = social_marketing[,-1])) + geom_boxplot() 


boxplot(social_marketing[,-c(1, 12:37)], outline= FALSE)


mai = melt(social_marketing, id.var = "X" )

ylim1 = boxplot.stats(social_marketing[,-1])$stats[c(2, 37)]

X = social_marketing[,-1]
X = scale(X, center=TRUE, scale=TRUE)

eclust(X, k=12, graph = TRUE)

clust1 = kmeans(X, 12, nstart=25)
fviz_cluster(clust1 , data = X, choose.vars= c(8,13), geom= "point")


PCAs = prcomp(X, scale=TRUE)

fviz_pca_var(PCAs,axes = c(2, 3), col.var="contrib",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE, title = "Variables Contribution in first two PCAs " )
