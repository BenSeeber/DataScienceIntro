#Data package
library(car)
#One favorit Plot package
library(ggplot2) 
#Data handling package
library(MASS) 
#Boosting tree Alg.
library(xgboost)
#An other nice plot package
library(rbokeh)

newdata <- Prestige[,c("education","income")]
max(newdata$education)
min(newdata$education)
# fit a linear model and run a summary of its results.
set.seed(1)
education.c <- scale(newdata$education, center=TRUE, scale=FALSE)
mod = lm(income ~ education.c, data = newdata)
summary(mod)

# visualize the model results.
qplot(education.c, income, data = newdata, main = "Relationship between Income and Education") +
  stat_smooth(method="lm", col="red") +
  scale_y_continuous(breaks = c(1000, 2000, 4000, 6000, 8000, 10000, 12000, 14000, 16000, 18000, 20000, 25000), minor_breaks = NULL)

plot(mod, pch=16, which=1)
train.pred_lm <- predict(mod)

train.data <- data.matrix(scale(newdata$education, center=TRUE, scale=FALSE))
train.label <- data.matrix(newdata$income)
mod2 <- xgboost(data = train.data, label = train.label, max_depth = 10, eta = 0.1, nthread = 4, 
          nrounds = 100, objective = "reg:linear")

train.pred <- predict(mod2, train.data)

figure() %>%
  ly_points(data.frame(train.data,train.label),color="gray") %>%
  ly_points(data.frame(train.data,train.pred),color = "green") %>%
  ly_points(data.frame(train.data,train.pred_lm))

# 

