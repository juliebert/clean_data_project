# clean_data_project
This repo contains an r script, run_analysis.R
This script loads data from the UCI HAR Dataset and manipulates that data.

1. read _X_train.txt_, _y_train.txt_, _subject_train.txt_, _X_test.txt_, _y_test.txt_, _subject_test.txt_, _features.txt_ and _activity_labels.txt_ data files and load them into tables
2. Concatentates the test and training datasets for X, y and subject in to a single table
3. Names the columns of the concatenated data table.
  * Columns from X datasets are names with the features dataset
  * Column from y datasets is named **code** (will correspod with an activity from the activity_labels dataset)
  * Column from subject data set is named **subject_number**
4. Creates a new data table that only includes X coulums that measure the **mean** or the **std**
5. Adds a coulmn to the data table with text descriptions of the activeties.
6. Creates a new tidy data table that only includes the average of the **mean** and **std** measurements form the previous step averaged for each subject and activity
7. Saves the tidy data set created in step 6 to "my_tidy_data.txt"
