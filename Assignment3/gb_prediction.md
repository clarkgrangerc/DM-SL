Assignment 3
============

Group Members: Clark Granger, Zachary Carlson and Zargham Khan
==============================================================

Question 1. Predictive model for Green Buildings
------------------------------------------------

Using the data on 7,984 commercial rental properties from the United
States, the goal is to build a predictive model for rental income per
square foot. To build the model we have several key features of each
property such as size in square foot, leasing rate, number of stories,
amenities, among others. We also have information about building’s
“neiborhood”, weather in the area and kind of contract that the property
offers. Beyond the amount of variables we have, we are specially
interested in quantifying the average change in rental income per square
foot associated with green certification, holding other features of the
building constant. In this dataset, 685 properties have been awarded
either LEED or EnergyStar certification as a green building.

To adress this problem we use different approachs we have seen in class.
The first approach is from the point of view of linear models, including
model regularization techniques and stepwise selection. In the second
approach we use a Lasso regression model and cross validation, to try to
find a best model. Finally we implement tree models, random forest and
boosting.

### Approach \#1 Linear models and stepwise selection

To start we cleaned our database eliminating the properties that are
without occupation and the entries with missing data. After that, we
proceed creating a model that include variables we consider are relevant
to explain the rent price. It is important to remark that we decided
working with the variable that summarize green rating which takes value
of 1 if the property has at least one green certifification and zero
otherwise. Then, the first model we fitted is a linear one, called
manual, that include most of the variables available, we mainly dropped
variables that seemed to do not explain to much in our model. These
variableswere property ID, precipitation days, cold and hot degree days,
however we included total degrees days. After the first model, we
regress a second one with the same varianles but now considering all the
interactions between covariates. Having our two first models, the next
step was working with the function step to look for a model that
improves the AIC of the previous ones. To do that we created a null
model and ran the function step to find a better model based on the
scope of variables of the two originals models. After we got the new 2
models, we splitted up our sample in a train and test subsamples. To
validate our models we generated out of sample RMSEs boostrapping our
data.

**Table 1. RSME, AIC and BIC for linear models**

|                              |  RMSE|       AIC|       BIC|   DF|
|------------------------------|-----:|---------:|---------:|----:|
| Model 1: Manual built        |  9.56|  56261.86|  56386.87|   18|
| Model 2: Interactions        |  9.24|  55658.25|  56609.70|  137|
| Model 3: Manual built + step |  9.56|  56258.53|  56362.70|   15|
| Model 4: Interactions + step |  9.22|  55690.84|  55920.03|   33|

Table 1 summarizes the information of the four linear models we built.
we can see that the model with the lowest RMSE is the model 4 generated
by the step function based on the all interactions model. We can also
see that this model has the second lowest AIC, only improved by model 2.
However, we decided to include BIC criteria too, since it penalizes the
number of coefficientes included in a model. With this criteria, the
model 4 is the better, considering it is a more parsimonious model than
model 2.

### Approach \#2 Lasso Regression: Variable Selection and Regularization

The second approach is from the point of view of lasso regression.
Working with the same data as the linear models, the only extraa step we
needed to take before start with lasso models was the creation of sparse
matrices for training and testing subsamples. The sparse matrices
included the same variables of our manual linear model plus all the
interactions, the last in order to have and equivalent scope of linear
models. We went straight to use the cross validation function to find
the best lasso model to predict rent. The cross validation function
finds the lasso model tha minimized the lambda and drops all the
coefficients that are close to be zero. We know when lambda is close to
zero the betas found by lasso are essentially the least squares
estimates. Thus, we implemented a cross validation lasso regression
considering 10 folds and bostrapped again the process several times.

**Table 2. Evaluation of Lasso Model**

|                        |  Model 5: Lasso Model|
|------------------------|---------------------:|
| RMSE                   |                  9.34|
| Log Lambda             |                 -2.17|
| Number of coefficients |                 31.80|

Table 2 contains the average results of the lasso cross validation. The
model found has in average a log lambda of -2.1682685 and in average
includes 31.8 coefficients. However, the findings suggests that the
lasso selected model does not improve the best linear model built in the
previous section according with the boostrapped out of sample RSME
computed. In graph 1, we show the evolution of a lasso regression for
one case. We can appreciate how lasso approach found the minimum RMSE in
a number of coefficients similar to the coefficients included in the
best linear regression. The last reinforces that the linear model could
be a good predictor of rent price.

**Graph 1. Lasso model: Errror vs Log Lambda**
![](gb_prediction_files/figure-markdown_github/unnamed-chunk-6-1.png)

### Approach \#3 Tree Models, Random Forest and Boosting

As a final approach, we work with tree models, random forest and
boosting. First we worked with a simple tree model to predict rent
price. About trees we known that they are good to manipulate large
dataset and to ignore redundant data, we know they are not the best
model to prediction though. A full tree was grown on the training set,
with splitting continuing until a minimum bucket size of 5 was reached.
This tree was pruned, and the tree size was chosen by 10-fold
cross-validation. we repeated this approach several times by data
boostrapping to generate out of sample RMSEs. After the simple tree, we
proceeded with a random forest. This method fit many large trees to
bootstrap-resampled versions of the training data by relevance. We
created 500 trees by random forest including a minimum of 5 features per
bucket, and later we compute the out of sample RMSE. Finally, we
performed a boosting model, that mainly fits several trees to reweighted
versions of the training dataset and then classifies by weighted
majority relevance. We fitted 5000 trees by this method with a shrinkage
factor of 0.05.

**Table 3. Tree, Random Forest and Boosting comparative**

|                       |  RMSE|
|-----------------------|-----:|
| Model 6: Tree model   |  9.12|
| Model 7:Random Forest |  6.27|
| Model 8: Boosting     |  8.65|

Table 3 summarizes the RMSE of the last tree model fitted. We can see
that when the simple tree model does not improve the previous models,
the random forest model and the boosting model certainly outperfom all
the models. The best model we have built to predict the rent price per
square foot so far is the random forest model with the least out of
sample RMSE. However, now we face the problem that random forest model
are certainly not interpretable and we want to know the partial effect
of being a green building over price. Despite of this limitation random
forest models allow us to get a importance meaure of each variable in
the model.It just adds up how much the error decreases every time a
variable is used in a split. This information is contained in graph 2.
we can observe that the most importan variable is the rent price in the
cluster where our property is located, followed by size and so on.

**Graph 2. Varibale importance (Random Forest)**
![](gb_prediction_files/figure-markdown_github/unnamed-chunk-9-1.png)

### Concluding Remarks

With data on 7,984 commercial rental properties from the United States,
we built eight models to predict the rent price per square foot. The
approaches implemented varie from linear models, going throug step
selection, lasso regression until to tree models, random forest and
boosting. The out of sample results suggets that the model with the
lowest error is the random forest model with a RMSE of 6.2696597. We
also were requested to find the the average change in rental income per
square foot associated with green certification. Given the barrier we
have to get this kind of interpretation from a random forest model. We
computed the average marginal effect of being a green building from the
best linear model we fitted (Model 4). The results suggest that having a
green certification leads an increasing in 1.307 dollars per square foot
in rent price. This result makes sense since green building properties
have positive features such as lower energy compsumption levels,
variable that according with our random forest model is important to
explain rent price.

Question. 2: What causes what?
------------------------------

### Part A.

Running a simple regression of crime on police will give us correlation
between these two variables but it will not help us identify if one
causes the other. It might be a case that crime affects police number
because police numbers are apportioned by authority based on
predetermined crime rates of areas. So a simple regression will be
spurious and will not help us identify if higher crime leads to higher
police number or vice versa.

Even if the casual effect of police is negative but the regression might
pick postive correlation due to high police in high crime areas which
might lead people to infer that higher police causes higher crime rate.
So a regression co-efficient always does not show what causes what. It
just gives us correlation between two variables.

### Part B.

The researchers from UPenn came up with a technqiue called intrumental
variable in which they use an exogenous shock to police numbers in
district one of Washington DC. They came up with a dummy variable of
High Alert for days when a high alert was issued due to potential
terrorist threat and that led to a higher than usual number of police in
the streets of district one. This means that they came up with a
variable that only affected the number of police numbers in district one
without having any affect on crime rate.

Through the increase in police number due to high alert, the researchers
try to look at the casual effect of higher police on crime rate. They
compare the crime rate of district one on high alert days with other
adjoining districts where police number on streets remain unchanged. So
district one had more police on these days as compared to other
districts.

Table 2 gives us coeffcient for high alert days which can be interpreted
as a reduction of average 7.3 crimes on high alert days as compared to
usual or normal days. This shows that high number of police on high
alert days lead to a decrease in crime numbers.

### Part C

The main purpose of including this variable is to control for any change
in number of public and tourists on high alert days. This approach helps
in negating the assumption that crime rate decreases on high alert days
because there are fewer people/ tourists on streets and so less
oppurtunity for crime. The table shows that even after controlling for
metro ridership, we see only a small change in coefficient for high
alert day. Thus, high alert is only affecting crime through higher
number of police and not through any other means.

### Part D

From the above regression, we can see that researchers are comparing
crime numbers in district one with other districts on high alert days.
If only district one witness an increase in police on high alert days,
then the decrease in crime rate in district one should be significantly
higher than other districts. The table clearly shows this as we look at
(Highalert\*District one) coefficient that shows a statistically
significant decrease of average 2.8 crimes on high alert days in
district one as compared to other districts of Washington that do not
show any significant change. The model also includes days fixed effects,
day of the week dummies, district fixed effects and district offense
fixed effects to isolate the casual effect of police on crime number.

Question.3: Clustering and PCA - Wines
--------------------------------------

In this question we are provided with a dataset of more than six
thousand different wines with their 11 chemical properties and two
outcome variables quality and color. The task at hand is to employ
unsupervised learning techniques and classify these wines into groups/
clusters based on color and quality.

We start with classfication of wines based on its color. We have two
colors; red and white. We plot boxplots of wine color against their
chemical properties to see which properties are different across these
two colors. We see that amount of chlorides, total sulfur dioxide and
volatile acidity are major variables that have different distribution
for red and white wines.

<img src="gb_prediction_files/figure-markdown_github/unnamed-chunk-11-1.png" style="display: block; margin: auto;" />

### Clustering Kmeans and Kmeanspp

