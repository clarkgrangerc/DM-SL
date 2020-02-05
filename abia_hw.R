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

# creating a ggplot
# The first line sets up a coordinate system.
# the second line maps displ to x, hwy to y, and draws points
ggplot(data = abia) + 
  geom_point(mapping = aes(x = Dest, y = DepDelay))


# facets
ggplot(data = abia) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_wrap(~ UniqueCarrier, nrow = 2)

####### AVERAGE DEPARTURE DELAY PER CARRIER (Departing From Austin ) #########
naustin = subset(abia, Origin=="AUS")

 carrier_sum = naustin %>%
      group_by(UniqueCarrier)  %>%  # group the data points by model nae
   summarize(DD.mean=mean(DepDelay[which(DepDelay > 0)],na.rm=TRUE)) 
 
windows()
 ggplot(carrier_sum, aes(x=reorder(UniqueCarrier,DD.mean), y=DD.mean)) + 
   geom_bar(stat='identity') + 
   coord_flip()+
   labs(title="Average Departure Delay per Carrier", 
        caption="Source: ABIA",
        x="Carrier",
        y = "Delay in minutes")
 
 ######AVG Delay per Scheduled Time of Departure(Departing from Austin)##############
 
CRSDepTime_sum = naustin %>%
   group_by(CRSDepTime)  %>%  # group the data points by model nae
   summarize(CRSDD.mean=mean(DepDelay[which(DepDelay > 0)],na.rm=TRUE)) 
 windows()
 ggplot(CRSDepTime_sum, aes(x=CRSDepTime, y=CRSDD.mean)) + 
   geom_bar(stat='identity') + 
   coord_flip() +
   labs(title="AVG Delay per Scheduled Time of Departure", 
        caption="Source: ABIA",
        x="Scheduled Time",
        y = "Delay in minutes") 
 
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
 
Month_sum = abia %>%
   group_by(Month)  %>%  # group the data points by model nae
   summarize(DD.mean=mean(DepDelay[which(DepDelay > 0)],na.rm=TRUE)) 
 
 windows()
 ggplot(Month_sum, aes(x=Month, y=DD.mean)) + 
   geom_bar(stat='identity') + 
   coord_flip()+
   labs(title="Average Departure Delay per Month", 
        caption="Source: ABIA",
        x="Month",
        y = "Delay in minutes")
        library(mosaic)

Cancel_data = ABIA %>%
  group_by(UniqueCarrier) %>%
  summarize(cancellation.rate = mean(Cancelled))

ggplot(Cancel_data, aes(x=UniqueCarrier, y=cancellation.rate)) + 
  geom_bar(stat='identity') +
  coord_flip()+
  labs(title="Cancellation Rate vs Airline Carrier",
       caption = "Source: ABIA" ,
       y="Cancellation Rate" ,
       x="Airline")

Month_Abbreviation <- factor(Month_Abbreviation, levels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"))

Month_data = ABIA %>%
  group_by(Month_Abbreviation) %>%
  summarize(cancellation.rate = mean(Cancelled))

ggplot(Month_data, aes(x=factor(Month_Abbreviation, levels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")), y=cancellation.rate)) + 
  geom_bar(stat='identity') +
  coord_flip()+
  labs(title="Cancellation Rate vs Month",
       caption = "Source: ABIA" ,
       y="Cancellation Rate" ,
       x="Month")
  
Time_data = ABIA %>%
  group_by(CRSDepTime) %>%
  summarize(cancellation.rate = mean(Cancelled))

ggplot(Time_data, aes(x=CRSDepTime, y=cancellation.rate)) + 
  geom_bar(stat='identity') +
  coord_flip()+ 
  xlim(500, 2400) + ylim(0,.25)+
  labs(title="Cancellation Rate vs Time of Day",
       caption = "Source: ABIA" ,
       y="Cancellation Rate" ,
       x="Military Time")
 
 
 
 ########## MAPS #########
 
 airportcodes = read.csv('C:/Users/clark/OneDrive/UTEXAS/Spring20/Data Mining/airportcodes.csv')
 summary(airportcodes)
 head(airportcodes)
 
 
 #############  
 
 
 
 
 
 
 