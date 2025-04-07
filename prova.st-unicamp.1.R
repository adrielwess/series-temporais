# Importando os pacotes

library(dplyr)
library(lubridate)
library(fable)
library(fabletools)
library(tsibble)
library(tsibbledata)
library(feasts)
library(tidyr)
library(ggplot2)
library(dplyr)

library(dplyr)
library(lubridate)

# Criar um índice de semana corretamente alinhado de domingo a sábado
serie_semanal <- data.frame(
  dia = 1:length(Chicago.Maior75[,2]), 
  valor = Chicago.Maior75[,2]
) %>%
  mutate(
    data = as.Date("1987-01-03") + (dia - 1) # Criar as datas a partir de 03/01/1987
  ) %>%
  mutate(
    semana = as.integer((data - as.Date("1987-01-04")) / 7) + 1 # Definir as semanas corretamente
  ) %>%
  group_by(semana) %>%
  summarise(
    data_inicio = min(data),  # Primeiro dia da semana (domingo)
    data_fim = max(data),     # Último dia da semana (sábado)
    soma_semanal = sum(valor, na.rm = TRUE)
  ) %>%
  ungroup()

# Ajustar a primeira semana manualmente
serie_semanal$soma_semanal[1] <- sum(
  Chicago.Maior75[1:7, 2], na.rm = TRUE # Somar os valores de 04/01/1987 a 10/01/1987
)

# Verificar se a primeira semana bate com 415 e a última com 30/12/2000
head(serie_semanal, 3)
tail(serie_semanal, 3)


# Ver a série semanal
serie_semanal <- as_tsibble(serie_semanal, index = semana)

serie_semanal %>%
  fabletools::autoplot(soma_semanal) +
  ggplot2::labs(title = "Séries de mortalidade em maiores de 75 em Chicago", y = "N° de Mortes")

serie_semanal <- serie_semanal %>%
  mutate(data = seq.Date(from = as.Date("1987-01-01"), 
                         by = "week", 
                         length.out = n()))

# Usar `data` como índice no tsibble
serie_semanal <- serie_semanal %>%
  as_tsibble(index = data)

serie_semanal %>%
  autoplot(soma_semanal) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(title = "", 
       x = "Ano", 
       y = "N° de Mortes") +
  theme_minimal()


# Observando a série em um período de 3 anos
library(dplyr)
library(lubridate)

# Supondo que sua série semanal já tenha sido criada, aqui está o código para adicionar a coluna de datas
serie_semanal <- serie_semanal %>%
  mutate(data = as.Date("1987-01-01") + weeks(semana - 1))

# Filtrar os 3 primeiros anos (até o final de 1989)
serie_semanal_3_anos <- serie_semanal %>%
  filter(data >= as.Date("1987-01-01") & data < as.Date("1991-01-01"))

# Plotar a série filtrada com datas no eixo x
ggplot(serie_semanal_3_anos, aes(x = data, y = soma_semanal)) +
  geom_line(color = "black") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(title = "Séries de mortalidade em maiores de 75 em Chicago (1987-1990)", 
       x = "Ano", 
       y = "N° de Mortes") +
  theme_minimal()


# A série aparentemente tem um comportamento anual, são observados ciclos que se repetem
# a cada ano então a frequencia será a cada ano

# Ajustes

tam <- length(serie_semanal$soma_semanal)        # tamanho da serie
t.1 <- seq(1:tam)           # tendencia
n.p <- tam/52                # numero de periodos
nu <- 1/52

# ajuste

# Criar um dataframe apenas com as 718 primeiras semanas
df_modelo <- serie_semanal[1:718, ]

# Adicionar os componentes harmônicos ao dataframe
df_modelo$COS1 <- cos(2*pi*1*df_modelo$semana/52)
df_modelo$SIN1 <- sin(2*pi*1*df_modelo$semana/52)
df_modelo$COS2 <- cos(2*pi*2*df_modelo$semana/52)
df_modelo$SIN2 <- sin(2*pi*2*df_modelo$semana/52)

# Ajustar o modelo
fit.1 <- lm(soma_semanal ~ semana + COS1 + SIN1 + COS2 + SIN2, data = df_modelo)

# Ver resultado do ajuste
summary(fit.1)

# Criar um novo dataframe para previsão
df_prev <- serie_semanal[719:tam, ]  

# Adicionar componentes harmônicos ao dataframe de previsão
for (i in 1:6) {
  df_prev[[paste0("COS", i)]] <- COS[719:tam, i]
  df_prev[[paste0("SIN", i)]] <- SIN[719:tam, i]
}

# Fazer previsão
previsoes <- predict(fit.1, newdata = df_prev)
previsoes

# Criando os dados de teste corretamente
dados_reais <- serie_semanal[719:730, ]

# Criando um dataframe para comparar os valores reais e previstos
dados_futuros <- data.frame(
  Data = dados_reais$data,  # Certifique-se de que 'data' existe em 'serie_semanal'
  Real = dados_reais$soma_semanal,
  Previsto = previsoes
)

# Visualizar os primeiros valores para conferir
head(dados_futuros)


# Combinando os dados reais e previstos para comparação
dados_combinados <- rbind(
  data.frame(Data = dados_reais$data, Valor = dados_reais$soma_semanal, Tipo = "Real"),
  data.frame(Data = dados_futuros$Data, Valor = dados_futuros$Previsto, Tipo = "Previsto")
)

# Criação do gráfico
ggplot(dados_combinados, aes(x = Data, y = Valor, color = Tipo, shape = Tipo)) +
  geom_point(size = 3) +
  scale_color_manual(values = c("Real" = "blue", "Previsto" = "red")) +
  scale_shape_manual(values = c("Real" = 16, "Previsto" = 17)) +
  labs(title = "",
       x = "Data",
       y = "Número de Mortes",
       color = "Tipo",
       shape = "Tipo") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "top"
  )


residuos <- residuals(fit.1)  # Extrai os resíduos do modelo
ajustados <- fitted(fit.1)    # Obtém os valores ajustados pelo modelo