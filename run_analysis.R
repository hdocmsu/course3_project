# R code to clean the data
# Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. 
# A Public Domain Dataset for Human Activity Recognition Using Smartphones. 
# 21th European Symposium on Artificial Neural Networks, Computational Intelligence and Machine Learning, 
# ESANN 2013. Bruges, Belgium 24-26 April 2013.

data_dir <- "UCI_HAR_Dataset/"
fn_labels <- "UCI_HAR_Dataset/activity_labels.txt"
fn_features <- "UCI_HAR_Dataset/features.txt"

fn_train_X <- "UCI_HAR_Dataset/train/X_train.txt"
fn_train_y <- "UCI_HAR_Dataset/train/y_train.txt"

fn_test_X <- "UCI_HAR_Dataset/test/X_test.txt"
fn_test_y <- "UCI_HAR_Dataset/test/y_test.txt"

fn_combo_X <- "UCI_HAR_Dataset/combo/X_combo.txt"
fn_combo_y <- "UCI_HAR_Dataset/combo/y_combo.txt"

fn_combo_short_X <- "UCI_HAR_Dataset/combo/X_combo_short.txt"
fn_combo_short_y <- "UCI_HAR_Dataset/combo/y_combo_short.txt"

fn_train_subject <- "UCI_HAR_Dataset/train/subject_train.txt"
fn_test_subject <- "UCI_HAR_Dataset/test/subject_test.txt"
fn_combo_subject <- "UCI_HAR_Dataset/combo/subject_combo.txt"

# create combo folder
if (!dir.exists(file.path("UCI_HAR_Dataset/", "combo/"))){
  dir.create(file.path("UCI_HAR_Dataset/", "combo/"))
}

# Read the txt file into a data.frame
read_txt <- function(x) {
  read.table(file = x, header = FALSE)
  }
# write a data.frame to txt file
write_txt <- function(data, fname){
  write.table(data, fname, append = FALSE, sep = " ", dec = ".",
              row.names = FALSE, col.names = FALSE)
}

# combine two data.frames
combine_dfs <- function(df1, df2){
  rbind(df1, df2)
}

# merge train and test to create combo data
X_train_df <- read_txt(fn_train_X)
y_train_df <- read_txt(fn_train_y)

X_test_df <- read_txt(fn_test_X)
y_test_df <- read_txt(fn_test_y)

X_combo_df <- combine_dfs(X_train_df, X_test_df)
y_combo_df <- combine_dfs(y_train_df, y_test_df)

write_txt(X_combo_df, fn_combo_X)
write_txt(y_combo_df, fn_combo_y)

subject_train_df <- read_txt(fn_train_subject)
subject_test_df <- read_txt(fn_test_subject)
subject_combo_df <- combine_dfs(subject_train_df, subject_test_df)
write_txt(subject_combo_df, fn_combo_subject)

# replace generic column names (V1, V2,...) by feature names
features <- read_txt(fn_features)
head(features) # V2 contains feature names
feature_names <- features$V2
names(X_test_df) <- feature_names 
names(y_test_df) <- "label"

names(X_train_df) <- feature_names
names(y_train_df) <- "label"

names(X_combo_df) <- feature_names
names(y_combo_df) <- "label"

# extract only mean and std features
mean_idx <- grep("mean", feature_names)
std_idx <- grep("std", feature_names)
mean_std_idx <- c(mean_idx, std_idx)

X_combo_df_short <- X_combo_df[,mean_std_idx]
y_combo_df_short <- y_combo_df

write_txt(X_combo_df_short, fn_combo_short_X)
write_txt(y_combo_df_short, fn_combo_short_y)

# create tidy data set with the average of each variable for each activity 
# and each subject
# create combo2 folder
if (!dir.exists(file.path("UCI_HAR_Dataset/", "combo2/"))){
  dir.create(file.path("UCI_HAR_Dataset/", "combo2/"))
}
fn_combo2_X <- "UCI_HAR_Dataset/combo2/X_combo2.txt"
fn_combo2_y <- "UCI_HAR_Dataset/combo2/y_combo2.txt"
fn_combo2_subject <- "UCI_HAR_Dataset/combo2/subject_combo2.txt"


Xy_combo2_df <- X_combo_df
Xy_combo2_df$label <- y_combo_df$label
Xy_combo2_df$subject <- subject_combo_df$V1
library(data.table)
Xy_combo2_df=data.table(Xy_combo2_df)

Xy_combo2_df_mean <- Xy_combo2_df[, lapply(.SD, mean), by = list(subject,label)]

X_combo2_df <- Xy_combo2_df_mean[,3:563]
y_combo2_df <- Xy_combo2_df_mean$label
subject_combo2_df <- Xy_combo2_df_mean$subject

write_txt(X_combo2_df, fn_combo2_X)
write_txt(y_combo2_df, fn_combo2_y)
write_txt(subject_combo2_df, fn_combo2_subject)

# write a data.frame to txt file
write_txt_col_name <- function(data, fname){
  write.table(data, fname, append = FALSE, sep = " ", dec = ".",
              row.names = FALSE, col.names = TRUE)
}
write_txt_col_name(Xy_combo2_df_mean, "UCI_HAR_Dataset/combo2/Xy_combo2.txt" )
