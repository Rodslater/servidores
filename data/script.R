library(httr)
library(lubridate)
library(downloader)
library(dplyr)

memory.limit(24576)
options(timeout = 200)

datas <- c()
for (i in 0:3) {
  mes <- month(Sys.Date()) - i
  mes <- ifelse(mes < 10, paste0('0', mes), mes)
  
  anomes <- paste0(year(Sys.Date()), mes)
  
  datas <- c(datas, anomes)
}


# Variável de controle para verificar se o primeiro arquivo foi baixado com sucesso
baixado <- FALSE

# Loop de baixar as séries
for (i in seq_along(datas)) {
  arquivo <- sprintf("dataset_%s.zip", datas[i])
  
  # Verifica se o arquivo já existe
  if (file.exists(arquivo)) {
    message(paste("Arquivo", arquivo, "já foi baixado. Continuando com o próximo arquivo."))
    next
  }
  
  url <- paste0('https://portaldatransparencia.gov.br/download-de-dados/servidores/', datas[i], '_Servidores_SIAPE', '.zip')
  
  # Verifica se o arquivo existe antes de fazer o download
  response <- tryCatch(
    {
      GET(url)
    },
    error = function(e) {
      return(NULL)
    }
  )
  
  # Se a resposta é NULL, o arquivo não existe, então passa para a próxima iteração
  if (is.null(response)) {
    message(paste("Arquivo não encontrado:", arquivo))
    return()
  }
  
  # Verifica se o primeiro arquivo já foi baixado com sucesso
  if (!baixado) {
    tryCatch(
      {
        download(url, dest = arquivo, mode = "wb")
        unzip(arquivo)
        file.remove(arquivo)
        arquivos_csv <- list.files(pattern = "\\.csv$", full.names = TRUE)
        padroes_mantidos <- c(".*Cadastro\\.csv$")
        arquivos_remover <- arquivos_csv[!grepl(paste(padroes_mantidos, collapse = "|"), arquivos_csv)]
        file.remove(arquivos_remover)
        
        # Define a variável baixado como TRUE
        baixado <- TRUE
        
        # Importar o arquivo CSV final
        arquivo_final <- arquivos_csv[grepl(paste(padroes_mantidos, collapse = "|"), arquivos_csv)]
        cadastro <- read.csv2(arquivo_final, dec =",", fileEncoding='latin1')
        
        # Remover o arquivo CSV final
        file.remove(arquivo_final)
        
      },
      error = function(e) {
        message(paste("Erro ao baixar o arquivo:", arquivo))
        return()
      }
    )
  }
}

 


atrasados <- c(102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,
               203,204,205,206,207,208,209,210,211,212,213,214,215,216,
               304,305,306,307,308,309,310,311,312,313,314,315,316)

vetor_tecnicos <- c(101:116, 201:216, 301:316, 401:416)

tecnicosBR <- cadastro |> 
  filter(grepl("Instituto Federal", ORG_LOTACAO), DESCRICAO_CARGO!= "Sem informação", DESCRICAO_CARGO!= "Inválido", !grepl("PROF", DESCRICAO_CARGO)) |> 
  filter(PADRAO_CARGO%in%vetor_tecnicos) |>
  select(ORG_LOTACAO, CPF, NOME, DESCRICAO_CARGO, CLASSE_CARGO, PADRAO_CARGO) |> 
  mutate(PADRAO_CARGO = as.numeric(PADRAO_CARGO)) |> 
  arrange(ORG_LOTACAO, PADRAO_CARGO, NOME)

names(tecnicosBR) <- c("Orgao", "CPF","Nome","Cargo", "Classe", "Padrao")


saveRDS(tecnicosBR,'data/tecnicosBR.rds')
