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
<td style="text-align: right;">0.5084030</td>
</tr>
<tr class="even">
<td>Linear Model</td>
<td style="text-align: right;">0.4952327</td>
</tr>
<tr class="odd">
<td>KNN Model</td>
<td style="text-align: right;">0.5302056</td>
</tr>
<tr class="even">
<td>Linear Model (Log Shares)</td>
<td style="text-align: right;">0.5873944</td>
</tr>
</tbody>
</table>

In table 1 we can observe so far the model with the best accuracy is the
linear model over the log of shares. We can see that the linear model
over shares is even worse that the null model. We can see that the
linear model of log shares has a gain in accuracy of 7.8991411%
comparing with the null model, it means a lift of 1.1553717.

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
<td style="text-align: right;">1310.20</td>
</tr>
<tr class="even">
<td>False Negative</td>
<td style="text-align: right;">570.50</td>
</tr>
<tr class="odd">
<td>False Positive</td>
<td style="text-align: right;">2701.05</td>
</tr>
<tr class="even">
<td>True Positive</td>
<td style="text-align: right;">3347.25</td>
</tr>
</tbody>
</table>

**The stats are the following:**

Overall error rate = 41.2605625%

True positive rate = 85.4380703%

False positive rate = 67.3368651%

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
<td style="text-align: right;">0.6267550</td>
</tr>
<tr class="even">
<td>Logit Model</td>
<td style="text-align: right;">0.6288738</td>
</tr>
<tr class="odd">
<td>KNN Classification Model</td>
<td style="text-align: right;">0.5887249</td>
</tr>
</tbody>
</table>

In the table 3 we can see that the model with the best accuraccy is the
Logit Model, which is slightly superior to the Linear Probability model
(0.6288738 vs 0.626755). This result was expected since in this approach
we are working directly over the binary variable, then the prediction
rank will have less variation. In the first case we predicted the number
of shares, which have a huge rank of possible outcomes. In the table 4,
we present the confusion matrix for our best model and then we present
the requested stats. We can see that the logistic model gives a gain of
accuracy of 4.1479379% over the lineal model of log shares. It
represents a lift of 1.0706159.

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
<td style="text-align: right;">2485.14</td>
</tr>
<tr class="even">
<td>False Negative</td>
<td style="text-align: right;">1415.17</td>
</tr>
<tr class="odd">
<td>False Positive</td>
<td style="text-align: right;">1527.49</td>
</tr>
<tr class="even">
<td>True Positive</td>
<td style="text-align: right;">2501.20</td>
</tr>
</tbody>
</table>

**The stats are the following:**

Overall error rate = 37.1126245%

True positive rate = 63.865263%