We run a simple kmeans clustering technique and chose centers as 2
because we already know how many groups we have to classify our data
into i.e. 2 colors. The result of kmeans clustering in the table below
shows that it separates wines based on its color quite successfully.
Only 24+68 = 92 wines out of 6,497 wines have been misclassified by this
method. The error rate is 1.416 percent.

Quitting from lines 322-327 (gb\_prediction.Rmd) Error in
table(wine*c**o**l**o**r*, *c**l**u**s**t*1cluster) : object ‘clust1’
not found Calls: <Anonymous> … withCallingHandlers -\> withVisible -\>
eval -\> eval -\> pander -\> table In addition: Warning messages: 1:
package ‘Metrics’ was built under R version 3.6.3 2: package ‘gamlr’ was
built under R version 3.6.3 3: package ‘margins’ was built under R
version 3.6.3 4: package ‘caret’ was built under R version 3.6.3 5:
package ‘knitr’ was built under R version 3.6.2 6: package
‘randomForest’ was built under R version 3.6.3 7: package ‘gbm’ was
built under R version 3.6.3

We also plot clusters along with wine colors on a graph with two major
differentiating chemical properties. White wines have more total sulfur
dioxide content whereas red wines have more chlordies.

<img src="gb_prediction_files/figure-markdown_github/pressure-1.png" style="display: block; margin: auto;" />

We also employ kmeans++ clustering and it gives us the same result as
kmeans clustering which can be seen in the table below.

<table style="width:36%;">
<caption>Wine Color on Vertical axis vs Cluster group on Horizontal axis for kmeans++ Clustering</caption>
<colgroup>
<col style="width: 16%" />
<col style="width: 9%" />
<col style="width: 9%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;"> </th>
<th style="text-align: center;">1</th>
<th style="text-align: center;">2</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;"><strong>red</strong></td>
<td style="text-align: center;">24</td>
<td style="text-align: center;">1575</td>
</tr>
<tr class="even">
<td style="text-align: center;"><strong>white</strong></td>
<td style="text-align: center;">4830</td>
<td style="text-align: center;">68</td>
</tr>
</tbody>
</table>

However when using hiearchial clustering, we do not see see clustering
based on color of wines. By cutting tree at 2 we get almost all wines
sorted into one cluster. Even with cutting tress at 5 or 10 levels, we
dont see any balance in the distribution of wines into different
clusters. It looks to be a very uneven hiearchial clustering. We try all
distance measuring approaches but they all give similar results.

<table style="width:32%;">
<caption>Wine Color on Vertical axis vs Cluster group on Horizontal axis for Hiearchial Clustering</caption>
<colgroup>
<col style="width: 16%" />
<col style="width: 9%" />
<col style="width: 5%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;"> </th>
<th style="text-align: center;">1</th>
<th style="text-align: center;">2</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;"><strong>red</strong></td>
<td style="text-align: center;">1599</td>
<td style="text-align: center;">0</td>
</tr>
<tr class="even">
<td style="text-align: center;"><strong>white</strong></td>
<td style="text-align: center;">4897</td>
<td style="text-align: center;">1</td>
</tr>
</tbody>
</table>

### PCA

We now use PCA and transform our data accordingly. We get 11 PCAs which
are plotted in scree plot below. If we look at first PCA, we see that
the main contributers of variation are total sulfur dioxide,chlorides
and volatile acidity which are also the main variables that
differentiate red from white wines. Thus first PCA is capturing
variations between red and white wines. Overall, first 6 PCAs explain
85% of total variation in our dataset of wines.

<img src="gb_prediction_files/figure-markdown_github/unnamed-chunk-15-1.png" style="display: block; margin: auto;" /><img src="gb_prediction_files/figure-markdown_github/unnamed-chunk-15-2.png" style="display: block; margin: auto;" />

We plot our graph for first two PCAs and color the points with color of
wines. We can clearly see that PCA1 on the x-axis is differentiating
white wines from red wines. So we can say that PCA1 is explaining color
variation of wines.

<img src="gb_prediction_files/figure-markdown_github/unnamed-chunk-16-1.png" style="display: block; margin: auto;" />

Now, we use our principal components to run kmeans clustering again to
see if we get any better performance than simple kmeans clustering on
original scaled data. With clustering on PCAs we see a further reduction
in our classification error. Now we only have 37 wines misclassified
which equals to an error rate of 0.5%. We can also run a logit model on
PCAs but since the question asks us to use only unsupervised learning,
we stuck with kmeans clustering.

<table style="width:36%;">
<caption>Wine Color on Vertical axis vs Cluster group on Horizontal axis for kmeans Clustering on PCA</caption>
<colgroup>
<col style="width: 16%" />
<col style="width: 9%" />
<col style="width: 9%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;"> </th>
<th style="text-align: center;">1</th>
<th style="text-align: center;">2</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;"><strong>red</strong></td>
<td style="text-align: center;">17</td>
<td style="text-align: center;">1582</td>
</tr>
<tr class="even">
<td style="text-align: center;"><strong>white</strong></td>
<td style="text-align: center;">4878</td>
<td style="text-align: center;">20</td>
</tr>
</tbody>
</table>

From our results we can confidently say that kmeans clustering with PCA
gives us a better result in classifying wines based on its color as
compared to using clustering on original scaled data.

### Sorting of Wine based on its Quality

We now try to sort these wines based on their quality. In the data, we
have wines with quality ranging from 3 to 9 on a numerical scale. Most
of these wines are 5,6 and 7 quality wines.

<img src="gb_prediction_files/figure-markdown_github/unnamed-chunk-18-1.png" style="display: block; margin: auto;" />

We run the same kmeans clustering but with centers = 7 as now we need to
sort wines into 7 clusters/ groups. The confusion matrix shows that
there is no pattern of sorting based on quality of wine. For 6 quality
wines, the alogrithm places it evenly in almost all clusters. This shows
that kmeans is not picking up the differences in wine quality
succesfully.

<table style="width:69%;">
<caption>Wine Quality on Vertical axis vs Cluster group on Horizontal axis for kmeans clustering on original scaled data</caption>
<colgroup>
<col style="width: 12%" />
<col style="width: 8%" />
<col style="width: 8%" />
<col style="width: 8%" />
<col style="width: 8%" />
<col style="width: 8%" />
<col style="width: 6%" />
<col style="width: 8%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;"> </th>
<th style="text-align: center;">1</th>
<th style="text-align: center;">2</th>
<th style="text-align: center;">3</th>
<th style="text-align: center;">4</th>
<th style="text-align: center;">5</th>
<th style="text-align: center;">6</th>
<th style="text-align: center;">7</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;"><strong>3</strong></td>
<td style="text-align: center;">4</td>
<td style="text-align: center;">7</td>
<td style="text-align: center;">7</td>
<td style="text-align: center;">2</td>
<td style="text-align: center;">5</td>
<td style="text-align: center;">1</td>
<td style="text-align: center;">4</td>
</tr>
<tr class="even">
<td style="text-align: center;"><strong>4</strong></td>
<td style="text-align: center;">21</td>
<td style="text-align: center;">63</td>
<td style="text-align: center;">24</td>
<td style="text-align: center;">27</td>
<td style="text-align: center;">64</td>
<td style="text-align: center;">2</td>
<td style="text-align: center;">15</td>
</tr>
<tr class="odd">
<td style="text-align: center;"><strong>5</strong></td>
<td style="text-align: center;">77</td>
<td style="text-align: center;">471</td>
<td style="text-align: center;">655</td>
<td style="text-align: center;">269</td>
<td style="text-align: center;">446</td>
<td style="text-align: center;">20</td>
<td style="text-align: center;">200</td>
</tr>
<tr class="even">
<td style="text-align: center;"><strong>6</strong></td>
<td style="text-align: center;">548</td>
<td style="text-align: center;">350</td>
<td style="text-align: center;">640</td>
<td style="text-align: center;">475</td>
<td style="text-align: center;">549</td>
<td style="text-align: center;">9</td>
<td style="text-align: center;">265</td>
</tr>
<tr class="odd">
<td style="text-align: center;"><strong>7</strong></td>
<td style="text-align: center;">446</td>
<td style="text-align: center;">43</td>
<td style="text-align: center;">122</td>
<td style="text-align: center;">189</td>
<td style="text-align: center;">137</td>
<td style="text-align: center;">1</td>
<td style="text-align: center;">141</td>
</tr>
<tr class="even">
<td style="text-align: center;"><strong>8</strong></td>
<td style="text-align: center;">97</td>
<td style="text-align: center;">2</td>
<td style="text-align: center;">22</td>
<td style="text-align: center;">31</td>
<td style="text-align: center;">27</td>
<td style="text-align: center;">0</td>
<td style="text-align: center;">14</td>
</tr>
<tr class="odd">
<td style="text-align: center;"><strong>9</strong></td>
<td style="text-align: center;">4</td>
<td style="text-align: center;">0</td>
<td style="text-align: center;">0</td>
<td style="text-align: center;">0</td>
<td style="text-align: center;">1</td>
<td style="text-align: center;">0</td>
<td style="text-align: center;">0</td>
</tr>
</tbody>
</table>

We then run kmeans clustering on principal components and sort data into
7 clusters. The consfusion matrix does not look much different than
simple kmeans clustering. So even with PCA we are not able to sort wines
based on their quality.

