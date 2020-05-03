library(ggplot2)
library(tidyverse)
library(dplyr)
library(foreach)
library(mosaic)
library(LICORS)
library(factoextra)
library(reshape2)
library(data.table)
library(PCICt)
library(rjson)

latest_infection_data= read.csv("us-counties.csv.txt")

latest_infection_data$enddate= as.Date("2020/4/30")

infection_time = read.csv("infections_timeseries.csv.txt")
latest_infection_data$date = as.Date(latest_infection_data$date, format="%Y-%m-%d")
latest_infection_data$days_since_first_infection1 = difftime(latest_infection_data$enddate ,latest_infection_data$date , units = c("days"))

Firstdate = setDT(latest_infection_data)[order(date), head(.SD, 1L), by = county]
Firstdate= Firstdate %>%
  group_by(county) %>%
  arrange(date) %>%
  slice(1L)

Firstdate= Firstdate[,-c(5,6)]
inf = filter(latest_infection_data, date == "2020-04-30")
inf= inf[, -c(7,8)]

inf2 = left_join(inf, Firstdate, by = "county")
inf2= inf2[, -c(7:10)]

summary(latest_infection_data)

interventions = read.csv("interventions.csv.txt")

interventions$stayhome = as.Date(interventions$stay.at.home, origin=as.Date("0001-01-01"))
interventions$X.50.gatherings = as.Date(interventions$X.50.gatherings, origin=as.Date("0001-01-01"))
interventions$public.schools = as.Date(interventions$public.schools, origin=as.Date("0001-01-01"))
interventions$X.500.gatherings = as.Date(interventions$X.500.gatherings, origin=as.Date("0001-01-01"))
interventions$restaurant.dine.in = as.Date(interventions$restaurant.dine.in, origin=as.Date("0001-01-01"))
interventions$entertainment.gym = as.Date(interventions$entertainment.gym, origin=as.Date("0001-01-01"))

interventions$date = as.Date("2020/4/30")
interventions$stayhome = difftime(interventions$date ,interventions$stayhome, units = c("days"))
interventions$X.50.gatherings = difftime(interventions$date ,interventions$X.50.gatherings , units = c("days"))
interventions$public.schools = difftime(interventions$date ,interventions$public.schools, units = c("days"))
interventions$X.500.gatherings = difftime(interventions$date ,interventions$X.500.gatherings, units = c("days"))
interventions$restaurant.dine.in = difftime(interventions$date ,interventions$restaurant.dine.in, units = c("days"))
interventions$entertainment.gym = difftime(interventions$date ,interventions$entertainment.gym, units = c("days"))

interventions = interventions[, -c(4, 10,11,13)]

inf3 = left_join(inf2, interventions, by = c("fips.x" = "FIPS"))


ggplot(inf3[-1687,])+ geom_point(mapping = aes(days_since_first_infection1, cases))

counties_features = read.csv("counties.csv.txt")
data = read.csv("ACSDATA.csv")
data$totalhouseholds = data$E_Total_Households_TYPE_Family+data$E_Total_Households_TYPE_Nonfamily

data1= data[, c(11:27, 33:36, 101:116, 128)]/ data[,9]
data1 = data1[, -c(32:38)]
data2 = data[, c(28:31,67:78)]/ data[,134]
data2= data2[, -c(5:9)]

data3 = counties_features[,c(1:3, 27:30, 55:57,59:61,71:73,106:111)]
dat= data3[,c(4:8,10)]/100
data3= data3[,-c(4:8,10)]
data3= data.frame(cbind(data3,dat))
data4 = counties_features[,c(114:125)]/counties_features[,7]

#####One part of ACS data features
data5= data.frame(cbind(data3,data4))

###### other part of ACS data that contains data for only counties with corona cases
data6= data[,c(134,2,3,4,9,10,135)]
data6 = data.frame(cbind(data6,data1,data2))

##### Joining both datasets

data7= left_join(data5, data6, by = "FIPS")

######Bring it all together in one dataset
final = left_join(inf3, data7, by = c("fips.x" = "FIPS"))

###################################weather data

temp = read.csv("temp_seasonal_county.txt")

shit = filter(temp, is.na(summer_tmmx))
sum(is.na(temp$summer_tmmx))

temp= temp %>%
  group_by(fips)%>%
  summarise_all(mean)

final= left_join(final, temp, by = c("fips.x" = "fips"))

write.csv(final, "D:/Casual_inference/Research Project/Data/IPUMS microdata/ covid.csv", row.names = TRUE)

