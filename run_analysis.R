

# importing the relevant libraries
library(dplyr)
library(tidyverse)

#importing the relevant datasets into appropriately named variables
xtrain <- data.table::fread("X_train.txt")
ytrain <- data.table::fread("y_train.txt")
xtest <- data.table::fread("X_test.txt")
ytest <- data.table::fread("y_test.txt")
subjecttest <- data.table::fread("subject_test.txt")
subjecttrain <- data.table::fread("subject_train.txt")

# converting them into tbl_df format for ease of manipulation using dplyr package
xtrain1 <- tbl_df(xtrain)
ytrain1 <- tbl_df(ytrain)
xtest1 <- tbl_df(xtest)
ytest1 <- tbl_df(ytest)
subjecttest1 <- tbl_df(subjecttest)
subjecttrain1 <- tbl_df(subjecttrain)

#getting the feature list
feature <- data.table::fread("features.txt")
feature <- tbl_df(feature)

#getting them in the form of tags, and applying them as names to the testing and training data
tags <- feature$V2
names(xtest1) <- tags
## Here, recording the activities to walking, lying, standing etc. and adding activity to tbl_df
ytest2 <- recode(ytest1$V1, "1" = "walking", "2" = "walking_upstairs", "3" = "walking_downstairs", "4" = "sitting", "5" = "standing", "6" = "laying" )
xtest1$activity <- ytest2
## Here, adding the subject list to the tbl_df
xtest1$subjects <- subjecttest1$V1
names(xtrain1) <- tags
##Again, attaching labels and adding activity to tbl_df
ytrain2 <- recode(ytrain1$V1, "1" = "walking", "2" = "walking_upstairs", "3" = "walking_downstairs", "4" = "sitting", "5" = "standing", "6" = "laying" )
xtrain1$activity <- ytrain2
##Adding subject list
xtrain1$subjects <- subjecttrain1$V1


#making a note of the type of data
xtrain1$typedata <- "train"
xtest1$typedata <- "test"

#creating the combined datasetrequired
bigdata <- rbind(xtest1,xtrain1)

#removing the duplicate columns present
bigdata <- bigdata[!duplicated(names(bigdata))]

#removing special characters from the column names
library(janitor) #package to clean column names
bigdata <- clean_names(bigdata) #reassign data set with special characters in column names replaced by _


# extracting the required columns from the dataset
## grouping by subjects
gbigdata <- bigdata
## first, extract the mean data and add the activity and typedata columns
gbigdata1 <- select(gbigdata, matches("mean"))
gbigdata1$activity <- gbigdata$activity
gbigdata1$typedata <- gbigdata$typedata
gbigdata1$subjects <- gbigdata$subjects
## extract the standard deviation columns, combine the two datasets and convert to tbl_df
gbigdata2 <- select(gbigdata, matches("std()"))
gfbigdata <- cbind(gbigdata1, gbigdata2)
gfbigdata <- tbl_df(gfbigdata)
##removing all the duplicated names
gfbigdata <- gfbigdata[!duplicated(names(gfbigdata))]
#the gfbigdata variable (SEPARATE FROM gbigdata and variants) is the tidy data set of the mean and standard deviation
# columns required. It has the required columns, added with column for type of 
#activity, the subject and the data set it was originally taken from (test or train)

#importing reshape library for last part of the assignment
library(reshape)
library(reshape2)
# converting tbl_df to data frame as previous format caused problems.
expdata <- as.data.frame(gfbigdata)
edata <- melt(expdata, id=c("activity","subjects","typedata"))

finaldataset <- cast(edata, subjects + activity~variable,mean)
finaldataset <- tbl_df(finaldataset)
finaldataset

#finaldataset is what is required at the end of all the steps.

#I hope my code is readable enough.
#peace.