<table style="width:69%;">
<caption>Wine Quality on Vertical axis vs Cluster group on Horizontal axis for kmeans Clustering on PCA</caption>
<colgroup>
<col style="width: 12%" />
<col style="width: 6%" />
<col style="width: 8%" />
<col style="width: 8%" />
<col style="width: 8%" />
<col style="width: 8%" />
<col style="width: 8%" />
<col style="width: 8%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;"> </th>
<th style="text-align: center;">1</th>
<th style="text-align: center;">2</th>
<th style="text-align: center;">3</th>
<th style="text-align: center;">4</th>
<th style="text-align: center;">5</th>
<th style="text-align: center;">6</th>
<th style="text-align: center;">7</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;"><strong>3</strong></td>
<td style="text-align: center;">3</td>
<td style="text-align: center;">7</td>
<td style="text-align: center;">5</td>
<td style="text-align: center;">3</td>
<td style="text-align: center;">2</td>
<td style="text-align: center;">4</td>
<td style="text-align: center;">6</td>
</tr>
<tr class="even">
<td style="text-align: center;"><strong>4</strong></td>
<td style="text-align: center;">4</td>
<td style="text-align: center;">65</td>
<td style="text-align: center;">29</td>
<td style="text-align: center;">15</td>
<td style="text-align: center;">24</td>
<td style="text-align: center;">9</td>
<td style="text-align: center;">70</td>
</tr>
<tr class="odd">
<td style="text-align: center;"><strong>5</strong></td>
<td style="text-align: center;">53</td>
<td style="text-align: center;">611</td>
<td style="text-align: center;">139</td>
<td style="text-align: center;">361</td>
<td style="text-align: center;">324</td>
<td style="text-align: center;">153</td>
<td style="text-align: center;">497</td>
</tr>
<tr class="even">
<td style="text-align: center;"><strong>6</strong></td>
<td style="text-align: center;">52</td>
<td style="text-align: center;">722</td>
<td style="text-align: center;">704</td>
<td style="text-align: center;">533</td>
<td style="text-align: center;">225</td>
<td style="text-align: center;">266</td>
<td style="text-align: center;">334</td>
</tr>
<tr class="odd">
<td style="text-align: center;"><strong>7</strong></td>
<td style="text-align: center;">2</td>
<td style="text-align: center;">199</td>
<td style="text-align: center;">525</td>
<td style="text-align: center;">140</td>
<td style="text-align: center;">29</td>
<td style="text-align: center;">143</td>
<td style="text-align: center;">41</td>
</tr>
<tr class="even">
<td style="text-align: center;"><strong>8</strong></td>
<td style="text-align: center;">0</td>
<td style="text-align: center;">33</td>
<td style="text-align: center;">110</td>
<td style="text-align: center;">28</td>
<td style="text-align: center;">7</td>
<td style="text-align: center;">13</td>
<td style="text-align: center;">2</td>
</tr>
<tr class="odd">
<td style="text-align: center;"><strong>9</strong></td>
<td style="text-align: center;">0</td>
<td style="text-align: center;">0</td>
<td style="text-align: center;">4</td>
<td style="text-align: center;">1</td>
<td style="text-align: center;">0</td>
<td style="text-align: center;">0</td>
<td style="text-align: center;">0</td>
</tr>
</tbody>
</table>

We try to group wines into two groups; high quality and low quality by
classifying wines with quality 6 and above as high quality and the rest
as low quality wines. We run kmeans clustering again but the results are
not encouraging as we see a very high error rate.

<table style="width:35%;">
<colgroup>
<col style="width: 15%" />
<col style="width: 9%" />
<col style="width: 9%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;"> </th>
<th style="text-align: center;">1</th>
<th style="text-align: center;">2</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;"><strong>High</strong></td>
<td style="text-align: center;">3258</td>
<td style="text-align: center;">855</td>
</tr>
<tr class="even">
<td style="text-align: center;"><strong>Low</strong></td>
<td style="text-align: center;">1596</td>
<td style="text-align: center;">788</td>
</tr>
</tbody>
</table>

This clearly shows that the clustering and PCA techniques are not able
to sort or identify wines based on its quality. It seems that our
approach of euclidean distance measurement is not capturing the
differenes in quality of wines. Looking at boxplots of quality against
different chemical properties, we do not see much variations for
chemical properties across different qualities of wines. Probably the
quality of wine is not particularly linked to these 11 chemical
properties and hence failure of clustering and PCA to distinguish it.

<img src="gb_prediction_files/figure-markdown_github/unnamed-chunk-22-1.png" style="display: block; margin: auto;" />

Market Segmentation
-------------------

### Initial Perception

``` r
set.seed(1)
social_marketing= read.csv('social_marketing.csv', header=TRUE)
```

The top three most shared things in our data by mean: chatter, photo
sharing, health/nutrition. The chatter makes since given that this is
twitter. The other two makes sense given these are people following a
health/nutrition company.

``` r
#center and scale
X = social_marketing[,-1]
X = scale(X, center=TRUE, scale=TRUE)
#extract the centers and scales from the rescaled data for later use
mu = attr(X, "scaled:center")
sigma = attr(X, "scaled:scale")
```

Now that I have the data scaled for clustering, I’d like to figure what
value of K to use so I’m going to get an elbow plot to get a ballpark
for what k to use.

### Elbow Plot

``` r
k_grid = seq(2, 20, by=1)
SSE_grid = foreach(k = k_grid, .combine='c') %do% {
  cluster_k = kmeans(X, k, nstart=50)
  cluster_k$tot.withinss
}
  plot(k_grid, SSE_grid)
```

<img src="gb_prediction_files/figure-markdown_github/unnamed-chunk-25-1.png" style="display: block; margin: auto;" />

Based on this elbow plot, k=12 is probably reasonable. This is prety
arbitrary. I tried to run a gap statistic to see what kind of k that
indicated was correct, but the code took too long to run. I let it run
for over 24 hours and it didn’t finish. So, we are going to proceed with
k=12.

### Clustering

``` r
  clust1 = kmeans(X, 12, nstart=25)
  
  clust2 = kmeanspp(X, k=12, nstart=25)
  
  clust1$tot.withinss
```

    ## [1] 176097.5

``` r
  clust2$tot.withinss
```

    ## [1] 176097.9

``` r
  clust1$betweenss
```

    ## [1] 107618.5

``` r
  clust2$betweenss
```

    ## [1] 107618.1

The K++ clustering had a total sum of squares between that was 658 more
and a total sum of squares within that was 658 less, so cluster 2, the
Kmeans++, seems to do a better job here. This is because generally we
want more “distance” between clusters and less “distance” within
clusters. So, lets move forward with cluster 2

### Cluster Summaries

#### Cluster 1

``` r
pander(clust2$center[1,]*sigma + mu) #into beauty/fashion/photosharing  
```

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 12%" />
<col style="width: 21%" />
<col style="width: 11%" />
<col style="width: 20%" />
<col style="width: 20%" />
<col style="width: 12%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">chatter</th>
<th style="text-align: center;">current_events</th>
<th style="text-align: center;">travel</th>
<th style="text-align: center;">photo_sharing</th>
<th style="text-align: center;">uncategorized</th>
<th style="text-align: center;">tv_film</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">4.14</td>
<td style="text-align: center;">1.758</td>
<td style="text-align: center;">1.461</td>
<td style="text-align: center;">6.126</td>
<td style="text-align: center;">1.275</td>
<td style="text-align: center;">0.8448</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 20%" />
<col style="width: 14%" />
<col style="width: 10%" />
<col style="width: 11%" />
<col style="width: 23%" />
<col style="width: 10%" />
<col style="width: 10%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">sports_fandom</th>
<th style="text-align: center;">politics</th>
<th style="text-align: center;">food</th>
<th style="text-align: center;">family</th>
<th style="text-align: center;">home_and_garden</th>
<th style="text-align: center;">music</th>
<th style="text-align: center;">news</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">1.115</td>
<td style="text-align: center;">1.386</td>
<td style="text-align: center;">1.038</td>
<td style="text-align: center;">0.9024</td>
<td style="text-align: center;">0.6164</td>
<td style="text-align: center;">1.251</td>
<td style="text-align: center;">1.027</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 20%" />
<col style="width: 14%" />
<col style="width: 24%" />
<col style="width: 18%" />
<col style="width: 22%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">online_gaming</th>
<th style="text-align: center;">shopping</th>
<th style="text-align: center;">health_nutrition</th>
<th style="text-align: center;">college_uni</th>
<th style="text-align: center;">sports_playing</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">1.169</td>
<td style="text-align: center;">1.754</td>
<td style="text-align: center;">2.275</td>
<td style="text-align: center;">1.532</td>
<td style="text-align: center;">0.8248</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 13%" />
<col style="width: 12%" />
<col style="width: 16%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 12%" />
<col style="width: 17%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">cooking</th>
<th style="text-align: center;">eco</th>
<th style="text-align: center;">computers</th>
<th style="text-align: center;">business</th>
<th style="text-align: center;">outdoors</th>
<th style="text-align: center;">crafts</th>
<th style="text-align: center;">automotive</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">11.85</td>
<td style="text-align: center;">0.5122</td>
<td style="text-align: center;">0.7317</td>
<td style="text-align: center;">0.5787</td>
<td style="text-align: center;">0.8071</td>
<td style="text-align: center;">0.5831</td>
<td style="text-align: center;">0.8448</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 11%" />
<col style="width: 14%" />
<col style="width: 11%" />
<col style="width: 15%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 24%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">art</th>
<th style="text-align: center;">religion</th>
<th style="text-align: center;">beauty</th>
<th style="text-align: center;">parenting</th>
<th style="text-align: center;">dating</th>
<th style="text-align: center;">school</th>
<th style="text-align: center;">personal_fitness</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.7517</td>
<td style="text-align: center;">0.8514</td>
<td style="text-align: center;">4.288</td>
<td style="text-align: center;">0.816</td>
<td style="text-align: center;">0.6275</td>
<td style="text-align: center;">0.929</td>
<td style="text-align: center;">1.361</td>
</tr>
</tbody>
</table>

<table style="width:67%;">
<colgroup>
<col style="width: 13%" />
<col style="width: 23%" />
<col style="width: 16%" />
<col style="width: 12%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">fashion</th>
<th style="text-align: center;">small_business</th>
<th style="text-align: center;">spam</th>
<th style="text-align: center;">adult</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">6.058</td>
<td style="text-align: center;">0.4457</td>
<td style="text-align: center;">4.337e-17</td>
<td style="text-align: center;">0.2195</td>
</tr>
</tbody>
</table>

#### Cluster 2

