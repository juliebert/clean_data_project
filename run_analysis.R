#run_analysis.R
#This script loads the data from distinct files in the UCI HAR Dataset and combines it 
#into a single tidy data table

#First make sure we've installed/loaded the data.table package
#install.packages("data.table")
library(data.table)

#############################################################################################
# Load the training signals
#############################################################################################
X_train = read.table("UCI HAR Dataset/train/X_train.txt", 
               sep="", 
               fill=FALSE, 
               strip.white=TRUE)
Y_train = read.table("UCI HAR Dataset/train/y_train.txt", 
                          sep="", 
                          fill=FALSE, 
                          strip.white=TRUE)
subject_train = read.table("UCI HAR Dataset/train/subject_train.txt", 
                          sep="", 
                          fill=FALSE, 
                          strip.white=TRUE)

#############################################################################################
# Load the test signals
#############################################################################################
X_test = read.table("UCI HAR Dataset/test/X_test.txt", 
                           sep="", 
                           fill=FALSE, 
                           strip.white=TRUE)
Y_test = read.table("UCI HAR Dataset/test/y_test.txt", 
                           sep="", 
                           fill=FALSE, 
                           strip.white=TRUE)
subject_test = read.table("UCI HAR Dataset/test/subject_test.txt", 
                           sep="", 
                           fill=FALSE, 
                           strip.white=TRUE)

#############################################################################################
# Load the descriptions
#############################################################################################

features = read.table("UCI HAR Dataset/features.txt", 
                      sep="", 
                      fill=FALSE, 
                      strip.white=TRUE,col.names=c('code','feature'))

activity = read.table("UCI HAR Dataset/activity_labels.txt", 
                      sep="", 
                      fill=FALSE, 
                      strip.white=TRUE,col.names=c('code','activity'))

#############################################################################################
# Step 1: Concatenate the test and training data sets into single data table
#############################################################################################

X = rbindlist(list(as.list(X_train), as.list(X_test)))
#set the column names to the descriptions in the feature data table
#this is doing Step 4 early, but I think it makes it easier
setnames(X,as.character(features$feature))

Y = rbindlist(list(as.list(Y_train), as.list(Y_test)))
#set the column name to code, this will match with the code colum in the activity data table
#for merging these two data tables later on
setnames(Y,'code')

subject = rbindlist(list(as.list(subject_train), as.list(subject_test)))
setnames(subject,'subject_number')

# Combine the three separate data tables into a singel data table
# This completes step 1 of the assignment
master = cbind(subject,Y,X)

############################################################################################
#Step 2: Extract only the measurements on the mean and standard deviation for each measurement. 
############################################################################################

#search for column names that contain the string 'mean' or 'std'
keys = c(grep('mean',names(master)),grep('std',names(master)))
s_keys = sort(keys)
#add colums 1 & 2 back in because they are the subject and activity IDs
s_keys = c(c(1,2),s_keys)

#create a new data frame made up only of the mean and std measurements
#This completes step 2 of the assignment
reduced_master = master[,s_keys,with = FALSE]

###########################################################################################
# Step 3: Add descriptive activity names to name the activities in the data set
###########################################################################################

named_master = merge(reduced_master,activity,by='code')
#move the new activity column to be in col 2 instead of at the end
first_cols = c(names(named_master)[2],tail(names(named_master),n=1),names(named_master)[1])
setcolorder(named_master, c(first_cols, setdiff(names(named_master), first_cols)))
# This completes step 3 of the assignment

##########################################################################################
# Step 4: Appropriately labels the data set with descriptive variable names. 
##########################################################################################

#This has already been done the column names are all descriptive

##########################################################################################
# Step 5: From the data set in step 4, creates a second, independent tidy data set with 
#         the average of each variable for each activity and each subject.
#########################################################################################

#remove the activity column so we can take averages across all rows
num_master = named_master[,activity:=NULL]
avg_master = num_master[0]
#loop over all the subjects
for (n in unique(named_master$subject_number)){
    setkey(num_master,"subject_number")
    temp = num_master[.(c(n))]
    #loop over all the activites
    for (m in c(unique(activity$code))){
        setkey(temp,"code")
        temp2 = temp[.(c(m))]
        #take the average of each column for each subject and activity
        out = lapply(temp2,mean)
        #append averages to the avg_master data table
        avg_master = rbindlist(list(as.list(avg_master), as.list(out)))
    }
}

neat_master = merge(avg_master,activity,by='code')
#remove the "code" column since it is logically replaced by named activities
neat_master[,code:=NULL]
#move the new activity column to be in col 2 instead of at the end
first_cols = c(names(neat_master)[1],tail(names(neat_master),n=1))
setcolorder(neat_master, c(first_cols, setdiff(names(neat_master), first_cols)))

#write the new tidy data set to a txt file
write.table(neat_master,file="my_tidy_data.txt",row.names = FALSE)



