library(dplyr)
library(downloader)
library(lubridate)

mes <- month(Sys.Date())-2
mes <- ifelse(mes<10, paste0('0',mes), mes)

anomes <- paste0(year(Sys.Date()), mes)

url <- paste0('https://portaldatransparencia.gov.br/download-de-dados/servidores/', anomes, '_Servidores_SIAPE')
download(url, dest="dataset.zip", mode="w") 
unzip ("dataset.zip")

cadastros <- paste0(anomes, '_Cadastro.csv')
afastamentos <- paste0(anomes, '_Afastamentos.csv')
observacoes <- paste0(anomes, '_Observacoes.csv')
remuneracao <- paste0(anomes, '_Remuneracao.csv')

cadastro <- read.csv2(cadastros, dec =",", fileEncoding='latin1')

file.remove(c('dataset.zip', cadastros, afastamentos, observacoes, remuneracao))


atrasados <- c(102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,
               203,204,205,206,207,208,209,210,211,212,213,214,215,216,
               304,305,306,307,308,309,310,311,312,313,314,315,316)

vetor_tecnicos <- c(101:116, 201:216, 301:316, 401:416)

tecnicosBR <- cadastro %>% 
  filter(grepl("Instituto Federal", ORG_LOTACAO), DESCRICAO_CARGO!= "Sem informação", DESCRICAO_CARGO!= "Inválido", !grepl("PROF", DESCRICAO_CARGO)) %>% 
   filter(PADRAO_CARGO%in%vetor_tecnicos) %>%
  select(ORG_LOTACAO, CPF, NOME, DESCRICAO_CARGO, CLASSE_CARGO, PADRAO_CARGO) %>% 
  mutate(PADRAO_CARGO = as.numeric(PADRAO_CARGO)) %>% 
  arrange(ORG_LOTACAO, PADRAO_CARGO, NOME)

names(tecnicosBR) <- c("Orgao", "CPF","Nome","Cargo", "Classe", "Padrao")

atrasadosBR <- tecnicosBR %>% 
  filter(Padrao%in%atrasados)
  

saveRDS(tecnicosBR,'data/tecnicosBR.rds')