``` r
pander(clust2$center[2,]*sigma + mu) #really into news/politics, travelling and computers #photo sharing and chatter    
```

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 12%" />
<col style="width: 21%" />
<col style="width: 11%" />
<col style="width: 20%" />
<col style="width: 20%" />
<col style="width: 12%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">chatter</th>
<th style="text-align: center;">current_events</th>
<th style="text-align: center;">travel</th>
<th style="text-align: center;">photo_sharing</th>
<th style="text-align: center;">uncategorized</th>
<th style="text-align: center;">tv_film</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">3.075</td>
<td style="text-align: center;">1.267</td>
<td style="text-align: center;">1.068</td>
<td style="text-align: center;">1.555</td>
<td style="text-align: center;">0.6338</td>
<td style="text-align: center;">0.7079</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 19%" />
<col style="width: 13%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 22%" />
<col style="width: 11%" />
<col style="width: 11%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">sports_fandom</th>
<th style="text-align: center;">politics</th>
<th style="text-align: center;">food</th>
<th style="text-align: center;">family</th>
<th style="text-align: center;">home_and_garden</th>
<th style="text-align: center;">music</th>
<th style="text-align: center;">news</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.9058</td>
<td style="text-align: center;">0.8825</td>
<td style="text-align: center;">0.7506</td>
<td style="text-align: center;">0.5101</td>
<td style="text-align: center;">0.3671</td>
<td style="text-align: center;">0.4466</td>
<td style="text-align: center;">0.5524</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 20%" />
<col style="width: 14%" />
<col style="width: 24%" />
<col style="width: 18%" />
<col style="width: 22%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">online_gaming</th>
<th style="text-align: center;">shopping</th>
<th style="text-align: center;">health_nutrition</th>
<th style="text-align: center;">college_uni</th>
<th style="text-align: center;">sports_playing</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.5795</td>
<td style="text-align: center;">0.68</td>
<td style="text-align: center;">1.157</td>
<td style="text-align: center;">0.816</td>
<td style="text-align: center;">0.3844</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 13%" />
<col style="width: 12%" />
<col style="width: 16%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 12%" />
<col style="width: 17%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">cooking</th>
<th style="text-align: center;">eco</th>
<th style="text-align: center;">computers</th>
<th style="text-align: center;">business</th>
<th style="text-align: center;">outdoors</th>
<th style="text-align: center;">crafts</th>
<th style="text-align: center;">automotive</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.9017</td>
<td style="text-align: center;">0.2952</td>
<td style="text-align: center;">0.3376</td>
<td style="text-align: center;">0.2531</td>
<td style="text-align: center;">0.3719</td>
<td style="text-align: center;">0.2732</td>
<td style="text-align: center;">0.4004</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 11%" />
<col style="width: 14%" />
<col style="width: 11%" />
<col style="width: 15%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 24%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">art</th>
<th style="text-align: center;">religion</th>
<th style="text-align: center;">beauty</th>
<th style="text-align: center;">parenting</th>
<th style="text-align: center;">dating</th>
<th style="text-align: center;">school</th>
<th style="text-align: center;">personal_fitness</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.3288</td>
<td style="text-align: center;">0.5258</td>
<td style="text-align: center;">0.3433</td>
<td style="text-align: center;">0.4212</td>
<td style="text-align: center;">0.326</td>
<td style="text-align: center;">0.3734</td>
<td style="text-align: center;">0.6523</td>
</tr>
</tbody>
</table>

<table style="width:68%;">
<colgroup>
<col style="width: 13%" />
<col style="width: 23%" />
<col style="width: 18%" />
<col style="width: 12%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">fashion</th>
<th style="text-align: center;">small_business</th>
<th style="text-align: center;">spam</th>
<th style="text-align: center;">adult</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.4589</td>
<td style="text-align: center;">0.1976</td>
<td style="text-align: center;">-2.628e-16</td>
<td style="text-align: center;">0.1062</td>
</tr>
</tbody>
</table>

#### Cluster 3

``` r
pander( clust2$center[3,]*sigma + mu) #really into news/politics, travelling and computers #photo sharing and chatter
```

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 12%" />
<col style="width: 21%" />
<col style="width: 11%" />
<col style="width: 20%" />
<col style="width: 20%" />
<col style="width: 12%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">chatter</th>
<th style="text-align: center;">current_events</th>
<th style="text-align: center;">travel</th>
<th style="text-align: center;">photo_sharing</th>
<th style="text-align: center;">uncategorized</th>
<th style="text-align: center;">tv_film</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">4.067</td>
<td style="text-align: center;">1.663</td>
<td style="text-align: center;">9.126</td>
<td style="text-align: center;">2.37</td>
<td style="text-align: center;">0.7185</td>
<td style="text-align: center;">0.9707</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 20%" />
<col style="width: 13%" />
<col style="width: 10%" />
<col style="width: 11%" />
<col style="width: 22%" />
<col style="width: 11%" />
<col style="width: 11%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">sports_fandom</th>
<th style="text-align: center;">politics</th>
<th style="text-align: center;">food</th>
<th style="text-align: center;">family</th>
<th style="text-align: center;">home_and_garden</th>
<th style="text-align: center;">music</th>
<th style="text-align: center;">news</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">1.147</td>
<td style="text-align: center;">11.34</td>
<td style="text-align: center;">1.701</td>
<td style="text-align: center;">0.7713</td>
<td style="text-align: center;">0.563</td>
<td style="text-align: center;">0.6393</td>
<td style="text-align: center;">3.628</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 20%" />
<col style="width: 14%" />
<col style="width: 24%" />
<col style="width: 18%" />
<col style="width: 22%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">online_gaming</th>
<th style="text-align: center;">shopping</th>
<th style="text-align: center;">health_nutrition</th>
<th style="text-align: center;">college_uni</th>
<th style="text-align: center;">sports_playing</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.7566</td>
<td style="text-align: center;">1.249</td>
<td style="text-align: center;">1.815</td>
<td style="text-align: center;">1.425</td>
<td style="text-align: center;">0.6804</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 13%" />
<col style="width: 12%" />
<col style="width: 16%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 12%" />
<col style="width: 17%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">cooking</th>
<th style="text-align: center;">eco</th>
<th style="text-align: center;">computers</th>
<th style="text-align: center;">business</th>
<th style="text-align: center;">outdoors</th>
<th style="text-align: center;">crafts</th>
<th style="text-align: center;">automotive</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">1.364</td>
<td style="text-align: center;">0.6276</td>
<td style="text-align: center;">4.109</td>
<td style="text-align: center;">0.8123</td>
<td style="text-align: center;">0.739</td>
<td style="text-align: center;">0.6716</td>
<td style="text-align: center;">0.654</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 11%" />
<col style="width: 14%" />
<col style="width: 11%" />
<col style="width: 15%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 24%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">art</th>
<th style="text-align: center;">religion</th>
<th style="text-align: center;">beauty</th>
<th style="text-align: center;">parenting</th>
<th style="text-align: center;">dating</th>
<th style="text-align: center;">school</th>
<th style="text-align: center;">personal_fitness</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.4721</td>
<td style="text-align: center;">1.334</td>
<td style="text-align: center;">0.4545</td>
<td style="text-align: center;">0.9501</td>
<td style="text-align: center;">1.135</td>
<td style="text-align: center;">0.6276</td>
<td style="text-align: center;">1.103</td>
</tr>
</tbody>
</table>

<table style="width:68%;">
<colgroup>
<col style="width: 13%" />
<col style="width: 23%" />
<col style="width: 15%" />
<col style="width: 15%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">fashion</th>
<th style="text-align: center;">small_business</th>
<th style="text-align: center;">spam</th>
<th style="text-align: center;">adult</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.6657</td>
<td style="text-align: center;">0.5777</td>
<td style="text-align: center;">4.77e-17</td>
<td style="text-align: center;">0.08504</td>
</tr>
</tbody>
</table>

#### Cluster 4

``` r
  pander(clust2$center[4,]*sigma + mu) #news, politics, and cars  
```

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 12%" />
<col style="width: 21%" />
<col style="width: 11%" />
<col style="width: 20%" />
<col style="width: 20%" />
<col style="width: 12%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">chatter</th>
<th style="text-align: center;">current_events</th>
<th style="text-align: center;">travel</th>
<th style="text-align: center;">photo_sharing</th>
<th style="text-align: center;">uncategorized</th>
<th style="text-align: center;">tv_film</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">4.12</td>
<td style="text-align: center;">1.607</td>
<td style="text-align: center;">1.161</td>
<td style="text-align: center;">2.103</td>
<td style="text-align: center;">0.7242</td>
<td style="text-align: center;">1.058</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 20%" />
<col style="width: 13%" />
<col style="width: 10%" />
<col style="width: 11%" />
<col style="width: 22%" />
<col style="width: 11%" />
<col style="width: 11%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">sports_fandom</th>
<th style="text-align: center;">politics</th>
<th style="text-align: center;">food</th>
<th style="text-align: center;">family</th>
<th style="text-align: center;">home_and_garden</th>
<th style="text-align: center;">music</th>
<th style="text-align: center;">news</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">3.079</td>
<td style="text-align: center;">5.53</td>
<td style="text-align: center;">1.129</td>
<td style="text-align: center;">1.125</td>
<td style="text-align: center;">0.6235</td>
<td style="text-align: center;">0.5947</td>
<td style="text-align: center;">6.866</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 20%" />
<col style="width: 14%" />
<col style="width: 24%" />
<col style="width: 18%" />
<col style="width: 22%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">online_gaming</th>
<th style="text-align: center;">shopping</th>
<th style="text-align: center;">health_nutrition</th>
<th style="text-align: center;">college_uni</th>
<th style="text-align: center;">sports_playing</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.8753</td>
<td style="text-align: center;">1.055</td>
<td style="text-align: center;">1.472</td>
<td style="text-align: center;">0.9904</td>
<td style="text-align: center;">0.5492</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 13%" />
<col style="width: 12%" />
<col style="width: 16%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 12%" />
<col style="width: 17%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">cooking</th>
<th style="text-align: center;">eco</th>
<th style="text-align: center;">computers</th>
<th style="text-align: center;">business</th>
<th style="text-align: center;">outdoors</th>
<th style="text-align: center;">crafts</th>
<th style="text-align: center;">automotive</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">1.211</td>
<td style="text-align: center;">0.4293</td>
<td style="text-align: center;">0.4245</td>
<td style="text-align: center;">0.3453</td>
<td style="text-align: center;">1.134</td>
<td style="text-align: center;">0.3837</td>
<td style="text-align: center;">4.403</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 9%" />
<col style="width: 14%" />
<col style="width: 11%" />
<col style="width: 15%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 25%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">art</th>
<th style="text-align: center;">religion</th>
<th style="text-align: center;">beauty</th>
<th style="text-align: center;">parenting</th>
<th style="text-align: center;">dating</th>
<th style="text-align: center;">school</th>
<th style="text-align: center;">personal_fitness</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.47</td>
<td style="text-align: center;">0.753</td>
<td style="text-align: center;">0.4748</td>
<td style="text-align: center;">0.9856</td>
<td style="text-align: center;">0.5516</td>
<td style="text-align: center;">0.7698</td>
<td style="text-align: center;">0.9137</td>
</tr>
</tbody>
</table>

