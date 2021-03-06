Question 3. Predicting when articles go viral
=============================================

Using the data of 39,797 online articles published by Mashable during
2013 and 2014, the goal is building a model to determine if an article
goes viral or not. An article is considered viral if it was shared more
than 1400 times. We have a set o features of each article such as things
like how long the headline is, how long the article is, how positive or
negative the “sentiment” of the article was, among others. Beyond to get
the best model to classify, Mashable wants to know if there is anything
they can learn about how to improve an article’s chance of reaching this
threshold.

To deal with this problem we are going to work with two approach. The
first approach is from the standpoint of regression. we will build three
models following techniques such as linear regression, K nearest
neighbor and transforming the objective variable. In this first approach
the objective variable will be the number of shares. The second approach
is from the standpoint of classification. In this case our objective
variable will be a binary entry Viral, which is 1 if the article is
viral or 0 otherwise. In both approach, we have measures that help us to
classify the model performance.

Approach \#1 Working with Shares as objective variable
------------------------------------------------------

In the first approach our objective variable is number of shares. To
start we anylized all the set of features([see
features](https://github.com/jgscott/ECO395M/blob/master/data/online_news_codes.txt))
we have to decide which of them are important to include in the models.
Then we start fitting linear models with several combinations of
variables. We used the function step to test if including some
interactions in the model would be helpful, but finally we decided work
with a more parsimonious model, given it has a good fitting. Below we
can see the variables we used in our linear models, we ran the first
using shares as explained variable and then we used log of shares as
explanatory variable. Then, we decided to try with a knn model as well.
For this last model, we did not consider the binary variables since they
do not add too much information in this methodology. The variables used
in the knn model are summarized below.

**Specification for Linear models:**

Shares or log(Shares) ~ n\_tokens\_title + n\_tokens\_content +
num\_hrefs + num\_self\_hrefs + num\_imgs + num\_videos +
average\_token\_length + num\_keywords + data\_channel\_is\_lifestyle +
data\_channel\_is\_entertainment + data\_channel\_is\_bus +
data\_channel\_is\_socmed + data\_channel\_is\_tech +
data\_channel\_is\_world + self\_reference\_avg\_sharess + is\_weekend +
global\_rate\_negative\_words + global\_rate\_positive\_words +
title\_subjectivity

**For KNN model the specification:**

Shares ~ n\_tokens\_title, n\_tokens\_content, num\_hrefs,
num\_self\_hrefs, num\_imgs, num\_videos, average\_token\_length,
num\_keywords, self\_reference\_avg\_sharess

Since the predictions of our model are numerical (number of shares), we
needed the evaluation in terms of a binary prediction (viral or not).
For that reason after generated prediction of our models across multiple
train/test splits we summarized the accuracy rate of each model
considering a threshold of 1400 shares to consider an article viral. In
the table 1 we can see the accuracy ratio for our three models plus a
“null” model that always predicts the articles as “not viral”.

**Table 1. Accuracy rate for models with Shares as objective variable**

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Accuracy Rate</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>Null Model</td>
<td style="text-align: right;">0.5074886</td>
</tr>
<tr class="even">
<td>Linear Model</td>
<td style="text-align: right;">0.4959352</td>
</tr>
<tr class="odd">
<td>KNN Model</td>
<td style="text-align: right;">0.5305839</td>
</tr>
<tr class="even">
<td>Linear Model (Log Shares)</td>
<td style="text-align: right;">0.5874322</td>
</tr>
</tbody>
</table>

In table 1 we can observe so far the model with the best accuracy is the
linear model over the log of shares. We can see that the linear model
over shares is even worse that the null model. We can see that the
linear model of log shares has a gain in accuracy of 7.9943641%
comparing with the null model, it means a lift of 1.157528.

Having found our best model for the prediction of number of shares we
proceed to present the Confusion matrix and the requested stats:

**Table 2. Confusion Matrix for the Linear Model of Log of Shares**

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Linear Model Log (Shares)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>True Negative</td>
<td style="text-align: right;">1314.87</td>
</tr>
<tr class="even">
<td>False Negative</td>
<td style="text-align: right;">571.21</td>
</tr>
<tr class="odd">
<td>False Positive</td>
<td style="text-align: right;">2700.04</td>
</tr>
<tr class="even">
<td>True Positive</td>
<td style="text-align: right;">3342.88</td>
</tr>
</tbody>
</table>

**The stats are the following:**

Overall error rate = 41.2567789%

True positive rate = 85.4063141%

False positive rate = 67.2503244%

Approach \#2 Working with binary variable viral as objective
------------------------------------------------------------

In the second approach we handled this problem from the standpoint of
classification. That is, we defined a binary variable viral and built
our very models for directly predicting viral status as a target
variable. We worked with the same specification of our first lineal
model, but using Linear probability model regression and a a logit model
regression. In the case of the Knn approach we used the same variables
of the knn model for shares.The table 3 summarized the accuracy rate for
the three classification models.

**Table 3. Accuracy rate for models with viral as objective variable**

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Accuracy Rate</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>Linear Probability Model</td>
<td style="text-align: right;">0.6269378</td>
</tr>
<tr class="even">
<td>Logit Model</td>
<td style="text-align: right;">0.6284286</td>
</tr>
<tr class="odd">
<td>KNN Classification Model</td>
<td style="text-align: right;">0.5863287</td>
</tr>
</tbody>
</table>

In the table 3 we can see that the model with the best accuraccy is the
Logit Model, which is slightly superior to the Linear Probability model
(0.6284286 vs 0.6269378). This result was expected since in this
approach we are working directly over the binary variable, then the
prediction rank will have less variation. In the first case we predicted
the number of shares, which have a huge rank of possible outcomes. In
the table 4, we present the confusion matrix for our best model and then
we present the requested stats. We can see that the logistic model gives
a gain of accuracy of 4.0996343% over the lineal model of log shares. It
represents a lift of 1.0697891.

**Table 4. Confusion Matrix for the Logistic Model of Viral**

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Logit Model</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>True Negative</td>
<td style="text-align: right;">2483.89</td>
</tr>
<tr class="even">
<td>False Negative</td>
<td style="text-align: right;">1414.25</td>
</tr>
<tr class="odd">
<td>False Positive</td>
<td style="text-align: right;">1531.94</td>
</tr>
<tr class="even">
<td>True Positive</td>
<td style="text-align: right;">2498.92</td>
</tr>
</tbody>
</table>

**The stats are the following:**

Overall error rate = 37.1571447%

True positive rate = 63.8592241%

False positive rate = 38.1475311%

In addition, we decided to include a graph to see the advantages in
accuracy of the probabilistic models over the Knn classification model
with differents values of K (see graph 1).

**Graph 1. KNN models vs LPM and Logit Models**
![](viral_files/figure-markdown_strict/unnamed-chunk-8-1.png)

How can we increase the probability that an article goes viral?
---------------------------------------------------------------

By this point we have adressed the problem to find the best model to
predict with the highest accuracy the binary output viral. But we also
want to know what features would increase the probability of an article
to go viral or not. However, since our best model is a logistic model we
know that the coefficients generated do not have a direct interpretation
as a causal effect, in this case a probability of succes. Therefore, in
table 6 we compute the average marginal effect of all the variables we
included in our logit model, because them can be readed as the partial
causal effect of each variable over the probability of an article to go
viral. Thus, if we want to increase the probability to be viral we
should increase the features with the higher partial effect such as
writing an article about social media or releasing the article in a
weekend. In the other hand we should avoid the characteristic that have
a negative partial effect such as writing about entertainment or
including a large number of negative words.

**Table 6. Average Marginal Effects of the Logit Model**

<table>
<thead>
<tr class="header">
<th style="text-align: left;">factor</th>
<th style="text-align: right;">AME</th>
<th style="text-align: right;">SE</th>
<th style="text-align: right;">z</th>
<th style="text-align: right;">p</th>
<th style="text-align: right;">lower</th>
<th style="text-align: right;">upper</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">average_token_length</td>
<td style="text-align: right;">-0.0256139</td>
<td style="text-align: right;">0.0036413</td>
<td style="text-align: right;">-7.034253</td>
<td style="text-align: right;">0.0000000</td>
<td style="text-align: right;">-0.0327507</td>
<td style="text-align: right;">-0.0184771</td>
</tr>
<tr class="even">
<td style="text-align: left;">data_channel_is_bus</td>
<td style="text-align: right;">-0.0644054</td>
<td style="text-align: right;">0.0104587</td>
<td style="text-align: right;">-6.158092</td>
<td style="text-align: right;">0.0000000</td>
<td style="text-align: right;">-0.0849040</td>
<td style="text-align: right;">-0.0439068</td>
</tr>
<tr class="odd">
<td style="text-align: left;">data_channel_is_entertainment</td>
<td style="text-align: right;">-0.1963339</td>
<td style="text-align: right;">0.0095150</td>
<td style="text-align: right;">-20.634066</td>
<td style="text-align: right;">0.0000000</td>
<td style="text-align: right;">-0.2149831</td>
<td style="text-align: right;">-0.1776848</td>
</tr>
<tr class="even">
<td style="text-align: left;">data_channel_is_lifestyle</td>
<td style="text-align: right;">-0.0467247</td>
<td style="text-align: right;">0.0138914</td>
<td style="text-align: right;">-3.363572</td>
<td style="text-align: right;">0.0007694</td>
<td style="text-align: right;">-0.0739514</td>
<td style="text-align: right;">-0.0194981</td>
</tr>
<tr class="odd">
<td style="text-align: left;">data_channel_is_socmed</td>
<td style="text-align: right;">0.1499195</td>
<td style="text-align: right;">0.0142640</td>
<td style="text-align: right;">10.510316</td>
<td style="text-align: right;">0.0000000</td>
<td style="text-align: right;">0.1219625</td>
<td style="text-align: right;">0.1778764</td>
</tr>
<tr class="even">
<td style="text-align: left;">data_channel_is_tech</td>
<td style="text-align: right;">0.0254192</td>
<td style="text-align: right;">0.0101054</td>
<td style="text-align: right;">2.515413</td>
<td style="text-align: right;">0.0118893</td>
<td style="text-align: right;">0.0056130</td>
<td style="text-align: right;">0.0452253</td>
</tr>
<tr class="odd">
<td style="text-align: left;">data_channel_is_world</td>
<td style="text-align: right;">-0.2085528</td>
<td style="text-align: right;">0.0098613</td>
<td style="text-align: right;">-21.148701</td>
<td style="text-align: right;">0.0000000</td>
<td style="text-align: right;">-0.2278805</td>
<td style="text-align: right;">-0.1892251</td>
</tr>
<tr class="even">
<td style="text-align: left;">global_rate_negative_words</td>
<td style="text-align: right;">-0.3877736</td>
<td style="text-align: right;">0.2665204</td>
<td style="text-align: right;">-1.454949</td>
<td style="text-align: right;">0.1456833</td>
<td style="text-align: right;">-0.9101439</td>
<td style="text-align: right;">0.1345967</td>
</tr>
<tr class="odd">
<td style="text-align: left;">global_rate_positive_words</td>
<td style="text-align: right;">0.5197897</td>
<td style="text-align: right;">0.1753182</td>
<td style="text-align: right;">2.964835</td>
<td style="text-align: right;">0.0030285</td>
<td style="text-align: right;">0.1761723</td>
<td style="text-align: right;">0.8634071</td>
</tr>
<tr class="even">
<td style="text-align: left;">is_weekend</td>
<td style="text-align: right;">0.1961620</td>
<td style="text-align: right;">0.0080755</td>
<td style="text-align: right;">24.290943</td>
<td style="text-align: right;">0.0000000</td>
<td style="text-align: right;">0.1803342</td>
<td style="text-align: right;">0.2119897</td>
</tr>
<tr class="odd">
<td style="text-align: left;">n_tokens_content</td>
<td style="text-align: right;">0.0000375</td>
<td style="text-align: right;">0.0000072</td>
<td style="text-align: right;">5.207723</td>
<td style="text-align: right;">0.0000002</td>
<td style="text-align: right;">0.0000234</td>
<td style="text-align: right;">0.0000516</td>
</tr>
<tr class="even">
<td style="text-align: left;">n_tokens_title</td>
<td style="text-align: right;">-0.0034511</td>
<td style="text-align: right;">0.0012986</td>
<td style="text-align: right;">-2.657632</td>
<td style="text-align: right;">0.0078692</td>
<td style="text-align: right;">-0.0059962</td>
<td style="text-align: right;">-0.0009060</td>
</tr>
<tr class="odd">
<td style="text-align: left;">num_hrefs</td>
<td style="text-align: right;">0.0031005</td>
<td style="text-align: right;">0.0003200</td>
<td style="text-align: right;">9.689264</td>
<td style="text-align: right;">0.0000000</td>
<td style="text-align: right;">0.0024733</td>
<td style="text-align: right;">0.0037276</td>
</tr>
<tr class="even">
<td style="text-align: left;">num_imgs</td>
<td style="text-align: right;">0.0016103</td>
<td style="text-align: right;">0.0003917</td>
<td style="text-align: right;">4.111125</td>
<td style="text-align: right;">0.0000394</td>
<td style="text-align: right;">0.0008426</td>
<td style="text-align: right;">0.0023780</td>
</tr>
<tr class="odd">
<td style="text-align: left;">num_keywords</td>
<td style="text-align: right;">0.0100010</td>
<td style="text-align: right;">0.0014690</td>
<td style="text-align: right;">6.808244</td>
<td style="text-align: right;">0.0000000</td>
<td style="text-align: right;">0.0071219</td>
<td style="text-align: right;">0.0128801</td>
</tr>
<tr class="even">
<td style="text-align: left;">num_self_hrefs</td>
<td style="text-align: right;">-0.0065826</td>
<td style="text-align: right;">0.0008151</td>
<td style="text-align: right;">-8.075731</td>
<td style="text-align: right;">0.0000000</td>
<td style="text-align: right;">-0.0081801</td>
<td style="text-align: right;">-0.0049850</td>
</tr>
<tr class="odd">
<td style="text-align: left;">num_videos</td>
<td style="text-align: right;">0.0011282</td>
<td style="text-align: right;">0.0007176</td>
<td style="text-align: right;">1.572214</td>
<td style="text-align: right;">0.1159010</td>
<td style="text-align: right;">-0.0002783</td>
<td style="text-align: right;">0.0025347</td>
</tr>
<tr class="even">
<td style="text-align: left;">self_reference_avg_sharess</td>
<td style="text-align: right;">0.0000014</td>
<td style="text-align: right;">0.0000002</td>
<td style="text-align: right;">7.843119</td>
<td style="text-align: right;">0.0000000</td>
<td style="text-align: right;">0.0000011</td>
<td style="text-align: right;">0.0000018</td>
</tr>
<tr class="odd">
<td style="text-align: left;">title_subjectivity</td>
<td style="text-align: right;">0.0320992</td>
<td style="text-align: right;">0.0084751</td>
<td style="text-align: right;">3.787483</td>
<td style="text-align: right;">0.0001522</td>
<td style="text-align: right;">0.0154884</td>
<td style="text-align: right;">0.0487101</td>
</tr>
</tbody>
</table>
