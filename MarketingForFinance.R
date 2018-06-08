library(rbokeh)
#Ich lade die Daten
data <- read.csv('~/DATA/DataScienceKurs/bank/bank-full.csv',sep = ';')

#Sampling
set.seed(123)
smp_size <- round(0.8 * nrow(data))
sample_ind <- sample(seq_len(nrow(data)), size = smp_size)

train <- data[sample_ind, ]
test <- data[-sample_ind,]

#Explorative Analyse

figure() %>%
  ly_hist(as.integer(train$y))

train_reagiert <- train[train$y=='yes', ] #@Stephan Komma nicht vergessen
train_nicht_reagiert <- train[train$y=='no', ]

figure(title='Nicht IBCS Konform!') %>%
  ly_hist(train_reagiert$age,color='red') %>%
  ly_hist(train_nicht_reagiert$age,color='blue')


figure(title='Nicht IBCS Konform!') %>%
  ly_hist(train_reagiert$age,color='red') %>%
  ly_hist(train_nicht_reagiert$age,color='blue')

figure(title='Nicht IBCS Konform!') %>%
  ly_hist(as.integer(train_reagiert$education),color='red') %>%
  ly_hist(as.integer(train_nicht_reagiert$education),color='blue')
levels(train_reagiert$education)

figure(title='Nicht IBCS Konform!') %>%
  ly_hist(as.integer(train_reagiert$housing),color='red') %>%
  ly_hist(as.integer(train_nicht_reagiert$housing),color='blue')
levels(train_reagiert$default)

#Build first model

model <- glm(y~., family = binomial, data = train)

summary(model)

pred <- predict(model,test)

pred_prob <- exp(pred)/(1+exp(pred))
plot(sort(pred_prob))

pred_dec <- pred_prob
pred_dec[pred_dec>0.5] <- 1
pred_dec[pred_dec<=0.5] <- 0

plot(test$y)

figure() %>%
  ly_points(data.frame(seq(1,10),pred_dec[79:88]),color='gray') %>%
  ly_points(data.frame(seq(1,10),as.integer(test$y[79:88])-1),color='red')

base_fore_metric <- data.frame(as.integer(test$y)-1,
                              pred_dec)
colnames(base_fore_metric) <- c('Y','PRED')

base_fore_metric$TP <- rep(0, nrow(base_fore_metric)) 
base_fore_metric$FP <- rep(0, nrow(base_fore_metric)) 
base_fore_metric$FN <- rep(0, nrow(base_fore_metric)) 

base_fore_metric[base_fore_metric$Y==1 & base_fore_metric$PRED==1,]$TP <- 1
base_fore_metric[base_fore_metric$Y==0 & base_fore_metric$PRED==1,]$FP <- 1
base_fore_metric[base_fore_metric$Y==1 & base_fore_metric$PRED==0,]$FN <- 1

num_TP <- sum(base_fore_metric$TP)
num_FP <- sum(base_fore_metric$FP)
num_FN <- sum(base_fore_metric$FN)

prec <- num_TP/(num_TP+num_FN)
rec <- num_TP/(num_TP+num_FP)
prec
rec

library(xgboost)

train.data <- data.matrix(train[,1:16])
train.label <- data.matrix(as.integer(train[,17])-1)
test.data <- data.matrix(test[,1:16])
test.label <- data.matrix(as.integer(test[,17])-1)

clf <- xgboost(data = train.data, label = train.label, max_depth = 10, eta = 0.015, nthread = 4, 
               nrounds = 500, objective = "binary:logistic") 

perd_xg <- predict(clf,test.data)

pred_dec <- perd_xg
pred_dec[pred_dec>0.5] <- 1
pred_dec[pred_dec<=0.5] <- 0

base_fore_metric <- data.frame(test.label,
                               pred_dec)
colnames(base_fore_metric) <- c('Y','PRED')

base_fore_metric$TP <- rep(0, nrow(base_fore_metric)) 
base_fore_metric$FP <- rep(0, nrow(base_fore_metric)) 
base_fore_metric$FN <- rep(0, nrow(base_fore_metric)) 

base_fore_metric[base_fore_metric$Y==1 & base_fore_metric$PRED==1,]$TP <- 1
base_fore_metric[base_fore_metric$Y==0 & base_fore_metric$PRED==1,]$FP <- 1
base_fore_metric[base_fore_metric$Y==1 & base_fore_metric$PRED==0,]$FN <- 1

num_TP <- sum(base_fore_metric$TP)
num_FP <- sum(base_fore_metric$FP)
num_FN <- sum(base_fore_metric$FN)

prec <- num_TP/(num_TP+num_FN)
rec <- num_TP/(num_TP+num_FP)
prec
rec
