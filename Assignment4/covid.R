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

d= filter(latest_infection_data, county == 'Douglas')  

latest_infection_data$enddate= as.Date("2020/4/30")

infection_time = read.csv("infections_timeseries.csv.txt")
latest_infection_data$date = as.Date(latest_infection_data$date, format="%Y-%m-%d")
latest_infection_data$days_since_first_infection1 = difftime(latest_infection_data$enddate ,latest_infection_data$date , units = c("days"))

Firstdate = setDT(latest_infection_data)[order(date), head(.SD, 1L), by = county]
Firstdate1= latest_infection_data %>%
  group_by(county, state) %>%
  arrange(date) %>%
  slice(1L)

Firstdate= Firstdate1[,-c(5,6)]
inf = filter(latest_infection_data, date == "2020-04-30")
inf= inf[, -c(7,8)]

inf2 = left_join(inf, Firstdate, by = "fips")
inf2= inf2[, -c(7:10)]

newyork = read.csv("04-30-2020.csv.txt")
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
hosptilization = read.csv("Hospitalization_all_locs.csv.txt")

ny = read.csv("04-30-2020.csv.txt")

newyork = filter(data7, FIPS %in% c(36005,36047,36061,36081,36085))
newyork2 = filter(counties_features, FIPS %in% c(36005,36047,36061,36081,36085))
newyork3 = filter(temp,fips %in% c(36005,36047,36061,36081,36085) )

####################### Time series plot 

timeseries = filter(infection_time, FIPS %in% c(53061,17031,6059,4013,6037,6085,25025,6075,55025,6073))


timeseries1 = as.data.frame(t(timeseries))
timeseries1 = timeseries1[-c(1,2),]
timeseries1 = timeseries1[-1,]
colnames(timeseries1) <- as.character(unlist(timeseries1[1,]))
names(timeseries1)[-1] <- sub("- US", "", names(timeseries1)[-1], fixed = TRUE)
timeseries1 = timeseries1[-1,]
setDT(timeseries1, keep.rownames = TRUE)[]
timeseries1$rn = gsub("X", "0", timeseries1$rn)

timeseries1$rn= as.Date(timeseries1$rn, format="%m.%d.%y")
timeseries1$rn= difftime(timeseries1$rn,as.Date("2020/01/22"), units = c("days"))
timeseries1$rn = as.numeric(timeseries1$rn)
ab = timeseries1

pop = read.csv("covid.csv")
pop = filter(pop, fips.x %in% c(53061,17031,6059,4013,6037,6085,25025,6075,55025,6073))
pop= pop[,c(5,43)]

library(directlabels)
library(magrittr)
library(ggrepel)
ab[,c(2:11)] %<>% lapply(function(x) as.numeric(as.character(x)))


ab$rn= factor(ab$rn)
summary(timeseries1)

timeseries = melt(ab, id="rn")
timeseries$rn = as.numeric(timeseries$rn)


ggplot(timeseries, mapping = aes(x = rn, y = value,color = factor(variable)), size = 1)+geom_line()+
  theme(legend.position = "none")+
  geom_text_repel(data = subset(timeseries, rn == max(rn)),aes(label= variable),nudge_x = 5, segment.color = NA)+
  coord_cartesian(xlim = c(50, 100 + 10))
  
######## Per 100,000 cases graphj
time = read.csv("graph.csv")
names(time)[-1] <- sub("- US", "", names(time)[-1], fixed = TRUE)

setDT(timeseries1, keep.rownames = TRUE)[]
time$Combined_Key = gsub("X", "0", time$Combined_Key)
time$Combined_Key= as.Date(time$Combined_Key , format="%m.%d.%y")
time$Combined_Key = difftime(time$Combined_Key ,as.Date("2020/01/22"), units = c("days"))
time$Combined_Key = as.numeric(as.character(time$Combined_Key))

time1 = melt(time, id="Combined_Key")

ggplot(time1, mapping = aes(x = Combined_Key, y = value))+geom_line(aes(color = variable), size = 0.8) +
  theme(legend.position = "none")+xlim(0, 120)+geom_text_repel(data = subset(time1, Combined_Key == max(Combined_Key)),aes(label= variable),nudge_x = 30,segment.color = NA) #+
  coord_cartesian(xlim = c(70, 100 + 10))

############################ US MAp
library(usmap)  
covid2 = read.csv("covid.csv")
names(covid2)[names(covid2) == "fips.x"] <- "fips"
countypop = counties_features[, c(1,7)]
covid2 = left_join(covid2, countypop, by= c("fips"="FIPS"))
covid2$cases_per_100thous = covid2$cases/(covid2$POP_ESTIMATE_2018/100000) 

plot_usmap(regions = "counties", data = covid2, values = 'cases_per_100thous', color = 'gray')+ 
  scale_fill_continuous(low = "white", high= 'red', name = "Cases per 100K Pop", label = scales::comma)+
  labs(title = 'US Counties Covid Cases') 


############################# Histogram

ggplot(data = covid2, mapping = aes(cases_per_100thous))+geom_density()

##### geom_dl(aes(label = variable), method = list(dl.trans(x = x+0.5), "last.points", cex = 0.8))  
write.csv(timeseries, "D:/Casual_inference/Research Project/Data/IPUMS microdata/ caseslineolot.csv", row.names = TRUE)


