# Importando os pacotes
library(fable)
library(fabletools)
library(tsibble)
library(tsibbledata)
library(feasts)
library(dplyr)
library(tidyr)
library(ggplot2)
library(dplyr)

# Criar um índice de semana e calcular a soma semanal
serie_semanal <- data.frame(dia = 1:length(Chicago.Maior75.sab.dom[,2]), valor = Chicago.Maior75.sab.dom[,2]) %>%
  mutate(semana = ceiling(dia / 7)) %>%
  group_by(semana) %>%
  summarise(soma_semanal = (sum(valor, na.rm = TRUE)))

# Ver a série semanal
serie_semanal <- as_tsibble(serie_semanal, index = semana)

library(fabletools)
library(ggplot2)
library(dplyr)

# Criando a coluna de data
serie_semanal <- serie_semanal %>%
  mutate(data = seq.Date(from = as.Date("1987-01-03"), 
                         by = "week", 
                         length.out = n()))

# Criando o gráfico
serie_semanal %>%
  fabletools::autoplot(soma_semanal) +
  ggplot2::labs(title = "", y = "N° de Mortes") +
  ggplot2::scale_x_continuous(breaks = seq(1, n(), by = 1), 
                              labels = seq(1, n(), by = 1)) +  # Ajusta o eixo x para ter índices de 1 até n
  ggplot2::theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Opção para rotacionar os rótulos do eixo x

# Use `data` como índice no tsibble
serie_semanal <- serie_semanal %>%
  as_tsibble(index = data)

serie_semanal %>%
  autoplot(soma_semanal) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(title = "", 
       x = "Ano", 
       y = "N° de Mortes") +
  theme_minimal()


dados_treino <- serie_semanal[1:718, ]
dados_teste <- serie_semanal[719:731, ]
# Identificar os valores outliers
outliers <- boxplot.stats(dados$soma_semanal)$out
print(outliers)

Como tem vários outliers, aplico o log para reduzir

dados.originais <- dados

dados$soma_semanal <- log(dados$soma_semanal)



# Preparando os dados
dados <- serie_semanal[1:718,]
tam <- length(dados$soma_semanal)        # tamanho da série
t.1 <- seq(1:tam)                        # tendência
nu <- 1/52                               # frequência sazonal

# Criar as matrizes de seno e cosseno de ordem 26
SIN = COS = matrix(nr=length(dados$semana), nc=26)
for (i in 1:26) {
  COS[,i] = cos(2*pi*i*dados$semana/52)
  SIN[,i] = sin(2*pi*i*dados$semana/52)
}

# Ajuste da regressão harmônica de ordem 26
fit.1 <- lm(dados$soma_semanal ~ dados$semana + COS[,1] + SIN[,1] + COS[,2] + SIN[,2] +
              COS[,3] + SIN[,3] + COS[,4] + SIN[,4]+COS[,5] + SIN[,5])

# Resumo do ajuste
summary(fit.1)


# Criar as matrizes de seno e cosseno de ordem 4
SIN = COS = matrix(nr=length(dados$semana), nc=4)
for (i in 1:4) {
  COS[,i] = cos(2 * pi * i * dados$semana / 52)
  SIN[,i] = sin(2 * pi * i * dados$semana / 52)
}

# Ajuste da regressão harmônica de ordem 4
fit.4 <- lm(dados$soma_semanal ~ dados$semana + COS[,1] + SIN[,1] + 
              COS[,2] + SIN[,2] + COS[,3] + SIN[,3] + COS[,4] + SIN[,4])

summary(fit.4)

0SIN = COS = matrix(nr=length(dados$semana), nc=26)
for (i in 1:26) {
  COS[,i] = cos(2 * pi * i * dados$semana / 52)
  SIN[,i] = sin(2 * pi * i * dados$semana / 52)
}

fit.26 <- lm(dados$soma_semanal ~ dados$semana + COS[,1] + SIN[,1] + 
               COS[,2] + SIN[,2] + COS[,3] + SIN[,3] + COS[,4] + SIN[,4] +
               COS[,5] + SIN[,5] + COS[,6] + SIN[,6] + COS[,7] + SIN[,7] + 
               COS[,8] + SIN[,8] + COS[,9] + SIN[,9] + COS[,10] + SIN[,10] +
               COS[,11] + SIN[,11] + COS[,12] + SIN[,12] + COS[,13] + SIN[,13] +
               COS[,14] + SIN[,14] + COS[,15] + SIN[,15] + COS[,16] + SIN[,16] +
               COS[,17] + SIN[,17] + COS[,18] + SIN[,18] + COS[,19] + SIN[,19] +
               COS[,20] + SIN[,20] + COS[,21] + SIN[,21] + COS[,22] + SIN[,22] +
               COS[,23] + SIN[,23] + COS[,24] + SIN[,24] + COS[,25] + SIN[,25] +
               COS[,26] + SIN[,26])


summary(fit.26)



library(ggplot2)

# Supondo que fit.1 é o seu modelo ajustado
residuos <- residuals(fit.1)