<table style="width:71%;">
<colgroup>
<col style="width: 13%" />
<col style="width: 23%" />
<col style="width: 16%" />
<col style="width: 16%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">fashion</th>
<th style="text-align: center;">small_business</th>
<th style="text-align: center;">spam</th>
<th style="text-align: center;">adult</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.5803</td>
<td style="text-align: center;">0.2326</td>
<td style="text-align: center;">5.898e-17</td>
<td style="text-align: center;">0.07194</td>
</tr>
</tbody>
</table>

#### Cluster 5

``` r
pander(clust2$center[5,]*sigma + mu) #mostly chatter, but shopping and photo sharing; maybe ads 
```

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 12%" />
<col style="width: 21%" />
<col style="width: 11%" />
<col style="width: 20%" />
<col style="width: 20%" />
<col style="width: 12%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">chatter</th>
<th style="text-align: center;">current_events</th>
<th style="text-align: center;">travel</th>
<th style="text-align: center;">photo_sharing</th>
<th style="text-align: center;">uncategorized</th>
<th style="text-align: center;">tv_film</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">9.764</td>
<td style="text-align: center;">1.987</td>
<td style="text-align: center;">1.098</td>
<td style="text-align: center;">6.004</td>
<td style="text-align: center;">0.8056</td>
<td style="text-align: center;">0.8419</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 19%" />
<col style="width: 13%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 22%" />
<col style="width: 11%" />
<col style="width: 11%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">sports_fandom</th>
<th style="text-align: center;">politics</th>
<th style="text-align: center;">food</th>
<th style="text-align: center;">family</th>
<th style="text-align: center;">home_and_garden</th>
<th style="text-align: center;">music</th>
<th style="text-align: center;">news</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">1.167</td>
<td style="text-align: center;">1.376</td>
<td style="text-align: center;">0.8387</td>
<td style="text-align: center;">0.8248</td>
<td style="text-align: center;">0.5566</td>
<td style="text-align: center;">0.8376</td>
<td style="text-align: center;">0.6421</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 20%" />
<col style="width: 14%" />
<col style="width: 24%" />
<col style="width: 18%" />
<col style="width: 22%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">online_gaming</th>
<th style="text-align: center;">shopping</th>
<th style="text-align: center;">health_nutrition</th>
<th style="text-align: center;">college_uni</th>
<th style="text-align: center;">sports_playing</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.7489</td>
<td style="text-align: center;">4.158</td>
<td style="text-align: center;">1.619</td>
<td style="text-align: center;">1.231</td>
<td style="text-align: center;">0.5524</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 13%" />
<col style="width: 12%" />
<col style="width: 16%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 12%" />
<col style="width: 17%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">cooking</th>
<th style="text-align: center;">eco</th>
<th style="text-align: center;">computers</th>
<th style="text-align: center;">business</th>
<th style="text-align: center;">outdoors</th>
<th style="text-align: center;">crafts</th>
<th style="text-align: center;">automotive</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">1.24</td>
<td style="text-align: center;">0.7415</td>
<td style="text-align: center;">0.5962</td>
<td style="text-align: center;">0.6474</td>
<td style="text-align: center;">0.4583</td>
<td style="text-align: center;">0.5214</td>
<td style="text-align: center;">0.9658</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 11%" />
<col style="width: 14%" />
<col style="width: 11%" />
<col style="width: 15%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 24%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">art</th>
<th style="text-align: center;">religion</th>
<th style="text-align: center;">beauty</th>
<th style="text-align: center;">parenting</th>
<th style="text-align: center;">dating</th>
<th style="text-align: center;">school</th>
<th style="text-align: center;">personal_fitness</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.3729</td>
<td style="text-align: center;">0.5609</td>
<td style="text-align: center;">0.3942</td>
<td style="text-align: center;">0.5908</td>
<td style="text-align: center;">0.4391</td>
<td style="text-align: center;">0.7137</td>
<td style="text-align: center;">1.075</td>
</tr>
</tbody>
</table>

<table style="width:67%;">
<colgroup>
<col style="width: 13%" />
<col style="width: 23%" />
<col style="width: 16%" />
<col style="width: 12%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">fashion</th>
<th style="text-align: center;">small_business</th>
<th style="text-align: center;">spam</th>
<th style="text-align: center;">adult</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.7201</td>
<td style="text-align: center;">0.4103</td>
<td style="text-align: center;">9.541e-18</td>
<td style="text-align: center;">0.1197</td>
</tr>
</tbody>
</table>

#### Cluster 6

``` r
pander(clust2$center[6,]*sigma + mu) #outdoors, fitness, photo sharing and food/cooking maybe athletes
```

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 12%" />
<col style="width: 21%" />
<col style="width: 11%" />
<col style="width: 20%" />
<col style="width: 20%" />
<col style="width: 12%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">chatter</th>
<th style="text-align: center;">current_events</th>
<th style="text-align: center;">travel</th>
<th style="text-align: center;">photo_sharing</th>
<th style="text-align: center;">uncategorized</th>
<th style="text-align: center;">tv_film</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">3.753</td>
<td style="text-align: center;">1.49</td>
<td style="text-align: center;">1.217</td>
<td style="text-align: center;">2.347</td>
<td style="text-align: center;">0.9358</td>
<td style="text-align: center;">0.8251</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 20%" />
<col style="width: 13%" />
<col style="width: 8%" />
<col style="width: 11%" />
<col style="width: 22%" />
<col style="width: 11%" />
<col style="width: 11%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">sports_fandom</th>
<th style="text-align: center;">politics</th>
<th style="text-align: center;">food</th>
<th style="text-align: center;">family</th>
<th style="text-align: center;">home_and_garden</th>
<th style="text-align: center;">music</th>
<th style="text-align: center;">news</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">1.178</td>
<td style="text-align: center;">1.167</td>
<td style="text-align: center;">2.23</td>
<td style="text-align: center;">0.7486</td>
<td style="text-align: center;">0.612</td>
<td style="text-align: center;">0.6639</td>
<td style="text-align: center;">1.057</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 20%" />
<col style="width: 14%" />
<col style="width: 24%" />
<col style="width: 18%" />
<col style="width: 22%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">online_gaming</th>
<th style="text-align: center;">shopping</th>
<th style="text-align: center;">health_nutrition</th>
<th style="text-align: center;">college_uni</th>
<th style="text-align: center;">sports_playing</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.8948</td>
<td style="text-align: center;">1.261</td>
<td style="text-align: center;">12.72</td>
<td style="text-align: center;">0.9235</td>
<td style="text-align: center;">0.597</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 13%" />
<col style="width: 12%" />
<col style="width: 16%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 12%" />
<col style="width: 17%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">cooking</th>
<th style="text-align: center;">eco</th>
<th style="text-align: center;">computers</th>
<th style="text-align: center;">business</th>
<th style="text-align: center;">outdoors</th>
<th style="text-align: center;">crafts</th>
<th style="text-align: center;">automotive</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">3.428</td>
<td style="text-align: center;">0.9481</td>
<td style="text-align: center;">0.5492</td>
<td style="text-align: center;">0.444</td>
<td style="text-align: center;">2.899</td>
<td style="text-align: center;">0.5806</td>
<td style="text-align: center;">0.5683</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 11%" />
<col style="width: 14%" />
<col style="width: 11%" />
<col style="width: 15%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 24%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">art</th>
<th style="text-align: center;">religion</th>
<th style="text-align: center;">beauty</th>
<th style="text-align: center;">parenting</th>
<th style="text-align: center;">dating</th>
<th style="text-align: center;">school</th>
<th style="text-align: center;">personal_fitness</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.5929</td>
<td style="text-align: center;">0.791</td>
<td style="text-align: center;">0.4194</td>
<td style="text-align: center;">0.776</td>
<td style="text-align: center;">0.7923</td>
<td style="text-align: center;">0.5096</td>
<td style="text-align: center;">6.702</td>
</tr>
</tbody>
</table>

<table style="width:68%;">
<colgroup>
<col style="width: 13%" />
<col style="width: 23%" />
<col style="width: 18%" />
<col style="width: 12%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">fashion</th>
<th style="text-align: center;">small_business</th>
<th style="text-align: center;">spam</th>
<th style="text-align: center;">adult</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.7486</td>
<td style="text-align: center;">0.2377</td>
<td style="text-align: center;">-3.556e-17</td>
<td style="text-align: center;">0.1694</td>
</tr>
</tbody>
</table>

#### Cluster 7

``` r
pander(clust2$center[7,]*sigma + mu) #chatter, sports playing, and photo sharing  
```

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 12%" />
<col style="width: 21%" />
<col style="width: 11%" />
<col style="width: 20%" />
<col style="width: 20%" />
<col style="width: 12%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">chatter</th>
<th style="text-align: center;">current_events</th>
<th style="text-align: center;">travel</th>
<th style="text-align: center;">photo_sharing</th>
<th style="text-align: center;">uncategorized</th>
<th style="text-align: center;">tv_film</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">4.032</td>
<td style="text-align: center;">1.416</td>
<td style="text-align: center;">1.504</td>
<td style="text-align: center;">2.657</td>
<td style="text-align: center;">0.7625</td>
<td style="text-align: center;">1.252</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 20%" />
<col style="width: 13%" />
<col style="width: 10%" />
<col style="width: 11%" />
<col style="width: 22%" />
<col style="width: 11%" />
<col style="width: 11%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">sports_fandom</th>
<th style="text-align: center;">politics</th>
<th style="text-align: center;">food</th>
<th style="text-align: center;">family</th>
<th style="text-align: center;">home_and_garden</th>
<th style="text-align: center;">music</th>
<th style="text-align: center;">news</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">1.302</td>
<td style="text-align: center;">1.261</td>
<td style="text-align: center;">1.223</td>
<td style="text-align: center;">1.1</td>
<td style="text-align: center;">0.563</td>
<td style="text-align: center;">0.6246</td>
<td style="text-align: center;">0.8152</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 20%" />
<col style="width: 14%" />
<col style="width: 24%" />
<col style="width: 18%" />
<col style="width: 22%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">online_gaming</th>
<th style="text-align: center;">shopping</th>
<th style="text-align: center;">health_nutrition</th>
<th style="text-align: center;">college_uni</th>
<th style="text-align: center;">sports_playing</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">10.98</td>
<td style="text-align: center;">1.141</td>
<td style="text-align: center;">1.771</td>
<td style="text-align: center;">11.23</td>
<td style="text-align: center;">2.768</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 13%" />
<col style="width: 12%" />
<col style="width: 16%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 12%" />
<col style="width: 17%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">cooking</th>
<th style="text-align: center;">eco</th>
<th style="text-align: center;">computers</th>
<th style="text-align: center;">business</th>
<th style="text-align: center;">outdoors</th>
<th style="text-align: center;">crafts</th>
<th style="text-align: center;">automotive</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">1.575</td>
<td style="text-align: center;">0.4633</td>
<td style="text-align: center;">0.5513</td>
<td style="text-align: center;">0.3578</td>
<td style="text-align: center;">0.6246</td>
<td style="text-align: center;">0.5367</td>
<td style="text-align: center;">0.912</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 10%" />
<col style="width: 14%" />
<col style="width: 11%" />
<col style="width: 15%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 24%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">art</th>
<th style="text-align: center;">religion</th>
<th style="text-align: center;">beauty</th>
<th style="text-align: center;">parenting</th>
<th style="text-align: center;">dating</th>
<th style="text-align: center;">school</th>
<th style="text-align: center;">personal_fitness</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">1.182</td>
<td style="text-align: center;">0.7361</td>
<td style="text-align: center;">0.3959</td>
<td style="text-align: center;">0.7243</td>
<td style="text-align: center;">0.6569</td>
<td style="text-align: center;">0.4897</td>
<td style="text-align: center;">1.041</td>
</tr>
</tbody>
</table>

