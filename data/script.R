library(dplyr)
library(downloader)
library(lubridate)

mes <- month(Sys.Date())-2
mes <- ifelse(mes<10, paste0('0',mes), mes)

anomes <- paste0(year(Sys.Date()), mes)

url <- paste0('https://portaldatransparencia.gov.br/download-de-dados/servidores/', anomes, '_Servidores_SIAPE')
download(url, dest="dataset.zip", mode="wb") 
unzip ("dataset.zip")

cadastros <- paste0(anomes, '_Cadastro.csv')
afastamentos <- paste0(anomes, '_Afastamentos.csv')
observacoes <- paste0(anomes, '_Observacoes.csv')
remuneracao <- paste0(anomes, '_Remuneracao.csv')


