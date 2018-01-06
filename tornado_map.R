#Developing Data Products Week 2 Project
#tornado_map.R
#by Lawrence Tomaziefski
#2017-01-01
#_______________________________________________________________________________
#Script Begins
#-------------------------------------------------------------------------------------
#Getting the Data

#Clear workspace of prior objects to free memory.
rm(list = ls())

#Set working directory
setwd('/Users/lawrence_tomaziefski/GitHub/Tornado_Map')
path ='/Users/lawrence_tomaziefski/GitHub/Tornado_Map/'

#Function to install and load libraries that are not already installed or loaded
#using very cool approach found here https://gist.github.com/stevenworthington/3178163
ipak <- function(pkg){
        new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
        if (length(new.pkg))
                install.packages(new.pkg, dependencies = TRUE)
        sapply(pkg, require, character.only = TRUE)
}
print(paste("started at :", Sys.time()))

print("loading libraries.")

#Create vector of libraries and pass into the above function.
libraries <- c("tibble","data.table","dtplyr","readr","acs",
               "lubridate","ggplot2","RColorBrewer","gridExtra",
               "devtools","ggthemes", "tidyr","knitr","R.utils","stringr",
               "reshape2","data.table","XLConnect","xlsx","maps","choroplethr",
               "choroplethrMaps","noncensus","dplyr","openxlsx","leaflet")
ipak(libraries)

#Check for data folder.  Create one if none exists
if (!file.exists("./data")) { dir.create("./data")}

#Get the  "NOAA data" from the course website:
url = "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"

#Create a sourcefile variable for reference when downloading and unzipping
sourceFile <- "./data/storm_data.zip"

#Check if file has already been downloaded.  If it does not exist, then download it.
if (!file.exists(sourceFile)) {
        download.file(url, destfile = "./data/storm_data.zip", method = "libcurl")
}
#There are storm data is provided in two formats, one is a .csv, and the other is a .bz2.  
#The .bz2 is basically a compressed .csv file and will load faster.  
bunzip2(sourceFile, "StormData.csv.bz2",remove = FALSE, skip = TRUE)

#Read the loaded data into a dataframe which will serve as the base for this analysis.  
storm_data = read.csv("StormData.csv.bz2",header = TRUE, stringsAsFactors = FALSE) 

#-------------------------------------------------------------------------------------
#Cleaning the Data
#-------------------------------------------------------------------------------------
#Although the NOAA storm data base contains records dating back to 1950, the NOAA did not begin recording 
#48 event tyes in accordance with NWS Directive 10-1065 issued in 1996.  Data from earlier than 1996, was collected
#on certain weather events (https://www.ncdc.noaa.gov/stormevents/details.jsp).  Over reporting of certain weather types will 
#skew the analysis.  In light of this, this analysis is focused the last five years of recorded weather events 
#in the data set.  This allows for a ten year period for the NWS Directive 10-1065 to be fully implemented and standardized across the United States,
#Additionally, this report will not take into account inflation, so the dollar amount will be closer to today's dollars.  

storm_data_sub = storm_data %>%
        select(37,1,2,7:8,21,23:24,25:28,32:33)  #Removes most of the administrative data
        
storm_data_date = colsplit(storm_data_sub$BGN_DATE," ",c("date","time")) #Extract the date from the BGN_DATE Column
storm_data_date = storm_data_date %>%
        mutate(date = mdy(date)) %>%
        select(date)

storm_data_sub = bind_cols(storm_data_sub, storm_data_date)

storm_data_sub_1996 = storm_data_sub %>%
        mutate(year = year(date)) %>%
        filter(year >= 1996) %>%
        mutate(lat = LATITUDE/100, lng = ((LONGITUDE/100)*-1),casualties = FATALITIES + INJURIES) %>%
        select(year,4:6,9:12,lat,lng,casualties)

#storm_data_sub_1996$property_damage_exp = as.factor(storm_data_sub_1996$property_damage_exp)
#storm_data_sub_1996$crop_damage_exp = as.factor(storm_data_sub_1996$crop_damage_exp)  

#Rename the column names to be more intuitive and user friendly. 
colnames(storm_data_sub_1996) = c("year","state","event_type","fscale","property_damage","property_damage_exp",
                                  "crop_damage","crop_damage_exp","lat","lng","casualties")

#Damage estimates.  The NOAA data set uses exponential multipliers for crop and property damage estimates.
#for the most part they are fairly self explanatory, but if more information is desired refer to the reference page
#at the following site https://rstudio-pubs-static.s3.amazonaws.com/58957_37b6723ee52b455990e149edde45e5b6.html.
#The total ecomonic cost by event was calculated by adding crop and property damage. 
 
property_damage_exps = unique(storm_data_sub$property_damage_exp)
prop_multiplier = data.frame(property_damage_exp= c("B","M", "K", 0,""), prop_multiplier = c(1000000000,1000000,1000,10,0))
storm_data_sub_1996 = left_join(storm_data_sub_1996,prop_multiplier, by = "property_damage_exp")
crop_multiplier = data.frame(crop_damage_exp= c("B","M", "K", 0,""), crop_multiplier = c(1000000000,1000000,1000,10,0))
storm_data_sub_1996 = left_join(storm_data_sub_1996, crop_multiplier, by = "crop_damage_exp")

#Filter the dataset to just the information corresponding to tornados and calculate the total economic cost fo the each tornado.
storm_data_tornado = storm_data_sub_1996 %>%
        mutate(property_damage = property_damage * prop_multiplier) %>%
        mutate(crop_damage = crop_damage * crop_multiplier) %>%
        mutate(total_economic_cost = signif((crop_damage + property_damage)/1000000),3) %>%
        filter(event_type %in% "TORNADO") %>%
        filter(lat > 0) %>%
        select(1:4,14,9:11)


#-------------------------------------------------------------------------------------
#Building the leaflet interactive map
#-------------------------------------------------------------------------------------
#Create the labels for the markers.  When the user clicks on the marker the label will tell them what year the tornado occured and the ecomonic damage the tornado 
#caused.  
storm_data_tornado = storm_data_tornado %>%
        mutate(label = paste(storm_data_tornado$year,", $",storm_data_tornado$total_economic_cost,"M,",storm_data_tornado$casualties,"Casualties"))

#Add marker colors to correspond to the tornado F-Scale Categories
colors = data.frame(fscale = c(0:5),col = c("red","orange","yellow","blue","green","grey"))
storm_data_tornado = left_join(storm_data_tornado, colors, by = "fscale")
storm_data_tornado$fscale = as.factor(storm_data_tornado$fscale)
storm_data_tornado$col = as.character(storm_data_tornado$col)

#Create the markers with icons
icons = awesomeIcons(
        icon = 'ion-android-funnel',
        iconColor = 'black',
        library = 'ion',
        markerColor = storm_data_tornado$col)

#Create the leaflet map that clusters and categorizes.  
storm_data_tornado %>% 
        leaflet() %>%
        addTiles() %>%
        addAwesomeMarkers(clusterOptions= markerClusterOptions(),label = storm_data_tornado$label, icon = icons) %>%
        addLegend(labels = c("F0","F1","F2","F3","F4","F5"), colors = colors$col)



        
