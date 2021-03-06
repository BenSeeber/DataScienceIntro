library(keras)
library(reticulate)
use_condaenv("tfdeeplearning")
use_backend("plaidml")

imdb <- dataset_imdb(num_words = 10000)
c(c(train_data, train_labels), c(test_data, test_labels)) %<-% imdb
str(train_data[[1]])
#Labels are 0 and 1 for negative and positive rating
train_labels[[1]]

#Get maximal Index
max(sapply(train_data, max))

word_index <- dataset_imdb_word_index()

reverse_word_index <- names(word_index)
names(reverse_word_index) <- word_index

decoded_review <- sapply(train_data[[1]], function(index) {
  word <- if (index >= 3) reverse_word_index[[as.character(index - 3)]]
  if (!is.null(word)) word else "?"
  })

#Vectorize Review
vectorize_sequences <- function(sequences, dimension = 10000) {
  results <- matrix(0, nrow = length(sequences), ncol = dimension)
  for (i in 1:length(sequences))
    
    results[i, sequences[[i]]] <- 1
  results
}
x_train <- vectorize_sequences(train_data)
x_test <- vectorize_sequences(test_data)

#get idea of data
str(x_train[1,])

y_train <- as.numeric(train_labels)
y_test <- as.numeric(test_labels)

#set nn with two hidden layers and one output layer
model <- keras_model_sequential() %>%
  layer_dense(units = 16, activation = "relu", input_shape = c(10000)) %>%
  layer_dense(units = 16, activation = "relu") %>%
  layer_dense(units = 1, activation = "sigmoid")

#set optimizer
model %>% compile(
  optimizer = "rmsprop",
  loss = "binary_crossentropy",
  metrics = c("accuracy")
)

#split dataset in training and validation
val_indices <- 1:10000
x_val <- x_train[val_indices,]
partial_x_train <- x_train[-val_indices,]
y_val <- y_train[val_indices]
partial_y_train <- y_train[-val_indices]

#train model with 20 epochs
history <- model %>% fit(
  partial_x_train,
  partial_y_train,
  epochs = 20,
  batch_size = 512,
  validation_data = list(x_val, y_val)
)

#plot statistics
str(history)
plot(history)

#Retrain from Scratch with 4 epochs
model <- keras_model_sequential() %>%
  layer_dense(units = 16, activation = "relu", input_shape = c(10000)) %>%
  layer_dense(units = 16, activation = "relu") %>%
  layer_dense(units = 1, activation = "sigmoid")
model %>% compile(
  optimizer = "rmsprop",
  loss = "binary_crossentropy",
  metrics = c("accuracy")
)
model %>% fit(x_train, y_train, epochs = 4, batch_size = 512)
results <- model %>% evaluate(x_test, y_test)

#Apply Model

y_pred <- model %>% predict(x_test[1:10,])

library(rbokeh)
figure() %>%
  ly_points(data.frame(seq(1,10),y_test[1:10])) %>%
  ly_points(data.frame(seq(1,10),y_pred[1:10]),color='red')