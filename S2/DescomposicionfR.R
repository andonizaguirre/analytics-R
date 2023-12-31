rm(list=ls())

#########################################################################
### -- ANAL�TICA PREDICTIVA DE DATOS -- ## 
#########################################################################
### Autores: Jose Cardenas ## 

#########################################################################

########### 1) LIBRERIAS A UTILIZAR ################# 

library(ggplot2)
library(TSA)
library(forecast)
library(scales)
library(stats)
#library(arima)

########### 2) DATA A UTILIZAR ################# 

## En Rstudio Cloud utilizar el siguiente comando
# Yt <- read.delim("./datatesisaereo.txt",header=T)

## En Rstudio de escritorio utilizar el siguiente comando

# Carga de datos
Yt<-read.delim("datatesisaereo.txt",header=T)
Yt<-ts(Yt,start=c(2000,1),freq=12)

########### 3) TRATAMIENTO DE LA DATA ################# 

## en primer lugar ver el analisis descriptivo de la data

# Grafico de la serie

# PERUANOS QUE RETORNAN MEDIANTE AVION AL PERU DEL
# A�O 2000 AL 2012

plot(Yt)

## Podemos observar si existe estacionalidad en un 
## gr�ficos de cajas agregados

# Agrupacion de meses
boxplot(Yt ~ cycle(Yt))
cycle(Yt)

## Aplicamos la sentencia para enf. descomposicion
Yt.ts.desc <- decompose(Yt,type="multiplicative")
plot(Yt.ts.desc, xlab='A�o')
Yt.ts.desc 

## Empezaremos a modelar con cada componente

# 1) Tendencia
rm(tendencia)
tendencia <- data.frame(trend = Yt.ts.desc$trend)
summary(tendencia)

tendencia$x <- seq(1:nrow(tendencia))

# MIN : 423.2
# MAX : 1818.6

## Reemplazaremos los nulos por cero
# tendencia$Yt.ts.desc.trend[is.na(tendencia$Yt.ts.desc.trend)]=0

library(sqldf)

tendencia$tendencia_imp <- sqldf(" 
select  
case
when trend is null and x<=6  then 423.2
when trend is null and x>=151  then 1818.6
else trend end tendencia_imputada
from tendencia")

tendencia <- data.frame(trend=tendencia$trend,x=tendencia$x,tendencia_imp=tendencia$tendencia_imp)

# modelamiento de la tendencia ( mediante un modelo propuesto en el pto 1)

# con lm relizamos un modelo de regresion lineal
modelo_tendencia <- lm(tendencia_imputada~x,tendencia)
# vamos a extraer los valores estimados
tendencia_estimada <- modelo_tendencia$fitted.values
head(tendencia_estimada) # aca observamos los 6 primeros valores

# 2) Estacionalidad
estacional <- data.frame(Yt.ts.desc$seasonal)
head(estacional)

# 3) estimacion de la serie en base a un modelo multiplicativo

dataf <- data.frame(tendencia_estimada,estacional);
colnames(dataf) <- c('tend_est','estacionalidad')

# al ser un modelo multiplicativo 
dataf$Yt_est <- dataf$tend_est * dataf$estacionalidad

## Grafico del modelo final

plot(Yt,col="red")
points(dataf$Yt_est,type='l',col="blue")

## Ejercicio: Modelemos en base a otro modelo la tendencia y comparar

## QUE PASARIA SI EL MODELO ES ADITIVO

## EXTRAER DE LA LISTA Yt.ts.desc LA TENDENCIA Y COEFF ESTACIONLES

# Y(T) = TENDENCIA + cOEF_ESTADCIONALES
## OJO : ANTES DE SUMAR DEBEN IMPUTAR LA TENDENCIA


# Mineria_MachuPichu_turismo