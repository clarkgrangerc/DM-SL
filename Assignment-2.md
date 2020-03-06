Homework. 2
===========

#### Group Members: Clark, Zach, Zargham

### Question.1 : Saratoga Houses

The question provides a data set of variables associated with house
prices in Saratoga. We have data for more than 1,700 houses which
include their prices, landvalue and other attributes like number of
bedrooms, bathrooms, living area, lotsize etc. The task is to develop
models for predicting the market prices of houses for tax authorities so
that they can tax them at their market value. We use the given sample to
construct two different models for this question.

#### Handbuild Linear Regression Model

The first part of the question asks us to handbuild a linear regression
model with price as dependent variable and using all other variables as
independent variables. We start by assessing the medium model provided
in Professor’s script and check its RMSE by running it on 1000 different
train/test samples.

``` r
Professors Medium model
lm_medium = lm(price ~ lotSize + age + livingArea + pctCollege + bedrooms + 
                   fireplaces + bathrooms + rooms + heating + fuel + centralAir
```

    ## [1] "RMSE for Medium"

    ## [1] 66554.15

#### Part A

We make new variables like extrarooms = rooms - bedrooms. Also we
include two variables landvalue and newConstruction which improves our
RMSE. However, trying composite variables like living area per lotsize,
bathrooms per bedroom and using building value by subtracting landvalue
from the property price did not improve the out of sample RMSE of the
model.We observed that adding more variables led to higher variance.

#### Part B

We used Step() function to narrow down variables and interactions that
can give us low variance but the lowest AIC model did not perform better
at out of sample RMSE in multiple iterations. Including more interaction
variables and polynomials manually and one by one also did not help.

Looking at the co-efficients, we can say that lotsize, no. of bedrooms,
no. of bathrooms, living area, central air, heating, fuel and land value
are the most important variables in explaining the prices of houses in
the sample. Some interaction variables also come out to be significant
in the regression model but they do not contribute much to out of sample
RMSE and in most cases increase error in out of sample prediction.

So we decided to have the following model as our final best linear
regression model for house prices.

    ## % latex table generated in R 3.6.1 by xtable 1.8-4 package
    ## % Thu Mar 05 20:43:58 2020
    ## \begin{table}[ht]
    ## \centering
    ## \begin{tabular}{rrrrr}
    ##   \hline
    ##  & Estimate & Std. Error & t value & Pr($>$$|$t$|$) \\ 
    ##   \hline
    ## (Intercept) & 22376.2525 & 9848.8444 & 2.27 & 0.0232 \\ 
    ##   landValue & 0.9805 & 0.0475 & 20.66 & 0.0000 \\ 
    ##   lotSize & 7189.1818 & 2167.1758 & 3.32 & 0.0009 \\ 
    ##   livingArea & 70.6978 & 4.6875 & 15.08 & 0.0000 \\ 
    ##   bedrooms & -6110.1060 & 2426.4014 & -2.52 & 0.0119 \\ 
    ##   bathrooms & 23655.9007 & 3416.2841 & 6.92 & 0.0000 \\ 
    ##   extrarooms & 2848.3774 & 977.4766 & 2.91 & 0.0036 \\ 
    ##   centralAirYes & 9173.3413 & 3526.7060 & 2.60 & 0.0094 \\ 
    ##   heatinghot air & -1181.3351 & 12519.3972 & -0.09 & 0.9248 \\ 
    ##   heatinghot water/steam & -12224.5384 & 13041.8981 & -0.94 & 0.3487 \\ 
    ##   age & -131.3668 & 59.2143 & -2.22 & 0.0267 \\ 
    ##   newConstructionYes & -48977.0560 & 7400.9384 & -6.62 & 0.0000 \\ 
    ##   fireplaces & 1218.6589 & 3033.6448 & 0.40 & 0.6879 \\ 
    ##   fuelgas & 11622.0815 & 12329.4124 & 0.94 & 0.3460 \\ 
    ##   fueloil & 11667.3803 & 12951.5844 & 0.90 & 0.3678 \\ 
    ##   pctCollege & -242.2089 & 151.2311 & -1.60 & 0.1094 \\ 
    ##    \hline
    ## \end{tabular}
    ## \end{table}

We applied this model on 1000 random train/ test splits of our data and
calculated its out of sample root mean squared error.

    ## [1] "Mean RMSE for Best Linear Model"

    ## [1] 59539.19

#### Part C KNN Model

