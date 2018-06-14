options(java.parameters = "-Xmx8000m")
library("RJDBC")
library('Metrics')
library('Rtsne')
library(rbokeh)

#Set db parameter
db <- '10.0.6.25:30015'
schema <- 'CREDICARDFRAUD'

#Set credentials for db
dbuser <- 'F095'
dbpw <- 'fp6Y#ju9'

#Set driver location
driverlocation <- "/Users/f095/ngdbc.jar"

#set up jdbc connection with ngdbc.jar driver, provided by SAP
##load driver
jdbcDriver <- JDBC(driverClass="com.sap.db.jdbc.Driver",
                   classPath=driverlocation)
##set up db conenction
jdbcConnection <- dbConnect(jdbcDriver,
                            sprintf("jdbc:sap://%s/?currentschema=%s",db,schema)
                            ,dbuser
                            ,dbpw)

data_fraud <- dbGetQuery(jdbcConnection, 'SELECT * FROM "CREDICARDFRAUD"."CREDITCARDFRAUD" WHERE "class"=1')
data_nonfraud <- dbGetQuery(jdbcConnection, 'SELECT * FROM "CREDICARDFRAUD"."CREDITCARDFRAUD" WHERE "class"=0')

## set the seed to make your partition reproductible
smp_size <- floor(0.01 * nrow(data_nonfraud))
set.seed(123)
sample_ind <- sample(seq_len(nrow(data_nonfraud)), size = smp_size)
data_nonfraud_sample <- data_nonfraud[sample_ind, ]

data <- rbind(data_fraud, data_nonfraud_sample)

data_unique <- unique(data[!(colnames(data) %in% c("time"))])

data_plot <- Rtsne(data_unique[!(colnames(data_unique) %in% c("class"))])

Class <- as.character(data_unique$class)

Amount <- round(data_unique$amount)

figure(width = 700, height = 800, xlab='DIM 1', ylab='DIM 2', title='Dimension Reduction with TSNE') %>%
  ly_points(data_plot$Y[,1], data_plot$Y[,2], color = Class,
            data = Amount, hover = list(Amount))