<table style="width:64%;">
<colgroup>
<col style="width: 13%" />
<col style="width: 23%" />
<col style="width: 15%" />
<col style="width: 11%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">fashion</th>
<th style="text-align: center;">small_business</th>
<th style="text-align: center;">spam</th>
<th style="text-align: center;">adult</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.8475</td>
<td style="text-align: center;">0.4018</td>
<td style="text-align: center;">4.77e-17</td>
<td style="text-align: center;">0.173</td>
</tr>
</tbody>
</table>

#### Cluster 8

``` r
pander(clust2$center[8,]*sigma + mu) #Sports fans that are religious and parents 
```

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 12%" />
<col style="width: 21%" />
<col style="width: 11%" />
<col style="width: 20%" />
<col style="width: 20%" />
<col style="width: 12%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">chatter</th>
<th style="text-align: center;">current_events</th>
<th style="text-align: center;">travel</th>
<th style="text-align: center;">photo_sharing</th>
<th style="text-align: center;">uncategorized</th>
<th style="text-align: center;">tv_film</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">3.842</td>
<td style="text-align: center;">1.649</td>
<td style="text-align: center;">1.348</td>
<td style="text-align: center;">2.454</td>
<td style="text-align: center;">0.6973</td>
<td style="text-align: center;">0.9158</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 20%" />
<col style="width: 13%" />
<col style="width: 10%" />
<col style="width: 11%" />
<col style="width: 22%" />
<col style="width: 11%" />
<col style="width: 11%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">sports_fandom</th>
<th style="text-align: center;">politics</th>
<th style="text-align: center;">food</th>
<th style="text-align: center;">family</th>
<th style="text-align: center;">home_and_garden</th>
<th style="text-align: center;">music</th>
<th style="text-align: center;">news</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">6.19</td>
<td style="text-align: center;">1.114</td>
<td style="text-align: center;">4.769</td>
<td style="text-align: center;">2.627</td>
<td style="text-align: center;">0.6459</td>
<td style="text-align: center;">0.7129</td>
<td style="text-align: center;">0.9813</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 20%" />
<col style="width: 14%" />
<col style="width: 24%" />
<col style="width: 18%" />
<col style="width: 22%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">online_gaming</th>
<th style="text-align: center;">shopping</th>
<th style="text-align: center;">health_nutrition</th>
<th style="text-align: center;">college_uni</th>
<th style="text-align: center;">sports_playing</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.9984</td>
<td style="text-align: center;">1.354</td>
<td style="text-align: center;">1.919</td>
<td style="text-align: center;">1.178</td>
<td style="text-align: center;">0.7363</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 13%" />
<col style="width: 12%" />
<col style="width: 16%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 12%" />
<col style="width: 17%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">cooking</th>
<th style="text-align: center;">eco</th>
<th style="text-align: center;">computers</th>
<th style="text-align: center;">business</th>
<th style="text-align: center;">outdoors</th>
<th style="text-align: center;">crafts</th>
<th style="text-align: center;">automotive</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">1.691</td>
<td style="text-align: center;">0.6427</td>
<td style="text-align: center;">0.7457</td>
<td style="text-align: center;">0.4961</td>
<td style="text-align: center;">0.6771</td>
<td style="text-align: center;">1.078</td>
<td style="text-align: center;">0.9938</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 11%" />
<col style="width: 14%" />
<col style="width: 11%" />
<col style="width: 15%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 24%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">art</th>
<th style="text-align: center;">religion</th>
<th style="text-align: center;">beauty</th>
<th style="text-align: center;">parenting</th>
<th style="text-align: center;">dating</th>
<th style="text-align: center;">school</th>
<th style="text-align: center;">personal_fitness</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.6817</td>
<td style="text-align: center;">5.552</td>
<td style="text-align: center;">1.134</td>
<td style="text-align: center;">4.262</td>
<td style="text-align: center;">0.5133</td>
<td style="text-align: center;">2.76</td>
<td style="text-align: center;">1.225</td>
</tr>
</tbody>
</table>

<table style="width:68%;">
<colgroup>
<col style="width: 13%" />
<col style="width: 23%" />
<col style="width: 18%" />
<col style="width: 12%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">fashion</th>
<th style="text-align: center;">small_business</th>
<th style="text-align: center;">spam</th>
<th style="text-align: center;">adult</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">1.005</td>
<td style="text-align: center;">0.3885</td>
<td style="text-align: center;">-1.648e-17</td>
<td style="text-align: center;">0.2246</td>
</tr>
</tbody>
</table>

#### Cluster 9

``` r
pander(clust2$center[9,]*sigma + mu) #adult
```

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 12%" />
<col style="width: 21%" />
<col style="width: 11%" />
<col style="width: 20%" />
<col style="width: 20%" />
<col style="width: 12%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">chatter</th>
<th style="text-align: center;">current_events</th>
<th style="text-align: center;">travel</th>
<th style="text-align: center;">photo_sharing</th>
<th style="text-align: center;">uncategorized</th>
<th style="text-align: center;">tv_film</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">4.323</td>
<td style="text-align: center;">1.487</td>
<td style="text-align: center;">1.574</td>
<td style="text-align: center;">2.138</td>
<td style="text-align: center;">1.051</td>
<td style="text-align: center;">0.7077</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 20%" />
<col style="width: 13%" />
<col style="width: 10%" />
<col style="width: 11%" />
<col style="width: 22%" />
<col style="width: 11%" />
<col style="width: 11%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">sports_fandom</th>
<th style="text-align: center;">politics</th>
<th style="text-align: center;">food</th>
<th style="text-align: center;">family</th>
<th style="text-align: center;">home_and_garden</th>
<th style="text-align: center;">music</th>
<th style="text-align: center;">news</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">1.262</td>
<td style="text-align: center;">1.133</td>
<td style="text-align: center;">1.272</td>
<td style="text-align: center;">0.9538</td>
<td style="text-align: center;">0.5487</td>
<td style="text-align: center;">0.6564</td>
<td style="text-align: center;">0.8667</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 20%" />
<col style="width: 14%" />
<col style="width: 24%" />
<col style="width: 18%" />
<col style="width: 22%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">online_gaming</th>
<th style="text-align: center;">shopping</th>
<th style="text-align: center;">health_nutrition</th>
<th style="text-align: center;">college_uni</th>
<th style="text-align: center;">sports_playing</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">1.195</td>
<td style="text-align: center;">1.041</td>
<td style="text-align: center;">1.728</td>
<td style="text-align: center;">1.179</td>
<td style="text-align: center;">0.4974</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 13%" />
<col style="width: 12%" />
<col style="width: 16%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 12%" />
<col style="width: 17%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">cooking</th>
<th style="text-align: center;">eco</th>
<th style="text-align: center;">computers</th>
<th style="text-align: center;">business</th>
<th style="text-align: center;">outdoors</th>
<th style="text-align: center;">crafts</th>
<th style="text-align: center;">automotive</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">1.395</td>
<td style="text-align: center;">0.6308</td>
<td style="text-align: center;">0.7333</td>
<td style="text-align: center;">0.3385</td>
<td style="text-align: center;">1.087</td>
<td style="text-align: center;">0.5333</td>
<td style="text-align: center;">0.9692</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 11%" />
<col style="width: 14%" />
<col style="width: 11%" />
<col style="width: 15%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 24%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">art</th>
<th style="text-align: center;">religion</th>
<th style="text-align: center;">beauty</th>
<th style="text-align: center;">parenting</th>
<th style="text-align: center;">dating</th>
<th style="text-align: center;">school</th>
<th style="text-align: center;">personal_fitness</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.5692</td>
<td style="text-align: center;">0.7744</td>
<td style="text-align: center;">0.6205</td>
<td style="text-align: center;">1.031</td>
<td style="text-align: center;">0.5538</td>
<td style="text-align: center;">0.8205</td>
<td style="text-align: center;">1.282</td>
</tr>
</tbody>
</table>

<table style="width:67%;">
<colgroup>
<col style="width: 13%" />
<col style="width: 23%" />
<col style="width: 18%" />
<col style="width: 11%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">fashion</th>
<th style="text-align: center;">small_business</th>
<th style="text-align: center;">spam</th>
<th style="text-align: center;">adult</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.7179</td>
<td style="text-align: center;">0.5949</td>
<td style="text-align: center;">-9.541e-18</td>
<td style="text-align: center;">9.051</td>
</tr>
</tbody>
</table>

#### Cluster 10

