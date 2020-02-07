library(tidyverse)
library(FNN)
library(mosaic)
library(rmarkdown)
library(ggplot2)

# read in the data: make sure to use the path name to
# wherever you'd stored the file
abia = read.csv('ABIA.csv')
summary(abia)
head(abia)

abia2 <- na.omit(abia)



####### AVERAGE DEPARTURE DELAY PER CARRIER (Departing From Austin ) #########
naustin = subset(abia, Origin=="AUS")
naustin$DepDelay = ifelse(naustin$DepDelay < 0, 0, naustin$DepDelay)
naustin$CRSDTime= substr(naustin$CRSDepTime, 1, nchar(naustin$CRSDepTime)-2)


carrier_sum = naustin %>%
      group_by(UniqueCarrier)  %>%  # group the data points by model nae
   summarize(DD.mean=mean(DepDelay ,na.rm=TRUE)) 

ggplot(carrier_sum, aes(x=reorder(UniqueCarrier,DD.mean), y=DD.mean)) + 
   geom_bar(stat='identity') + 
   coord_flip()+
   labs(title="Average Departure Delay per Carrier", 
        caption="Source: ABIA",
        x="Carrier",
        y = "Delay in minutes")
 
 ######AVG Delay per Scheduled Time of Departure(Departing from Austin)##############
 
CRSDepTime_sum = naustin %>%
   group_by(CRSDTime)  %>%  # group the data points by model nae
   summarize(CRSDD.mean=mean(DepDelay,na.rm=TRUE)) 
 windows()
 ggplot(CRSDepTime_sum, aes(x=CRSDTime, y=CRSDD.mean)) + 
   geom_bar(stat='identity') +
   labs(title="AVG Delay per Scheduled Time of Departure", 
        caption="Source: ABIA",
        x="Scheduled Time (Hour of the Day",
        y = "Delay in minutes")
 
 
 DestinationDelay = naustin %>%
   group_by(Dest) %>%
   summarize(DDM= mean(DepDelay, na.rm = TRUE))
 ggplot(DestinationDelay , aes (x= reorder(Dest,DDM), y= DDM))+
   geom_bar(stat = 'identity')+
   coord_flip()+
   labs(title = "AVG Delay per Destination of Flight",
        caption = "Source : ABIA",
        x = "Destination",
        y= "Delay in minutes")
 
 count(nrow(naustin$CRSDTime == "17"))
 
summary(naustin)

  
 ##       ylim(0, 200) + xlim(0,2400)
 
 
 ###########Cancellation Rate####################33333
 
 carrier_canc = abia%>%
    group_by(UniqueCarrier) %>%
    summarize(canc_rate = sum(Cancelled=='1')/n())#total survey#
 
 ggplot(carrier_canc, aes(x=reorder(UniqueCarrier,canc_rate), y=canc_rate)) + 
   geom_bar(stat='identity') + 
   coord_flip()+
   labs(title="Cancellation Rate per Carrier", 
        caption="Source: ABIA",
        x="Carrier",
        y = "Cancellation rate")
 
 ############## AVG Departure Delay per Month (DEPARTING OR ARRIVING From Austin ) #####################
 
Month_sum = naustin %>%
   group_by(Month)  %>%  # group the data points by model nae
   summarize(DD.mean=mean(DepDelay,na.rm=TRUE)) 
 
 windows()
 ggplot(Month_sum, aes(x=Month, y=DD.mean)) + 
   geom_bar(stat='identity') + 
   coord_flip()+
   labs(title="Average Departure Delay per Month", 
        caption="Source: ABIA",
        x="Month",
        y = "Delay in minutes")
        library(mosaic)

Cancel_data = naustin %>%
  group_by(Month) %>%
  summarize(cancellation.rate = mean(Cancelled))

windows()
ggplot(Cancel_data, aes(x=Month, y=cancellation.rate)) + 
  geom_bar(stat='identity') +
  coord_flip()+
  labs(title="Cancellation Rate vs Month of the Year",
       caption = "Source: ABIA" ,
       y="Cancellation Rate" ,
       x="Month")

Month_Abbreviation <- factor(Month_Abbreviation, levels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"))

Month_data = abia %>%
  group_by(Month_Abbreviation) %>%
  summarize(cancellation.rate = mean(Cancelled))

ggplot(Month_data, aes(x=factor(Month_Abbreviation, levels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")), y=cancellation.rate)) + 
  geom_bar(stat='identity') +
  coord_flip()+
  labs(title="Cancellation Rate vs Month",
       caption = "Source: ABIA" ,
       y="Cancellation Rate" ,
       x="Month")
  
Time_data = naustin %>%
  group_by(CRSDTime) %>%
  summarize(cancellation.rate = mean(Cancelled))

windows()
ggplot(Time_data, aes(x=CRSDTime, y=cancellation.rate)) + 
  geom_bar(stat='identity') +
  coord_flip()+ 
  labs(title="Cancellation Rate vs Time of Day",
       caption = "Source: ABIA" ,
       y="Cancellation Rate" ,
       x="Military Time")
 
 
xlim(5, 24) + ylim(0,.25) 
 ########## MAPS #########
 
 airportcodes = read.csv('C:/Users/clark/OneDrive/UTEXAS/Spring20/Data Mining/airportcodes.csv')
 summary(airportcodes)
 head(airportcodes)
 
 
 #############  
 
 
 
 
 
 
 