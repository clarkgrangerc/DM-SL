#loading library
library(tidyverse)
library(ISLR)
library(mosaic)
library(foreach)
library(cluster)
library(ggalt)
library(ggfortify)

install.packages('ggfortify')

#loading data set
data_file<-'https://raw.githubusercontent.com/jgscott/ECO395M/master/data/wine.csv'
wine<-read.csv(url(data_file))
head(wine)
#take out numerical variables for dimensional reduction and clustering
wine_data = wine[,c(1:11)]


#Rescale and normalize the data
wine_data = scale(wine_data, center = TRUE , scale =TRUE)

#Cluster to red wine and white wine
#Elbow plot to find optimum k
k_grid = seq(2, 20, by=1)
SSE_grid = foreach(k = k_grid, .combine='c') %do% {
  cluster_k = kmeans(wine_data, k, nstart=10)
  cluster_k$tot.withinss
}
plot(k_grid, SSE_grid)

#Double check using CH index
CH_grid = foreach(k = k_grid, .combine='c') %do% {
  cluster_k = kmeans(wine_data, k, nstart=30)
  W = cluster_k$tot.withinss
  B = cluster_k$betweenss
  CH = (B/W)*((N-k)/(k-1))
  CH
}
plot(k_grid, CH_grid)
which.max(CH_grid)
#The optimum cluster is 
k_grid[which.max(CH_grid)]

#Test using gap statistic
### take very long ###
wine_gap = clusGap(wine_data, FUN = kmeans, nstart = 10, K.max = 10, B = 10)
plot(wine_gap)

#using pH and density as 2 covariables for displaying cluster
clust = kmeans(wine_data, 3, nstart=10)
qplot(wine$density,wine$pH, data=wine, shape=factor(clust$cluster), col=factor(wine$color))

#combine cluster id for each observation
wine$cluster[which(clust$cluster == 1)] = 1
wine$cluster[which(clust$cluster == 2)] = 2
wine$cluster[which(clust$cluster == 3)] = 3

df_wine   <- data.frame(wine, Species=wine$color)
df_wine_1 <- wine[wine$cluster == 1, ]  # df for cluster 1
df_wine_2 <- wine[wine$cluster == 2, ]  # df for cluster 2
df_wine_3 <- wine[wine$cluster == 3, ]  # df for cluster 3

#cluster result
xtabs(~clust$cluster + wine$color)
table = xtabs(~clust$cluster + wine$color)

#PCA for wine quality
pr_wine = prcomp(wine_data, scale = TRUE)
scores = pr_wine$x
loadings = pr_wine$rotation

#apply PCA to cluster
clustPCA = kmeans(scores[,1:3], 3, nstart=10)
qplot(scores[,1], scores[,2], color=factor(wine$color), shape=factor(clustPCA$cluster), xlab='Component 1', ylab='Component 2')


#plotting the cluster
theme_set(theme_classic())
pca_mod <- prcomp(wine_data)  # compute principal components

df_pc <- data.frame(pca_mod$x, Species=wine$cluster, quality=wine$quality, color=wine$color)  # dataframe of principal components
df_pc$Species =factor(df_pc$Species)
df_pc_cluster1 <- df_pc[df_pc$Species == 1,]  # df for cluster 1
df_pc_cluster2 <- df_pc[df_pc$Species == 2,]  # df for cluster 2
df_pc_cluster3 <- df_pc[df_pc$Species == 3,]  # df for cluster 3


ggplot(df_pc, aes(PC1, PC2, col=Species)) + 
  geom_point(aes(shape=color), size=2) +   # draw points
  labs(title="Wine Clustering", 
       subtitle="With principal components PC1 and PC2 as X and Y axis",
       caption="Source: Iris") + 
  coord_cartesian(xlim = 1.2 * c(min(df_pc$PC1), max(df_pc$PC1)), 
                  ylim = 1.2 * c(min(df_pc$PC2), max(df_pc$PC2))) +   # change axis limits
  geom_encircle(data = df_pc_cluster1, aes(x=PC1, y=PC2)) +   # draw circles
  geom_encircle(data = df_pc_cluster2, aes(x=PC1, y=PC2)) +
  geom_encircle(data = df_pc_cluster3, aes(x=PC1, y=PC2))

#plotting the cluster
theme_set(theme_classic())
pca_mod <- prcomp(wine_data)  # compute principal components

df_pc <- data.frame(pca_mod$x, Species=wine$color)  # dataframe of principal components
df_pc_red <- df_pc[df_pc$Species == "red", ]  # df for 'virginica'
df_pc_white <- df_pc[df_pc$Species == "white", ]  # df for 'setosa'

#df_pc_ver <- df_pc[df_pc$Species == "versicolor", ]  # df for 'versicolor'

ggplot(df_pc, aes(PC1, PC2, col=Species)) + 
  geom_point(aes(shape=Species), size=2) +   # draw points
  labs(title="Iris Clustering", 
       subtitle="With principal components PC1 and PC2 as X and Y axis",
       caption="Source: Iris") + 
  coord_cartesian(xlim = 1.2 * c(min(df_pc$PC1), max(df_pc$PC1)), 
                  ylim = 1.2 * c(min(df_pc$PC2), max(df_pc$PC2))) +   # change axis limits
  geom_encircle(data = df_pc_red, aes(x=PC1, y=PC2)) +   # draw circles
  geom_encircle(data = df_pc_white, aes(x=PC1, y=PC2))


# The top characteristics associated with each component
top1 = order(loadings[,1], decreasing=TRUE)
colnames(X)[top1]
top2 = order(loadings[,2], decreasing=TRUE)
colnames(X)[top2]
top3 = order(loadings[,3], decreasing=TRUE)
colnames(X)[top3]

#now cluster into quality from 1-10 #only range from 3 - 9
factor(wine$quality)

#looking at the distribution of the wine quality
ggplot(wine)+
  geom_bar(aes(x = quality))

#kmean cluster, still 3 for optimal cluster for 3-9 quality
clust2 = kmeans(X, 3, nstart=10)

# table for the correctly clustering
xtabs(~clust2$cluster + wine$quality)
table2 = xtabs(~clust2$cluster + wine$quality)

#need to find a good representation of cluster
ggplot(wine)+ geom_density(aes(x = clust2$cluster, col = factor(wine$quality), fill = factor(wine$quality)))
ggplot(wine)+ geom_density(aes(x = wine$quality, col = factor(wine$quality), fill = factor(wine$quality)))

#apply PCA before clustering
pr_wine2 = prcomp(data_wine, scale=TRUE)
loadings = pr_wine2$rotation
scores = pr_wine2$x

# PCA for clustering
clustPCA2 = kmeans(scores[,1:4], 3, nstart=10)
qplot(scores[,1], scores[,2], color=factor(wine$quality), shape = factor(clustPCA2$cluster) , xlab='Component 1', ylab='Component 2')

# table for the correctly clustering
xtabs(~clustPCA2$cluster + wine$quality)
tablePCA = xtabs(~clustPCA2$cluster + wine$quality)