# QQ-Plot
qq_plot <- ggplot(data = data.frame(residuos), aes(sample = residuos)) +
  geom_qq() +
  geom_qq_line() +
  labs(title = "", x = "Quantis Teóricos", y = "Quantis dos Resíduos") +
  theme_minimal()

print(qq_plot)

library(lmtest)

# Teste de Ljung-Box
ljung_box_test <- Box.test(residuos, lag = 20, type = "Ljung-Box")

# Resultados do teste
print(ljung_box_test)


# Calcular e plotar a PACF dos resíduos de forma simples
pacf(residuos, main = "")


pacf(residuo)



# Ajustando o modelo ARIMA com regressores
ar1 <- arima(x = dados$soma_semanal, order = c(1, 0, 0), 
             xreg = dados$semana + COS[,1] + SIN[,1] + COS[,2] + SIN[,2] +
               COS[,3] + SIN[,3] + COS[,4] + SIN[,4] + COS[,5] + SIN[,5],
             include.mean = F)
ar2 <- arima(x = dados$soma_semanal, order = c(2, 0, 0), 
             xreg = dados$semana + COS[,1] + SIN[,1] + COS[,2] + SIN[,2] +
               COS[,3] + SIN[,3] + COS[,4] + SIN[,4] + COS[,5] + SIN[,5],
             include.mean = F)
ar3 <- arima(x = dados$soma_semanal, order = c(3, 0, 0), 
             xreg = dados$semana + COS[,1] + SIN[,1] + COS[,2] + SIN[,2] +
               COS[,3] + SIN[,3] + COS[,4] + SIN[,4] + COS[,5] + SIN[,5],
             include.mean = F)
ar4 <- arima(x = dados$soma_semanal, order = c(19, 0, 0), 
             xreg = dados$semana + COS[,1] + SIN[,1] + COS[,2] + SIN[,2] +
               COS[,3] + SIN[,3] + COS[,4] + SIN[,4]+COS[,5] + SIN[,5],
             include.mean = F)
pacf(ar4$residuals,main="")
aic.1<-AIC(ar1)
aic.2<-AIC(ar2)
aic.3<-AIC(ar3)
aic.4<-AIC(ar4)
bic4<-BIC(ar4)
bic.1<-BIC(ar1)
bic.2<-BIC(ar2)
bic.3<-BIC(ar3)

hanna-quinn
logL1 <- logLik(ar1)
logL2 <- logLik(ar3)
logL3 <- logLik(ar3)
logL4 <- logLik(ar4)
k1 <- length(ar1$coef)
k2 <- length(ar2$coef)
k3 <- length(ar3$coef)
k4 <- length(ar4$coef)
n <- as.numeric(nrow(1:718))
HQ1 <- -2*as.numeric(logL1) + 2 * k1 * log(log(n))
HQ2 <- -2 * as.numeric(logL2) + 2 * k2 * log(log(n))
HQ3 <- -2 * as.numeric(logL3) + 2 * k3 * log(log(n))
HQ4 <- -2 * as.numeric(logL4) + 2 * k4 * log(log(n))
n <- nrow(dados)
print(n)

pacf.ar1<-pacf(ar1$residuals,main="")
pacf.ar2<-pacf(ar2$residuals,main="")
pacf.ar3<-pacf(ar3$residuals,main="")

# Supondo que você quer usar o modelo AR(1) para previsão
# Primeiro, vamos criar as matrizes de seno e cosseno para as previsões
future_weeks <- 13
n <- length(dados$soma_semanal)

# Criar as matrizes de seno e cosseno para as próximas 13 semanas
future_weeks_index <- seq(n + 1, n + future_weeks)
SIN_future = COS_future = matrix(nr = future_weeks, nc = 5)

for (i in 1:5) {
  COS_future[, i] = cos(2 * pi * i * future_weeks_index / 52)
  SIN_future[, i] = sin(2 * pi * i * future_weeks_index / 52)
}

# Fazer as previsões
predictions <- predict(ar1, n.ahead = future_weeks, 
                       newxreg = future_weeks_index + COS_future + SIN_future)

# Converta as previsões de log de volta ao nível original
predicted_values <- exp(predictions$pred)

# Criar um dataframe para as previsões
future_dates <- seq.Date(from = max(serie_semanal$data), by = "week", length.out = future_weeks)
forecast_df <- data.frame(data = future_dates, predicted_soma_semanal = predicted_values)

# Adicionar previsões ao gráfico existente
ggplot() +
  geom_line(data = serie_semanal, aes(x = data, y = soma_semanal), color = "blue") +
  geom_line(data = forecast_df, aes(x = data, y = predicted_soma_semanal), color = "red") +
  labs(title = "Previsão de Mortes Semanais", 
       x = "Data", 
       y = "N° de Mortes") +
  theme_minimal() +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  geom_ribbon(data = forecast_df, aes(x = data, ymin = predicted_soma_semanal - 1.96 * sd(residuos), 
                                      ymax = predicted_soma_semanal + 1.96 * sd(residuos)), alpha = 0.2)
