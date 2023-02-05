#using linear regression to predict the Tax amount of a neighborhood based on the number of INDUStrial zoned lots

#loading the dataframe
bostonhousing.df <- BostonHousing

#plotting a scatterplot of industrial zoned lots (INDUS) against tax amount (TAX) using ggplot2
ggplot(bostonhousing.df) + geom_point(aes(x = INDUS, y = TAX), color = "navy", alpha = 0.7)

#calculating the correlation coeffecient
cor(x = bostonhousing.df$INDUS, y = bostonhousing.df$TAX)

#calculating the y-intercept and slope for the linear model
lm(INDUS ~ AGE, data = bostonhousing.df)

#creating a column of predicted TAX based on the linear model
bostonhousing.df$Pred.TAX = 0.3607 + (bostonhousing.df$TAX * 0.1571)

#calculating Error between predicted and actual values
bostonhousing.df$ERROR = bostonhousing.df$PRED.TAX - bostonhousing.df$TAX

#plotting INDUS vs TAX with a regression line for visualization
ggplot(bostonhousing.df, aes(INDUS, TAX)) +
+     geom_point() + 
+     geom_smooth(method = "lm")