``` r
pander(clust2$center[10,]*sigma + mu) #adult twitters that also have health/nutrition chatter, photo sharing, and a little politics/travel/sports fandom/current events.
```

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 12%" />
<col style="width: 21%" />
<col style="width: 11%" />
<col style="width: 20%" />
<col style="width: 20%" />
<col style="width: 12%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">chatter</th>
<th style="text-align: center;">current_events</th>
<th style="text-align: center;">travel</th>
<th style="text-align: center;">photo_sharing</th>
<th style="text-align: center;">uncategorized</th>
<th style="text-align: center;">tv_film</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">4.653</td>
<td style="text-align: center;">1.878</td>
<td style="text-align: center;">2.245</td>
<td style="text-align: center;">2.449</td>
<td style="text-align: center;">0.9184</td>
<td style="text-align: center;">0.8776</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 20%" />
<col style="width: 13%" />
<col style="width: 10%" />
<col style="width: 11%" />
<col style="width: 22%" />
<col style="width: 11%" />
<col style="width: 11%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">sports_fandom</th>
<th style="text-align: center;">politics</th>
<th style="text-align: center;">food</th>
<th style="text-align: center;">family</th>
<th style="text-align: center;">home_and_garden</th>
<th style="text-align: center;">music</th>
<th style="text-align: center;">news</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">1.898</td>
<td style="text-align: center;">2.245</td>
<td style="text-align: center;">1.469</td>
<td style="text-align: center;">0.7959</td>
<td style="text-align: center;">0.6939</td>
<td style="text-align: center;">0.6939</td>
<td style="text-align: center;">1.204</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 20%" />
<col style="width: 14%" />
<col style="width: 24%" />
<col style="width: 18%" />
<col style="width: 22%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">online_gaming</th>
<th style="text-align: center;">shopping</th>
<th style="text-align: center;">health_nutrition</th>
<th style="text-align: center;">college_uni</th>
<th style="text-align: center;">sports_playing</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">1.449</td>
<td style="text-align: center;">0.9592</td>
<td style="text-align: center;">2.796</td>
<td style="text-align: center;">1.918</td>
<td style="text-align: center;">0.5306</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 13%" />
<col style="width: 12%" />
<col style="width: 16%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 12%" />
<col style="width: 17%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">cooking</th>
<th style="text-align: center;">eco</th>
<th style="text-align: center;">computers</th>
<th style="text-align: center;">business</th>
<th style="text-align: center;">outdoors</th>
<th style="text-align: center;">crafts</th>
<th style="text-align: center;">automotive</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">1.796</td>
<td style="text-align: center;">0.8571</td>
<td style="text-align: center;">1</td>
<td style="text-align: center;">0.1837</td>
<td style="text-align: center;">1.143</td>
<td style="text-align: center;">0.6939</td>
<td style="text-align: center;">1</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 10%" />
<col style="width: 14%" />
<col style="width: 11%" />
<col style="width: 15%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 24%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">art</th>
<th style="text-align: center;">religion</th>
<th style="text-align: center;">beauty</th>
<th style="text-align: center;">parenting</th>
<th style="text-align: center;">dating</th>
<th style="text-align: center;">school</th>
<th style="text-align: center;">personal_fitness</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">1.265</td>
<td style="text-align: center;">1.327</td>
<td style="text-align: center;">0.5714</td>
<td style="text-align: center;">1.204</td>
<td style="text-align: center;">0.6939</td>
<td style="text-align: center;">0.8776</td>
<td style="text-align: center;">1.755</td>
</tr>
</tbody>
</table>

<table style="width:60%;">
<colgroup>
<col style="width: 13%" />
<col style="width: 23%" />
<col style="width: 11%" />
<col style="width: 11%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">fashion</th>
<th style="text-align: center;">small_business</th>
<th style="text-align: center;">spam</th>
<th style="text-align: center;">adult</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.9592</td>
<td style="text-align: center;">0.5306</td>
<td style="text-align: center;">1.041</td>
<td style="text-align: center;">7.204</td>
</tr>
</tbody>
</table>

#### Cluster 11

``` r
pander(clust2$center[11,]*sigma + mu) #high in dating and chatter; maybe the "gossip people" 
```

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 12%" />
<col style="width: 21%" />
<col style="width: 11%" />
<col style="width: 20%" />
<col style="width: 20%" />
<col style="width: 12%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">chatter</th>
<th style="text-align: center;">current_events</th>
<th style="text-align: center;">travel</th>
<th style="text-align: center;">photo_sharing</th>
<th style="text-align: center;">uncategorized</th>
<th style="text-align: center;">tv_film</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">7.943</td>
<td style="text-align: center;">1.615</td>
<td style="text-align: center;">1.469</td>
<td style="text-align: center;">2.641</td>
<td style="text-align: center;">1.526</td>
<td style="text-align: center;">0.9427</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 20%" />
<col style="width: 13%" />
<col style="width: 10%" />
<col style="width: 11%" />
<col style="width: 22%" />
<col style="width: 10%" />
<col style="width: 11%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">sports_fandom</th>
<th style="text-align: center;">politics</th>
<th style="text-align: center;">food</th>
<th style="text-align: center;">family</th>
<th style="text-align: center;">home_and_garden</th>
<th style="text-align: center;">music</th>
<th style="text-align: center;">news</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">1.344</td>
<td style="text-align: center;">1.328</td>
<td style="text-align: center;">1.167</td>
<td style="text-align: center;">0.7604</td>
<td style="text-align: center;">0.9479</td>
<td style="text-align: center;">0.651</td>
<td style="text-align: center;">0.9271</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 20%" />
<col style="width: 14%" />
<col style="width: 24%" />
<col style="width: 18%" />
<col style="width: 22%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">online_gaming</th>
<th style="text-align: center;">shopping</th>
<th style="text-align: center;">health_nutrition</th>
<th style="text-align: center;">college_uni</th>
<th style="text-align: center;">sports_playing</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">1.042</td>
<td style="text-align: center;">1.229</td>
<td style="text-align: center;">2.141</td>
<td style="text-align: center;">1.427</td>
<td style="text-align: center;">0.9479</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 13%" />
<col style="width: 12%" />
<col style="width: 16%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 12%" />
<col style="width: 17%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">cooking</th>
<th style="text-align: center;">eco</th>
<th style="text-align: center;">computers</th>
<th style="text-align: center;">business</th>
<th style="text-align: center;">outdoors</th>
<th style="text-align: center;">crafts</th>
<th style="text-align: center;">automotive</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">1.531</td>
<td style="text-align: center;">0.6146</td>
<td style="text-align: center;">0.6719</td>
<td style="text-align: center;">0.7292</td>
<td style="text-align: center;">0.8594</td>
<td style="text-align: center;">0.849</td>
<td style="text-align: center;">0.5729</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 11%" />
<col style="width: 14%" />
<col style="width: 11%" />
<col style="width: 15%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 24%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">art</th>
<th style="text-align: center;">religion</th>
<th style="text-align: center;">beauty</th>
<th style="text-align: center;">parenting</th>
<th style="text-align: center;">dating</th>
<th style="text-align: center;">school</th>
<th style="text-align: center;">personal_fitness</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.6875</td>
<td style="text-align: center;">1.193</td>
<td style="text-align: center;">1.062</td>
<td style="text-align: center;">1.078</td>
<td style="text-align: center;">9.349</td>
<td style="text-align: center;">2.281</td>
<td style="text-align: center;">1.323</td>
</tr>
</tbody>
</table>

<table style="width:68%;">
<colgroup>
<col style="width: 13%" />
<col style="width: 23%" />
<col style="width: 18%" />
<col style="width: 12%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">fashion</th>
<th style="text-align: center;">small_business</th>
<th style="text-align: center;">spam</th>
<th style="text-align: center;">adult</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">2.51</td>
<td style="text-align: center;">0.5573</td>
<td style="text-align: center;">-9.541e-18</td>
<td style="text-align: center;">0.2448</td>
</tr>
</tbody>
</table>

#### Cluster 12

``` r
pander(clust2$center[12,]*sigma + mu) #into TV/Film/Art/music also likely in college
```

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 12%" />
<col style="width: 21%" />
<col style="width: 11%" />
<col style="width: 20%" />
<col style="width: 20%" />
<col style="width: 12%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">chatter</th>
<th style="text-align: center;">current_events</th>
<th style="text-align: center;">travel</th>
<th style="text-align: center;">photo_sharing</th>
<th style="text-align: center;">uncategorized</th>
<th style="text-align: center;">tv_film</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">3.94</td>
<td style="text-align: center;">1.943</td>
<td style="text-align: center;">2.089</td>
<td style="text-align: center;">2.471</td>
<td style="text-align: center;">1.437</td>
<td style="text-align: center;">5.61</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 20%" />
<col style="width: 14%" />
<col style="width: 10%" />
<col style="width: 11%" />
<col style="width: 23%" />
<col style="width: 10%" />
<col style="width: 10%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">sports_fandom</th>
<th style="text-align: center;">politics</th>
<th style="text-align: center;">food</th>
<th style="text-align: center;">family</th>
<th style="text-align: center;">home_and_garden</th>
<th style="text-align: center;">music</th>
<th style="text-align: center;">news</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">1.337</td>
<td style="text-align: center;">1.536</td>
<td style="text-align: center;">1.665</td>
<td style="text-align: center;">0.7345</td>
<td style="text-align: center;">0.7618</td>
<td style="text-align: center;">1.675</td>
<td style="text-align: center;">1.221</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 20%" />
<col style="width: 14%" />
<col style="width: 24%" />
<col style="width: 18%" />
<col style="width: 22%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">online_gaming</th>
<th style="text-align: center;">shopping</th>
<th style="text-align: center;">health_nutrition</th>
<th style="text-align: center;">college_uni</th>
<th style="text-align: center;">sports_playing</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.7146</td>
<td style="text-align: center;">1.417</td>
<td style="text-align: center;">1.861</td>
<td style="text-align: center;">2.516</td>
<td style="text-align: center;">0.7593</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 13%" />
<col style="width: 12%" />
<col style="width: 16%" />
<col style="width: 14%" />
<col style="width: 14%" />
<col style="width: 12%" />
<col style="width: 17%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">cooking</th>
<th style="text-align: center;">eco</th>
<th style="text-align: center;">computers</th>
<th style="text-align: center;">business</th>
<th style="text-align: center;">outdoors</th>
<th style="text-align: center;">crafts</th>
<th style="text-align: center;">automotive</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">1.536</td>
<td style="text-align: center;">0.5782</td>
<td style="text-align: center;">0.4615</td>
<td style="text-align: center;">0.6501</td>
<td style="text-align: center;">0.6576</td>
<td style="text-align: center;">1.132</td>
<td style="text-align: center;">0.5211</td>
</tr>
</tbody>
</table>