In the third part, the question asks us to fit a K-nearest neighbor
model. We select the same variables as our linear model and scale them
accordingly to fit a KNN model. We did 300 loops for each K starting
from 1 to 300 K’s. The average RMSE declines in the range of 100 to 150
K. However, exact value of K with minimum average RMSE changes with each
iteration of 500 training/ test splits for each K.We selected K = 135
based on our 500 training/ tests sample splits. It gave an RMSE of
80616.

![](Assignment-2_files/figure-markdown_github/R%20vs%20RMSE%20graph-1.png)

    ## [1] 80616.88

### Report: Pricing Model Comparison

We have two models for predicting the prices of houses in Saratoga. One
is the linear regression model and the other one in KNN model. Both
these models have their strengths and weaknesses. The main metric for
comparing these two models is to check their out of sample prediction
error or RMSE. By running the model on more than 500 different train/
test samples we find out that Linear regression model has lower RMSE
which means that on average linear model is predicting prices accurately
as compared to KNN model.

Linear Regression model Mean RMSE = 59,536.05 KNN Model Mean RMSE at
K-135 = 80,616.88

### Single Random Train/Test Performance

We run both these models on a same train set and predict values for both
these models on same test to compare their RMSE and Fit for same data
points.

![](Assignment-2_files/figure-markdown_github/actual%20vs%20predicted-1.png)

    ## [1] "LM RMSE"

    ## [1] 68159.41

    ## [1] "KNN RMSE"

    ## [1] 79442.51

Looking at the actual vs predicted plot we see that KNN model’s
predictions are more spread out than LM’s model predictions. We can see
that LM model’s prediction are evenly distributed around the center line
whereas the KNN model’s predictions tend to be on the lower side of the
line thus indicating on average lower prediction of prices as compared
to the actual one.Here we see that LM model has better predictions with
lower RMSE.

We can also see that the predictions for higher prices are far from the
actual prices for both models. This means that both models are not
performing good at extreme values. We check the performance of both
models on prices in lower and higher percentiles and check how their
RMSE perform at the fringe.

We run 100 train/ test random splits of the sample and run both models
for every train/test case and then check for RMSE of both models at
different percentile of prices. The table below shows that the KNN model
has higher error for higher percentile data. That means houses with
higher prices are predicted more inaccurately as compared to houses with
average prices. The RMSE of LM model is also high but lower than KNN
model but for lower percentiles, LM model has slightly higher RMSE than
KNN, however the difference is not as stark as for higher percentile
values. Here we can also prefer LM model over KNN as it also performs
better at extreme values.

Furthermore, root mean square errors for houses that have average prices
are almost the same for both models. This means that both models have
almost similar performance for values around the average.

![](Assignment-2_files/figure-markdown_github/graph-1.png)

### Conclusion

We can see that Linear regression model performs better for predicting
prices of houses in Saratoga. The linear model is easily interpretable
and we can see which variables affect prices more.

KNN model is a non parametric model and is known as a slow learning
model where it has to train on the data everytime to make a prediction
for new values. It cannot learn from the training data and cannot
develop a generalize model and that is why it is more susceptible to
noise in data and we saw that its errors increase for outliers.
Furthermore, we cannot easily see which variables are contributing more
towards price changes. With more dimensions or variables the performance
of the KNN model deteriorates as compared to Linear model where adding
more variables might improve prediction.

Given the results, we can clearly say that Linear Regression model is a
better model than KNN in this case. It has low error on average and also
at extreme values.

------------------------------------------------------------------------

### **Question 2: A Hospital Audit**

#### Part 1: Are some radiologists more clinically conservative than others in recalling patients, holding patient risk factors equal?

Here, we model recall decisions on all risk factors and the radiologist
that made the decision to gauge how conservative the doctors are
relative to each other.

