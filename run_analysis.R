#load dplyr
library(dplyr)

#download data in working directory as allData.zip
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, "allData.zip", method="curl")

#unzip data
unzip("allData.zip")

#check files and directories
list.files()
#[1] "allData.zip"           "run_analysis.R"        "UCI HAR Dataset"     
#[4] "UCI HAR Dataset.names"

#check files in "UCI HAR Dataset"
list.files("UCI HAR Dataset")
#[1] "activity_labels.txt" "features.txt"        "features_info.txt"  
#[4] "README.txt"          "test"                "train"

#More files
list.files("UCI HAR Dataset/test")
#[1] "Inertial Signals" "subject_test.txt" "X_test.txt"       "y_test.txt" 
list.files("UCI HAR Dataset/train")
#"Inertial Signals"  "subject_train.txt" "X_train.txt"       "y_train.txt"

# Assigning file contents to dataframes

features <- read.table("UCI HAR Dataset/features.txt", col.names = c("n","functions"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")

#Requirement 1: merge data with subsequent rbind into one large dataframe
X <- rbind(x_train, x_test)
Y <- rbind(y_train, y_test)
subject <- rbind(subject_train, subject_test)
merged_data <- cbind(Subject, Y, X)

#preview data with head()
#head(merged_data)

#Requirement 2 Extract measurements on the mean and standard deviation for each measurement
meanStdData <- merged_data %>% select(subject, code, contains("mean"), contains("std"))
#head(meanStdData)

#Requirement 3 Uses descriptive activity names from activities dataframe to name the activities in the data set
meanStdData$code <- activities[meanStdData$code, 2]
head(meanStdData)

#Requirement 4: Appropriately labeling data set with descriptive variable names.
names(meanStdData)[2] = "activity"
names(meanStdData)<-gsub("Acc", "Accelerometer", names(meanStdData))
names(meanStdData)<-gsub("Gyro", "Gyroscope", names(meanStdData))
names(meanStdData)<-gsub("BodyBody", "Body", names(meanStdData))
names(meanStdData)<-gsub("Mag", "Magnitude", names(meanStdData))
names(meanStdData)<-gsub("^t", "Time", names(meanStdData))
names(meanStdData)<-gsub("^f", "Frequency", names(meanStdData))
names(meanStdData)<-gsub("tBody", "TimeBody", names(meanStdData))
names(meanStdData)<-gsub("-mean()", "Mean", names(meanStdData), ignore.case = TRUE)
names(meanStdData)<-gsub("-std()", "STD", names(meanStdData), ignore.case = TRUE)
names(meanStdData)<-gsub("-freq()", "Frequency", names(meanStdData), ignore.case = TRUE)
names(meanStdData)<-gsub("angle", "Angle", names(meanStdData))
names(meanStdData)<-gsub("gravity", "Gravity", names(meanStdData))

#head(meanStdData)

#Requirement 5: Create and save to working directory a tidy data set with the average of each variable for each activity and each subject
FinalData <- meanStdData %>%
    group_by(subject, activity) %>%
    summarise_all(funs(mean))
#actual save
write.table(FinalData, "FinalData.txt", row.name=FALSE)