<table>
<caption>Table continues below</caption>
<colgroup>
<col style="width: 10%" />
<col style="width: 14%" />
<col style="width: 11%" />
<col style="width: 15%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 24%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">art</th>
<th style="text-align: center;">religion</th>
<th style="text-align: center;">beauty</th>
<th style="text-align: center;">parenting</th>
<th style="text-align: center;">dating</th>
<th style="text-align: center;">school</th>
<th style="text-align: center;">personal_fitness</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">5.067</td>
<td style="text-align: center;">1.112</td>
<td style="text-align: center;">0.7122</td>
<td style="text-align: center;">0.6228</td>
<td style="text-align: center;">0.4566</td>
<td style="text-align: center;">0.7196</td>
<td style="text-align: center;">1.077</td>
</tr>
</tbody>
</table>

<table style="width:65%;">
<colgroup>
<col style="width: 13%" />
<col style="width: 23%" />
<col style="width: 16%" />
<col style="width: 11%" />
</colgroup>
<thead>
<tr class="header">
<th style="text-align: center;">fashion</th>
<th style="text-align: center;">small_business</th>
<th style="text-align: center;">spam</th>
<th style="text-align: center;">adult</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: center;">0.9156</td>
<td style="text-align: center;">0.8288</td>
<td style="text-align: center;">6.158e-17</td>
<td style="text-align: center;">0.196</td>
</tr>
</tbody>
</table>

#### Cluster sizes

``` r
  pander(clust2$size)
```

*451*, *3184*, *341*, *417*, *936*, *732*, *341*, *641*, *195*, *49*,
*192* and *403* These are giving us the values for the center of the
different clusters which will help us see patterns of tweeting in
different market segments. I also called the cluster sizes so we can see
how many people fell into each market segment/cluster

There are definitely some distinct groups that can be seen in these
clusters.I will come back to these at the end of the report. Now, I’d
like to look at what a PCA approach would look like for this.

### PCAs

``` r
  PCAs = prcomp(X, scale=TRUE)
  
  # variance plot
  plot(PCAs)
```

<img src="gb_prediction_files/figure-markdown_github/unnamed-chunk-40-1.png" style="display: block; margin: auto;" />

``` r
  summary(PCAs)
```

    ## Importance of components:
    ##                           PC1     PC2     PC3     PC4     PC5     PC6     PC7
    ## Standard deviation     2.1186 1.69824 1.59388 1.53457 1.48027 1.36885 1.28577
    ## Proportion of Variance 0.1247 0.08011 0.07057 0.06541 0.06087 0.05205 0.04592
    ## Cumulative Proportion  0.1247 0.20479 0.27536 0.34077 0.40164 0.45369 0.49961
    ##                            PC8     PC9    PC10    PC11    PC12    PC13    PC14
    ## Standard deviation     1.19277 1.15127 1.06930 1.00566 0.96785 0.96131 0.94405
    ## Proportion of Variance 0.03952 0.03682 0.03176 0.02809 0.02602 0.02567 0.02476
    ## Cumulative Proportion  0.53913 0.57595 0.60771 0.63580 0.66182 0.68749 0.71225
    ##                           PC15    PC16   PC17    PC18    PC19    PC20    PC21
    ## Standard deviation     0.93297 0.91698 0.9020 0.85869 0.83466 0.80544 0.75311
    ## Proportion of Variance 0.02418 0.02336 0.0226 0.02048 0.01935 0.01802 0.01575
    ## Cumulative Proportion  0.73643 0.75979 0.7824 0.80287 0.82222 0.84024 0.85599
    ##                           PC22    PC23    PC24    PC25    PC26    PC27    PC28
    ## Standard deviation     0.69632 0.68558 0.65317 0.64881 0.63756 0.63626 0.61513
    ## Proportion of Variance 0.01347 0.01306 0.01185 0.01169 0.01129 0.01125 0.01051
    ## Cumulative Proportion  0.86946 0.88252 0.89437 0.90606 0.91735 0.92860 0.93911
    ##                           PC29    PC30    PC31   PC32    PC33    PC34    PC35
    ## Standard deviation     0.60167 0.59424 0.58683 0.5498 0.48442 0.47576 0.43757
    ## Proportion of Variance 0.01006 0.00981 0.00957 0.0084 0.00652 0.00629 0.00532
    ## Cumulative Proportion  0.94917 0.95898 0.96854 0.9769 0.98346 0.98974 0.99506
    ##                           PC36
    ## Standard deviation     0.42165
    ## Proportion of Variance 0.00494
    ## Cumulative Proportion  1.00000

Examining the summary, we can see that to conserve 75% of the variance,
you’d have to go with 16 PCAs, which makes it seem like most of the
features are relatively uncorrelated and shouldn’t be compressed. I
would rather go with clustering here, which won’t be as destructive to
the variance.

Number of people in each cluster: cluster 1: 451 cluster 2: 3184 cluster
3: 341 cluster 4: 417 cluster 5: 936 cluster 6: 732 cluster 7: 341
cluster 8: 641 cluster 9: 195 cluster 10: 49 cluster 11: 192 cluster 12:
403

Using the K++ clustering as our main descriptive tool here, we can see
some distinct groups of followers for NutrientH2O:

### Cluster 6

Cluster 6 is probably athletes given that their top shared things were
personal fitness, outdoors, cooking, photo sharing, and food. Athletes
are useful to health and fitness brand like NutrientH2O, since they need
healthy and fit people to endorse their products. This cluster also
included 732 people, the third biggest cluster, so this is an important
group.

### Clusters 9 and 10

Clusters 9 and 10 shared more adult content than any other category of
content, so NutrientH2O should be aware of this cluster. They may want
to block some of these accounts from interacting with them. From a
marketing perspective, NutrientH2O probably doesn’t want to be
associated with adult content accounts. These are also the smallest and
third smallest cluster in terms of twitter accounts, so this isn’t a
very big chunk of NutrientH2O’s followers.

### Cluster 12

Cluster 12 was sharing a lot about TV/film/art and college, which could
be useful information for NutrientH2O. Knowing that they have followers
into the arts, they could try to do some targeted advertising related to
movies, popular tv shoes, colleges, etc. This cluster is 403 people
which is a sizable amount.

### Cluster 8

Cluster 8 was sharing a lot about sports fandom, parenting, food and
religion. This could be another interesting market segment to try to
appeal to through targetted marketing somehow since they are the fourth
biggest market segment. NutrientH2O could try to advertise through the
sports they are fans of, or through their children/ religious
institution. You can see below that cluster 8 is dominating when it
comes to sharing a lot about both religion and sports fandom.

``` r
  fviz_cluster(clust2 , data = X, choose.vars= c(7,27), geom="point")
```

<img src="gb_prediction_files/figure-markdown_github/unnamed-chunk-41-1.png" style="display: block; margin: auto;" />

### Cluster 3 and 4

Clusters 3 and 4 are very high in politics, news, and cluster 3 is high
in automotive, computer and travelling twitter posts. This market
segment seems like they are probably older, given their posts about news
and politics. In the plot below, you see that many of the members with
high news and politics shares are in clusters 3 and 4.

``` r
fviz_cluster(clust2 , data = X, choose.vars= c(8,13), geom="point")
```

<img src="gb_prediction_files/figure-markdown_github/unnamed-chunk-42-1.png" style="display: block; margin: auto;" />

### Cluster 2

Our biggest cluster was cluster 2. Cluster 2 has 3184 members, whearas
the next biggest cluster only has 936. Basiaclly, cluster 2 is massive.
Cluster 2 is tricky because the cluster center is below average on every
category of tweet. This suggests to me that cluster 2 may be capturing
the inactive/relatively inactive group of followers that NutrientH2O
has. The categories they are most active in are chatter, photo sharing,
current events, health and nutrition, travel, and sports fandom, in that
order. The fact that cluster 2 represent a fairly inactive group on
twitter can best be seen from our PCA analysis. We see all the variation
vectors pointing left because the first PCA coincides with inactiveness
on twitter.

``` r
fviz_pca_var(PCAs, col.var="contrib",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE, title = "Variables Contribution in first two PCAs " )
```

<img src="gb_prediction_files/figure-markdown_github/unnamed-chunk-43-1.png" style="display: block; margin: auto;" />

### Cluster 5

This was our second biggest cluster, cluster 5, at 936 members. This
group really seperates itself from the rest of the sample in the amount
of photo sharing and shopping that appear on these member’s accounts.
This is another important market segment that has a lot going on in and
around twitter so maybe Nutrient H2O needs to start sharing some photos
of fashionable people using their product or vouching for their brand,
etc. You can see below that cluster 5 is dominating when it comes to
shopping and photo sharing posts.

``` r
fviz_cluster(clust2 , data = X, choose.vars= c(4,15), geom="point")
```

<img src="gb_prediction_files/figure-markdown_github/unnamed-chunk-44-1.png" style="display: block; margin: auto;" />

### Conclusion

These are just a few of the interesting market segments I saw in the
clusters, but you could formulate advertising plans for more or less of
the clusters here. It’s up to the advertising firm which of these
clusters of the NutrientH2O audience they want to utilize.

``` r
fviz_pca_var(PCAs,axes = c(2,3), col.var="contrib",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE, title = "Variables Contribution in second two PCAs " )
```

<img src="gb_prediction_files/figure-markdown_github/unnamed-chunk-45-1.png" style="display: block; margin: auto;" />
Looking at PCA 2 and PCA 3(we took out the PCA1 because this largely
represent how inactive people are), you can see the related topics, and
how the vectors are pointing in similar directions when they are
clustered together. This provides a nice grouping of intersts for
NutrientH2O to utilize in their advertising focus. In conclusion, one
market segment to focus on is interested in
religion/sportsfandom/parenting/food/school/family. This market segment
seems to be probably parents. A second market segment to focus on is
intersted in news/computers/travel/politics. This market segment seems
like it might be the generation of working, young millenials. A third
market segment to focus on is interested in photo
sharing/shopping/fashion/cooking/nutrition/health/chatter/beauty. This
group seems more likely to be high schoolers and people more into how
they look.