``` r
brca = read.csv("brca.csv")
model_recall = glm(recall ~ . - cancer, data=brca, family=binomial)
summary(model_recall)
```

    ## 
    ## Call:
    ## glm(formula = recall ~ . - cancer, family = binomial, data = brca)
    ## 
    ## Deviance Residuals: 
    ##     Min       1Q   Median       3Q      Max  
    ## -1.0445  -0.6185  -0.5186  -0.3761   2.7939  
    ## 
    ## Coefficients:
    ##                          Estimate Std. Error z value Pr(>|z|)    
    ## (Intercept)              -3.27515    0.64028  -5.115 3.13e-07 ***
    ## radiologistradiologist34 -0.52171    0.32764  -1.592  0.11132    
    ## radiologistradiologist66  0.35466    0.27895   1.271  0.20358    
    ## radiologistradiologist89  0.46376    0.28026   1.655  0.09797 .  
    ## radiologistradiologist95 -0.05219    0.29380  -0.178  0.85900    
    ## ageage5059                0.11121    0.29534   0.377  0.70651    
    ## ageage6069                0.15683    0.36212   0.433  0.66494    
    ## ageage70plus              0.10782    0.36923   0.292  0.77028    
    ## history                   0.21588    0.23301   0.926  0.35419    
    ## symptoms                  0.72928    0.35897   2.032  0.04219 *  
    ## menopausepostmenoNoHT    -0.19342    0.23732  -0.815  0.41506    
    ## menopausepostmenounknown  0.40267    0.46399   0.868  0.38548    
    ## menopausepremeno          0.34208    0.31269   1.094  0.27396    
    ## densitydensity2           1.22015    0.53897   2.264  0.02358 *  
    ## densitydensity3           1.41907    0.53562   2.649  0.00806 ** 
    ## densitydensity4           1.00034    0.60196   1.662  0.09656 .  
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## (Dispersion parameter for binomial family taken to be 1)
    ## 
    ##     Null deviance: 834.25  on 986  degrees of freedom
    ## Residual deviance: 799.99  on 971  degrees of freedom
    ## AIC: 831.99
    ## 
    ## Number of Fisher Scoring iterations: 5

In this output, we can see the estimates on the different radiologists,
which tells us how conservative they are. Notice, our output only has
four radiologists shown but there are actually 5 radiologists of
interest. The fifth one(radiologist 13) is excluded and represented
within the intercept. Then, the radiologist estimates in this output are
just used to compare against that fifth radiologist. For example,
radiologist 34 has an estimate of -.52, which corresponds to multiplying
the radioligist 13 odds of recall by .6, holding all other risk factors
equal, therefore this radiologist is less conservative than the baseline
radiologist(the fifth radiolist not shown in the output) at the
hospital.

Analagously, radiologist 89 seems to be the most conservative with an
estimate of .46 which cooresponds to multiplying the odds of recall by
1.58(again, comparing to the fifth radiologist not shown in the output),
holding other risk factors constant.

In conclusion, yes, some radioligists seem to be more conservative than
others. This model would suggest that if the same patient saw both
radiologist 34 and radiologist 89, radiologist 89 would be about 2.6
times more likely to recall them. This is a pretty concerning figure. We
would like our cross-doctor reliability to be higher. It seems logical
that there should be some stable risk of cancer that should determine
recall and which doctor you have shouldn’t influence the decision, at
least not to the magnitude we see here. Moreover, here is our
radiologist conservativeness ranking

1.  Radiologist 89

2.  Radiologist 66

3.  Radiologist 13

4.  Radiologist 95

5.  Radiologist 34

#### Part 2: When the radiologists at this hospital interpret a mammogram to make a decision on whether to recall the patient, does the data suggest that they should be weighing some clinical risk factors more heavily than they currently are?

Let’s model cancer versus recall and risk factors. “Model B”(regresses
cancer on recall decision and risk factors) shouldn’t be any better than
“Model A”(regresses cancer on only recall decision) if doctors are using
all the risk factor information to the fullest of its potential.

``` r
model_cancer = glm(cancer ~ ., data=brca, family=binomial)
summary(model_cancer)
```

    ## 
    ## Call:
    ## glm(formula = cancer ~ ., family = binomial, data = brca)
    ## 
    ## Deviance Residuals: 
    ##     Min       1Q   Median       3Q      Max  
    ## -1.1394  -0.2468  -0.1670  -0.1380   3.2213  
    ## 
    ## Coefficients:
    ##                           Estimate Std. Error z value Pr(>|z|)    
    ## (Intercept)              -5.475184   1.308560  -4.184 2.86e-05 ***
    ## radiologistradiologist34  0.019054   0.564041   0.034   0.9731    
    ## radiologistradiologist66 -0.369522   0.541216  -0.683   0.4948    
    ## radiologistradiologist89 -0.233148   0.569854  -0.409   0.6824    
    ## radiologistradiologist95 -0.384849   0.578076  -0.666   0.5056    
    ## recall                    2.335523   0.368592   6.336 2.35e-10 ***
    ## ageage5059                0.477893   0.639295   0.748   0.4547    
    ## ageage6069                0.398328   0.812756   0.490   0.6241    
    ## ageage70plus              1.436443   0.736670   1.950   0.0512 .  
    ## history                   0.247484   0.438785   0.564   0.5727    
    ## symptoms                 -0.008199   0.715848  -0.011   0.9909    
    ## menopausepostmenoNoHT    -0.173097   0.455574  -0.380   0.7040    
    ## menopausepostmenounknown  0.819953   0.728254   1.126   0.2602    
    ## menopausepremeno          0.230478   0.661825   0.348   0.7277    
    ## densitydensity2           0.718016   1.079528   0.665   0.5060    
    ## densitydensity3           0.834956   1.081480   0.772   0.4401    
    ## densitydensity4           1.998087   1.133849   1.762   0.0780 .  
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## (Dispersion parameter for binomial family taken to be 1)
    ## 
    ##     Null deviance: 315.59  on 986  degrees of freedom
    ## Residual deviance: 260.27  on 970  degrees of freedom
    ## AIC: 294.27
    ## 
    ## Number of Fisher Scoring iterations: 7

