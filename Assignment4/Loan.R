library(mosaic)
library(tidyverse)
library(Metrics)
library(gamlr)
library(margins)
library(rpart)
library(caret)
library(randomForest)
library(gbm)
library(dummies)

loan <- read.csv('loanadj.csv')
summary(loan)

###### Creating objective variable Good crdeit =1 if loan status either current of fully paid
loan$goodcredit=ifelse(loan$loan_status == "Current" | loan$loan_status == "Fully Paid", 1, 0)

###### Creating dummy variables for home ownership (rent,own and mortgage)
loan <- cbind(loan, dummy(loan$home_ownership))
colnames(loan)[colnames(loan)=="loanOWN"] <- "home_own"
colnames(loan)[colnames(loan)=="loanRENT"] <- "home_rent"
colnames(loan)[colnames(loan)=="loanMORTGAGE"] <- "home_mort"                 

#### creating a unique variable for FICO rating 
loan$fico=(loan$fico_range_high+loan$fico_range_low)/2

#### Creating a variable for debt consolidation
loan$debt_consolidation=ifelse(loan$purpose == "debt_consolidation", 1, 0)

#### Creating a variable for individual application
loan$indv_app=ifelse(loan$application_type == "Individual", 1, 0)

#### Creating a variable for term, 1 if term is 60 mo 0 if 36 mo
loan$loterm=ifelse(loan$term == "60 months", 1, 0)

### Creating a variable for income verification
loan$incver=loan$goodcredit=ifelse(loan$verification_status == "Verified" |
                                      loan$verification_status == "Source Verified", 1, 0)
tabulate(loan$incver)
names(loan)

m1  = glm(goodcredit ~ (debt_consolidation+fico+loan_amnt+annual_inc+home_own
                        +home_mort+dti+indv_app+avg_cur_bal+term),data=loan,family = binomial)
summary(m1)


date<-as.Date(loan$issue_d,format="%%M-%%y")

loan$issue_d <- as.Date(loan$issue_d, "%m/%d/%Y")
