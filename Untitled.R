original_dataset_dir <- "/Users/f095/DATA/DataScienceKurs/CatDogTrain"

base_dir <- "/Users/f095/DATA/DataScienceKurs/cats_and_dogs_small"
dir.create(base_dir,showWarnings = FALSE)

train_dir <- file.path(base_dir, "train")
dir.create(train_dir,showWarnings = FALSE)
validation_dir <- file.path(base_dir, "validation")
dir.create(validation_dir,showWarnings = FALSE)
test_dir <- file.path(base_dir, "test")
dir.create(test_dir,showWarnings = FALSE)

train_cats_dir <- file.path(train_dir, "cats")
dir.create(train_cats_dir,showWarnings = FALSE)

train_dogs_dir <- file.path(train_dir, "dogs")
dir.create(train_dogs_dir,showWarnings = FALSE)

validation_cats_dir <- file.path(validation_dir, "cats")
dir.create(validation_cats_dir,showWarnings = FALSE)

validation_dogs_dir <- file.path(validation_dir, "dogs")
dir.create(validation_dogs_dir,showWarnings = FALSE)

test_cats_dir <- file.path(test_dir, "cats")
dir.create(test_cats_dir,showWarnings = FALSE)

test_dogs_dir <- file.path(test_dir, "dogs")
dir.create(test_dogs_dir,showWarnings = FALSE)

fnames <- paste0("cat.", 1:1000, ".jpg")
file.copy(file.path(original_dataset_dir, fnames), 
          file.path(train_cats_dir)) 

fnames <- paste0("cat.", 1001:1500, ".jpg")
file.copy(file.path(original_dataset_dir, fnames), 
          file.path(validation_cats_dir))

fnames <- paste0("cat.", 1501:2000, ".jpg")
file.copy(file.path(original_dataset_dir, fnames),
          file.path(test_cats_dir))

fnames <- paste0("dog.", 1:1000, ".jpg")
file.copy(file.path(original_dataset_dir, fnames),
          file.path(train_dogs_dir))

fnames <- paste0("dog.", 1001:1500, ".jpg")
file.copy(file.path(original_dataset_dir, fnames),
          file.path(validation_dogs_dir)) 

fnames <- paste0("dog.", 1501:2000, ".jpg")
file.copy(file.path(original_dataset_dir, fnames),
          file.path(test_dogs_dir))

#Load pretrained Network
library(keras)

conv_base <- application_vgg16(
  weights = "imagenet",
  include_top = FALSE,
  input_shape = c(150, 150, 3)
)

summary(conv_base)

#Feature Extraction
model <- keras_model_sequential() %>% 
  conv_base %>% 
  layer_flatten() %>% 
  layer_dense(units = 256, activation = "relu") %>% 
  layer_dense(units = 1, activation = "sigmoid")

summary(model)

length(model$trainable_weights)

freeze_weights(conv_base)
length(model$trainable_weights)

train_datagen = image_data_generator(
  rescale = 1/255,
  rotation_range = 40,
  width_shift_range = 0.2,
  height_shift_range = 0.2,
  shear_range = 0.2,
  zoom_range = 0.2,
  horizontal_flip = TRUE,
  fill_mode = "nearest"
)

# Note that the validation data shouldn't be augmented!
test_datagen <- image_data_generator(rescale = 1/255)  

train_generator <- flow_images_from_directory(
  train_dir,                  # Target directory  
  train_datagen,              # Data generator
  target_size = c(150, 150),  # Resizes all images to 150 × 150
  batch_size = 20,
  class_mode = "binary"       # binary_crossentropy loss for binary labels
)

validation_generator <- flow_images_from_directory(
  validation_dir,
  test_datagen,
  target_size = c(150, 150),
  batch_size = 20,
  class_mode = "binary"
)

model %>% compile(
  loss = "binary_crossentropy",
  optimizer = optimizer_rmsprop(lr = 2e-5),
  metrics = c("accuracy")
)

history <- model %>% fit_generator(
  train_generator,
  steps_per_epoch = 100,
  epochs = 1,
  validation_data = validation_generator,
  validation_steps = 50
)

#Test Model
test_generator <- flow_images_from_directory(
  test_dir,
  test_datagen,
  target_size = c(150, 150),
  batch_size = 20,
  class_mode = "binary"
)

model %>% evaluate_generator(test_generator, steps = 2)

pred <- model %>% predict_generator(test_generator,steps=1)
a <- reticulate::iter_next(test_generator)

pred_bi <- pred
pred_bi[pred_bi>0.5]<-1
pred_bi[pred_bi<=0.5]<-0

data.frame(a[[2]],pred_bi)