This result implies that Model B is better than Model A from above
because the model is giving esimates to some of the risk factors even
after controling for recall. If doctors were correctly weighting all
risk factors in their recall decisions, the only non-zero estimate
should be on the recall feature. The recall variable is a proxy for the
probability of cancer since doctors want the most-at-risk patients to be
further evaluated. So, the fact that there are non-zero estimates on
features that aren’t recall suggests the model was improved even after
using the recall decisions by incorporating risk factors that shoud have
already been used in recall.

There are some pretty large estimates on some of the risk factors! For
example, tissue density type 4 had an estimate of 1.998 which
cooresponds to being 7.37x more likely to have cancer than patients with
density 1, holding all else fixed.

Family history of cancer, tissue density, and age all seem to have some
extra information that could be utilized in the recall decision.
Patients with tissue density 4 are 7.4x more likely to get cancer,
holding recall decision fixed. Patients with family history of cancer
are 1.28x more likely to get cancer than patients without history of
breast cancer, holding recall decision fixed. This “incorrect” weighting
of risk factors also shows up in the raw error rates below. This can be
seen below in the increase in false positives and false negatives when
moving from history=0 to history=1. 1.5% of the patients who weren’t
recalled ended up having cancer when they didn’t have any family history
of breast cancer. When they did have family history of breast cancer,
this figure jumps to 2.75%. 84.8% of the patients who were recalled
didn’t end up having cancer in the case where they had no family history
of breast cancer. In the case where they did have family history of
breast cancer, this figure jumps to 86.2%. This reinforces the fact that
we could get better recall performance from weighting tissue density 4
and family history of breast cancer more heavily in our decision to
perform addition diagnostic tests or not. There are other factors with
similar results but I just went over two of them.

``` r
xtabs(~cancer + recall + history, brca) %>% prop.table(margin=c(2, 3))
```

    ## , , history = 0
    ## 
    ##       recall
    ## cancer          0          1
    ##      0 0.98414986 0.84873950
    ##      1 0.01585014 0.15126050
    ## 
    ## , , history = 1
    ## 
    ##       recall
    ## cancer          0          1
    ##      0 0.97241379 0.86206897
    ##      1 0.02758621 0.13793103

``` r
xtabs(~cancer + recall + density, brca) %>% prop.table(margin=c(2, 3))
```

    ## , , density = density1
    ## 
    ##       recall
    ## cancer          0          1
    ##      0 1.00000000 0.75000000
    ##      1 0.00000000 0.25000000
    ## 
    ## , , density = density2
    ## 
    ##       recall
    ## cancer          0          1
    ##      0 0.98591549 0.85416667
    ##      1 0.01408451 0.14583333
    ## 
    ## , , density = density3
    ## 
    ##       recall
    ## cancer          0          1
    ##      0 0.98153034 0.87654321
    ##      1 0.01846966 0.12345679
    ## 
    ## , , density = density4
    ## 
    ##       recall
    ## cancer          0          1
    ##      0 0.95604396 0.73333333
    ##      1 0.04395604 0.26666667

In conclusion, the doctors could adjust how they are currently weighting
different risk factors to make more accurate evidence-based decisions
about recall and reduce unneccessary diagnostic tests as well as make
sure people who need diagnostic tests are getting them. Ultimately, this
should also lead to better outcomes for the patients because we will
catch the cancer sooner for the patients who have breast cancer.
