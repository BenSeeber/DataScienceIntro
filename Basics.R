#Die Basis für ein R Skript ist es auch ein paar Kommentare zu machen
#Wie z.B. das jetzt eine Library Installiert wird.
install.packages('rbokeh')
install.packages('xgboost')
install.packages('keras')

#Ups... jetzt sind doch ein paar mehr Packete installiert
#Dann können diese jetzt auch geladen werden
library(rbokeh)
library(xgboost)
library(keras)

#Wie erfolgt die Referenzierung in R? Ganz einfach mit einem <- 
#Dann kann man einfach einer Variablen einen Character zuweisen
ich_bin_ein_string <- 'LoL'
aber_ich_bin_der_geilere_strin <- "LoLLL"

#Dann sind auch Integer gar nicht so schwer
Ganzzahl <- 42
#Was war ich noch mal?
typeof(Ganzzahl)
#Oh doch keine Ganzzahl, dann noch mal
Ganzzahl <- as.integer(Ganzzahl)
typeof(Ganzzahl)
#Jetzt aber, und ja ich kann mich selber überschreiben
sprintf("Ich bin ein %s",typeof(Ganzzahl))
#Ja geil jetzt wissen es alle

#So jetzt mal ein Vektor
cooler_vector <- c('ich','bin','ein','vecotr')

#und ich kann auch anders
cooler_vector[1:2]

#mit dem
cooler_vector_zwei <- c('Ich','bin','noch','geiler','Dude')

#gibt es ein data.frame
gang <- data.frame(cooler_vector,cooler_vector_zwei)
#ups... muss wohl einer gehen, füße ab
gang <- data.frame(cooler_vector,head(cooler_vector_zwei,-1))
gang
#jetzt noch die Namen
colnames(gang) <- c('Coole','Nase')

#So das war das wichtigste
#oh noch schnell mal was einlesen
aus_nem_csv <- read.csv('~/test.csv',sep = ",")

#Ach ja, evtl. braucht es noch einmal den Typ Matrix aus einem Dataframe
data.matrix(gang)

#Ach und wer auch mal was mit einer Funktion machen möchte
geilefunktion <- function(input) 
  {
  for (i in input)
    {
    print(i)
    }
}

geilefunktion(gang)

typeof(gang$Coole[1])