False positive rate = 38.0670533%

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
<td style="text-align: right;">-0.0237341</td>
<td style="text-align: right;">0.0036379</td>
<td style="text-align: right;">-6.5242176</td>
<td style="text-align: right;">0.0000000</td>
<td style="text-align: right;">-0.0308642</td>
<td style="text-align: right;">-0.0166041</td>
</tr>
<tr class="even">
<td style="text-align: left;">data_channel_is_bus</td>
<td style="text-align: right;">-0.0653706</td>
<td style="text-align: right;">0.0104623</td>
<td style="text-align: right;">-6.2481796</td>
<td style="text-align: right;">0.0000000</td>
<td style="text-align: right;">-0.0858764</td>
<td style="text-align: right;">-0.0448648</td>
</tr>
<tr class="odd">
<td style="text-align: left;">data_channel_is_entertainment</td>
<td style="text-align: right;">-0.1969016</td>
<td style="text-align: right;">0.0094812</td>
<td style="text-align: right;">-20.7676207</td>
<td style="text-align: right;">0.0000000</td>
<td style="text-align: right;">-0.2154844</td>
<td style="text-align: right;">-0.1783188</td>
</tr>
<tr class="even">
<td style="text-align: left;">data_channel_is_lifestyle</td>
<td style="text-align: right;">-0.0508888</td>
<td style="text-align: right;">0.0139631</td>
<td style="text-align: right;">-3.6445293</td>
<td style="text-align: right;">0.0002679</td>
<td style="text-align: right;">-0.0782559</td>
<td style="text-align: right;">-0.0235217</td>
</tr>
<tr class="odd">
<td style="text-align: left;">data_channel_is_socmed</td>
<td style="text-align: right;">0.1478814</td>
<td style="text-align: right;">0.0142287</td>
<td style="text-align: right;">10.3932051</td>
<td style="text-align: right;">0.0000000</td>
<td style="text-align: right;">0.1199938</td>
<td style="text-align: right;">0.1757691</td>
</tr>
<tr class="even">
<td style="text-align: left;">data_channel_is_tech</td>
<td style="text-align: right;">0.0265592</td>
<td style="text-align: right;">0.0100932</td>
<td style="text-align: right;">2.6314031</td>
<td style="text-align: right;">0.0085033</td>
<td style="text-align: right;">0.0067769</td>
<td style="text-align: right;">0.0463414</td>
</tr>
<tr class="odd">
<td style="text-align: left;">data_channel_is_world</td>
<td style="text-align: right;">-0.2177634</td>
<td style="text-align: right;">0.0098956</td>
<td style="text-align: right;">-22.0060349</td>
<td style="text-align: right;">0.0000000</td>
<td style="text-align: right;">-0.2371584</td>
<td style="text-align: right;">-0.1983683</td>
</tr>
<tr class="even">
<td style="text-align: left;">global_rate_negative_words</td>
<td style="text-align: right;">-0.2067665</td>
<td style="text-align: right;">0.2656443</td>
<td style="text-align: right;">-0.7783585</td>
<td style="text-align: right;">0.4363577</td>
<td style="text-align: right;">-0.7274198</td>
<td style="text-align: right;">0.3138868</td>
</tr>
<tr class="odd">
<td style="text-align: left;">global_rate_positive_words</td>
<td style="text-align: right;">0.4796460</td>
<td style="text-align: right;">0.1754231</td>
<td style="text-align: right;">2.7342240</td>
<td style="text-align: right;">0.0062527</td>
<td style="text-align: right;">0.1358231</td>
<td style="text-align: right;">0.8234689</td>
</tr>
<tr class="even">
<td style="text-align: left;">is_weekend</td>
<td style="text-align: right;">0.1957478</td>
<td style="text-align: right;">0.0080521</td>
<td style="text-align: right;">24.3100737</td>
<td style="text-align: right;">0.0000000</td>
<td style="text-align: right;">0.1799659</td>
<td style="text-align: right;">0.2115296</td>
</tr>
<tr class="odd">
<td style="text-align: left;">n_tokens_content</td>
<td style="text-align: right;">0.0000297</td>
<td style="text-align: right;">0.0000072</td>
<td style="text-align: right;">4.1171629</td>
<td style="text-align: right;">0.0000384</td>
<td style="text-align: right;">0.0000156</td>
<td style="text-align: right;">0.0000439</td>
</tr>
<tr class="even">
<td style="text-align: left;">n_tokens_title</td>
<td style="text-align: right;">-0.0026840</td>
<td style="text-align: right;">0.0012953</td>
<td style="text-align: right;">-2.0721104</td>
<td style="text-align: right;">0.0382552</td>
<td style="text-align: right;">-0.0052227</td>
<td style="text-align: right;">-0.0001453</td>
</tr>
<tr class="odd">
<td style="text-align: left;">num_hrefs</td>
<td style="text-align: right;">0.0030135</td>
<td style="text-align: right;">0.0003162</td>
<td style="text-align: right;">9.5301964</td>
<td style="text-align: right;">0.0000000</td>
<td style="text-align: right;">0.0023938</td>
<td style="text-align: right;">0.0036333</td>
</tr>
<tr class="even">
<td style="text-align: left;">num_imgs</td>
<td style="text-align: right;">0.0015849</td>
<td style="text-align: right;">0.0003860</td>
<td style="text-align: right;">4.1062568</td>
<td style="text-align: right;">0.0000402</td>
<td style="text-align: right;">0.0008284</td>
<td style="text-align: right;">0.0023414</td>
</tr>
<tr class="odd">
<td style="text-align: left;">num_keywords</td>
<td style="text-align: right;">0.0101207</td>
<td style="text-align: right;">0.0014717</td>
<td style="text-align: right;">6.8769224</td>
<td style="text-align: right;">0.0000000</td>
<td style="text-align: right;">0.0072362</td>
<td style="text-align: right;">0.0130052</td>
</tr>
<tr class="even">
<td style="text-align: left;">num_self_hrefs</td>
<td style="text-align: right;">-0.0062069</td>
<td style="text-align: right;">0.0008200</td>
<td style="text-align: right;">-7.5690739</td>
<td style="text-align: right;">0.0000000</td>
<td style="text-align: right;">-0.0078141</td>
<td style="text-align: right;">-0.0045997</td>
</tr>
<tr class="odd">
<td style="text-align: left;">num_videos</td>
<td style="text-align: right;">0.0006990</td>
<td style="text-align: right;">0.0006963</td>
<td style="text-align: right;">1.0038433</td>
<td style="text-align: right;">0.3154542</td>
<td style="text-align: right;">-0.0006657</td>
<td style="text-align: right;">0.0020637</td>
</tr>
<tr class="even">
<td style="text-align: left;">self_reference_avg_sharess</td>
<td style="text-align: right;">0.0000016</td>
<td style="text-align: right;">0.0000002</td>
<td style="text-align: right;">8.3373989</td>
<td style="text-align: right;">0.0000000</td>
<td style="text-align: right;">0.0000012</td>
<td style="text-align: right;">0.0000020</td>
</tr>
<tr class="odd">
<td style="text-align: left;">title_subjectivity</td>
<td style="text-align: right;">0.0218957</td>
<td style="text-align: right;">0.0084953</td>
<td style="text-align: right;">2.5773988</td>
<td style="text-align: right;">0.0099547</td>
<td style="text-align: right;">0.0052453</td>
<td style="text-align: right;">0.0385461</td>
</tr>
</tbody>
</table>
