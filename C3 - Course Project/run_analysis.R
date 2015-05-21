###############################################################################
## Install and load required libraries
###############################################################################
if (!("vd" %in% rownames(installed.packages())))
{   
    # for join_all
    install.packages("plyr")
    library(plyr)
}

if (!("dplyr" %in% rownames(installed.packages())))
{
    # for summarise_each and group_by
    install.packages("dplyr")
    library(dplyr)
}

###############################################################################
## Merges the training and the test sets to create one data set
###############################################################################
## load test data
test_set <- read.table("./UCI HAR Dataset/test/X_test.txt")

## load training data
train_set <- read.table("./UCI HAR Dataset/train/X_train.txt")

## merge test data
data_set <- rbind(test_set, train_set)

###############################################################################
## Extracts only the measurements on the mean and standard deviation for each measurement
###############################################################################
## load variables labels
labels <- read.table("./UCI HAR Dataset/features.txt")

# find labels to keep or to remove from data set 
unselected_labels <- labels[!(grepl("mean", labels$V2) | grepl("std", labels$V2)),]
selected_labels <- labels[(grepl("mean", labels$V2) | grepl("std", labels$V2)),]

#remove unselected labels from data set
data_set <- data_set[-c(t(unselected_labels[1]))]

###############################################################################
## Uses descriptive activity names to name the activities in the data set
###############################################################################

activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")
test_labels <- read.table("./UCI HAR Dataset/test/y_test.txt")
train_labels <- read.table("./UCI HAR Dataset/train/y_train.txt")

## merge activity data from test set and training set
activity_set <- rbind(test_labels, train_labels)

## join the merge activity data with activitly labels in order to only get activity names
activity_set <- join_all(list(activity_set,activity_labels))[2]
names(activity_set) = "Activity"

###############################################################################
## Appropriately labels the data set with descriptive variable names
###############################################################################
names(data_set) = as.character(t(selected_labels$V2))

###############################################################################
## Finally merges User, Activity and all data sets
###############################################################################
test_subjects <- read.table("./UCI HAR Dataset/test/subject_test.txt")
train_subjects <- read.table("./UCI HAR Dataset/train/subject_train.txt")
subjects_set <- rbind(test_subjects, train_subjects)
names(subjects_set) = "User"

data_set <- cbind(subjects_set, activity_set, data_set)


###############################################################################
## creates a second, independent tidy data set with the average of each variable 
## for each activity and each subject
###############################################################################
tidy_data_set <- data_set %>% group_by(User, Activity) %>% summarise_each(funs(mean))
write.table(tidy_data_set, "./tidy_data_set.txt")