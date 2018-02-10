#Program to generate new cluster for spotify API data. Additionally, predicting cluster numbers using random forrest predictive modelling
setwd("C:/Users/user/Downloads")
getwd()


#Installing relevant R libraries
install.packages("readr") # FOr reading input dataset
install.packages("ggplot2") #For data visualisation
install.packages("rJava") #For Random Forest Modelling
install.packages("useful") # Package for K-means clustering

#Reading the existing cluster dataset used in decisison brief
library(readr)
spotify <- read.csv("C:/Users/user/Downloads/Spotify_std_1.csv",header = TRUE)
head(spotify,5)

spotify$clusterNum = as.factor(spotify$clusterNum) #Converting the cluster from int to unordered factor

str(spotify)
library(randomForest)  #Random Forest Library
library(e1071)  
library(caret)  
library(ggplot2)  
set.seed(123) #Setting seed for constant simulated result in random forest
sample.ind = sample(2,  
                    nrow(spotify),
                    replace = T,
                    prob = c(0.3,0.7)) # Splitting the existing cluster dataset into training and test in the ratio 0.3:0.7
spotify.train = spotify[sample.ind==1,]  #Train dataset
spotify.test = spotify[sample.ind==2,]  #Test dataset

#Deleting character variables and strings for cluster analysis
spotify.train$song_title = NULL
spotify.train$artist = NULL
str(spotify.train)

#Modelling the existing cluster dataset usimg random forest modelling
rf = randomForest(clusterNum ~ .,  
                  ntree = 100,
                  data = spotify.train)
plot(rf)  
print(rf,limit = 10) #Confusion matrix to validate different clusters with their accuracies

#Evaluating importance of each song attribute to determine the target variable
varImpPlot(rf,  
           sort = T,
           n.var=10,
           main="Top 10 - Variable Importance")
var.imp = data.frame(importance(rf,  type=2))
var.imp$Variables = row.names(var.imp)  
print(var.imp[order(var.imp$MeanDecreaseGini,decreasing = T),])

#Predicting cluster values using the random forest modelling
spotify.train$predicted.response = predict(rf , spotify.train)

print(  
  confusionMatrix(data = spotify.train$predicted.response,  
                  reference = spotify.train$clusterNum)) # COnfusion matrix to assess the accuracy, sensitivity and specificity for the preidicted model

# Predicting response variableusing test dataset( Note: Random FOrest is a self-learning algorithm)
spotify.test$predicted.response <- predict(rf ,spotify.test)

# Create Confusion Matrix
print(  
  confusionMatrix(data=spotify.test$predicted.response,  
                  reference=spotify.test$clusterNum))

#Loading the validation dataset that is SPotify API song attributes obtained
spotify_new <- read.csv("C:/Users/user/Downloads/New2000 tracks_2_attr.csv",header = TRUE)
head(spotify_new,5)
#Cleaning the loaded dataset
##Deleting character variables and strings for cluster analysis
spotify_new$danceability = spotify_new$ï..danceability 
spotify_new$ï..danceability = NULL
str(spotify_new)

spotify_new$predicted.response <- predict(rf ,spotify_new) #Prediciting the target variable (cluster number) for spotify API dataset

head(spotify_new,5)

write.table(spotify_new, "C:/Users/user/Downloads/Spotify_new.txt", sep="\t") #Exporting clustering output 

#Assessing the output, we conclude that the clustering is still biasing towards top artists and tracks and hence, we do not see many tracks in the 2nd and 5th cluster. In order to avoid this discrepancy, we need to do a clsuter analysis on the combined ataset of initial spotify attributes dataset plus songs retrived from SPotify API

#K means CLustering

#Loding the combined dataset
spotify_combined <- read.csv("C:/Users/user/Downloads/K-Means_Full.csv",header = TRUE)
head(spotify_combined,5)
summary(spotify_combined)

#Cleaning the loaded dataset
spotify_combined$danceability = spotify_combined$ï..danceability 
spotify_combined$ï..danceability = NULL
str(spotify_combined)

##Deleting character variables and strings for cluster analysis
spotify_combined$Artist.Name = NULL
spotify_combined$Tracks = NULL
spotify_combined$Key = NULL
spotify_combined$Segment = NULL

#setting aseed for constant value during simulation
set.seed(278613)

#Removing hte null and NAs
x = complete.cases(spotify_combined)
y = spotify_combined[x,]

#We ran a Hartigan's test to see the optimal size of clusters but provided inconclusive reults. Additionally, we wanted to be consistent with our earlier clustering algorithm for better results.

library(useful)
#Running a K-means clustering with 4 clusters on the cleaned,combined dataset
spotify_newcluster<- kmeans(x=y , centers=4, nstart = 25)
spotify_newcluster
spotify_newcluster$cluster
str(y)
#Adding the generated cluster value to the existing dataset
spotify_4cluster = cbind(y,spotify_newcluster$cluster)
head(spotify_4cluster, n=5)

#Running a K-means clustering with 5 clusters on the cleaned,combined dataset
spotify_newcluster1<- kmeans(x=y , centers=5, nstart = 25)
spotify_newcluster1
spotify_newcluster1$cluster
str(y)
#Adding the generated cluster value to the existing dataset
spotify_4cluster1 = cbind(y,spotify_newcluster1$cluster)
head(spotify_4cluster1, n=5)

#Exporting the datasets to evaluate the best cluster size
write.table(spotify_4cluster, "C:/Users/user/Downloads/Spotify_4clust.txt", sep="\t")
write.table(spotify_4cluster1, "C:/Users/user/Downloads/Spotify_5clust.txt", sep="\t")

#On evaluating the distribution for cluster-size =4,5, we concluded that cluster size 5 fits best and is also aligned with our earlier clustering algorithm giving us a fair platform to compare them 