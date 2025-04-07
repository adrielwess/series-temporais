# Certifique-se de carregar os pacotes necessários
library(dplyr)
library(e1071)  
library(tidyverse)
library(ggplot2)
library(gridExtra)
library(forecast)

# Usando `tibble()` em vez de `data_frame()`
log.retornos <- tibble(Data = dados$...1, Retornos = dados$VALE3)
log.retornos$Retornos
# Substituindo valores faltantes por 0
log.retornos <- log.retornos %>%
  mutate(Retornos = ifelse(is.na(Retornos), 0, Retornos))

# Visualizar os primeiros registros
head(log.retornos)

# Renomeando a primeira coluna para 'data'
names(log.retornos)[1] <- "data"

# Calcular as estatísticas
estatisticas <- log.retornos %>%
  summarise(
    media = mean(Retornos),
    desvio_padrao = sd(Retornos),
    variancia = var(Retornos),
    curtose = kurtosis(Retornos),
    assimetria = skewness(Retornos),
    maximmo = max(Retornos),
    minimo = min(Retornos),
    observacoes = length(log.retornos$Retornos)
    
  )

# Adicionar coluna indicando se a distribuição é normal ou de cauda pesada
estatisticas <- estatisticas %>%
  mutate(distribuicao = ifelse(curtose > 3, "Cauda Pesada", "Normal"))
estatisticas




library(ggplot2)
ggplot(log.retornos) + 
  geom_line(aes(x =data, y = Retornos), color = "green4") +
  xlab("Tempo") + ylab("Preço")


library(ggplot2)

grafico_a <- ggplot(data = log.retornos, aes(x = Retornos)) +
  geom_histogram(aes(y = ..density..), bins = 30, fill = "#87CEFA", color = "#4682B4", alpha = 0.7) +
  geom_density(color = "#FF6347", linewidth = 1) +
  labs(title = "Quadro (A): Densidade dos Retornos", x = "Retornos", y = "Densidade") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 12)
  )

grafico_b <- ggplot(data = log.retornos, aes(sample = Retornos)) +
  stat_qq(color = "#4682B4", size = 1) +
  stat_qq_line(color = "#FF6347", linewidth = 1) +
  labs(title = "Quadro (B): QQ-Plot dos Retornos", x = "Quantis da Normal", y = "Quantis da Amostra") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 12)
  )


acf_data <- ggAcf(log.retornos$Retornos, plot = FALSE)
grafico_c <- ggAcf(log.retornos$Retornos, lag.max = 50, plot = TRUE) +
  labs(title = "Quadro (C): ACF dos Retornos", x = "Defasagens", y = "Autocorrelação") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 12)
  ) +
  geom_hline(yintercept = 0, color = "#FF6347", linewidth = 0.8, linetype = "dashed")


log.retornos$Retornos2 <- log.retornos$Retornos^2
acf_data_sq <- ggAcf(log.retornos$Retornos2, plot = FALSE)
grafico_d <- ggAcf(log.retornos$Retornos2, lag.max = 80, plot = TRUE) +
  labs(title = "Quadro (D): ACF dos Quadrados dos Retornos", x = "Defasagens", y = "Autocorrelação") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 12)
  ) +
  geom_hline(yintercept = 0, color = "#FF6347", linewidth = 0.8, linetype = "dashed")



# ACF para a série log.retornos$Retornos
acf_data <- ggAcf(log.retornos$Retornos, plot = FALSE)

grafico_acf <- ggAcf(log.retornos$Retornos, lag.max = 80, plot = TRUE) +
  labs(title = "Quadro (A): ACF dos Retornos", x = "Defasagens", y = "Autocorrelação") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 12)
  ) +
  geom_hline(yintercept = 0, color = "#FF6347", linewidth = 0.8, linetype = "dashed")

# Exibindo o gráfico
print(grafico_acf)

# PACF para a série log.retornos$Retornos
pacf_data <- ggPacf(log.retornos$Retornos, plot = FALSE)

grafico_pacf <- ggPacf(log.retornos$Retornos, lag.max = 80, plot = TRUE) +
  labs(title = "Quadro (B): PACF dos Retornos", x = "Defasagens", y = "Autocorrelação Parcial") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 12)
  ) +
  geom_hline(yintercept = 0, color = "#FF6347", linewidth = 0.8, linetype = "dashed")

# Exibindo o gráfico
print(grafico_pacf)


grid.arrange(grafico_acf, grafico_pacf, ncol = 2)

pacf(log.retornos$Retornos)
modelo<-arima(log.retornos$Retornos, order=c(4,0,0))
coeftest(modelo)
summary(modelo)


# ACF para a série log.retornos$Retornos
acf_data <- ggAcf(modelo$residuals^2, plot = FALSE)

grafico_acf <- ggAcf(modelo$residuals^2, lag.max = 80, plot = TRUE) +
  labs(title = "Quadro (A): ACF dos Resíduos", x = "Defasagens", y = "Autocorrelação") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 12)
  ) +
  geom_hline(yintercept = 0, color = "#FF6347", linewidth = 0.8, linetype = "dashed")

# Exibindo o gráfico
print(grafico_acf)

# PACF para a série log.retornos$Retornos
pacf_data <- ggPacf(modelo$residuals^2, plot = FALSE)

grafico_pacf <- ggPacf(modelo$residuals^2, lag.max = 80, plot = TRUE) +
  labs(title = "Quadro (B): PACF dos Resíduos ao quadrado", x = "Defasagens", y = "Autocorrelação Parcial") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 12)
  ) +
  geom_hline(yintercept = 0, color = "#FF6347", linewidth = 0.8, linetype = "dashed")

# Exibindo o gráfico
print(grafico_pacf)


grid.arrange(grafico_acf, grafico_pacf, ncol = 2)

grid.arrange(grafico_acf, grafico_pacf, ncol = 2)
























spec <- ugarchspec(mean.model = list(armaOrder = c(4, 0), include.mean = FALSE),
                   variance.model = list(model = 'sGARCH', garchOrder = c(3, 0)),
                   distribution = 'rnorm')
fit_01 <- ugarchfit(spec, log.retornos$Retornos, solver = 'hybrid')
plot(fit_01)

9
e_hat = fit_01@fit$residuals/fit_01@fit$sigma
op = par(mfrow = c(1,2))
acf(e_hat)
acf(e_hat^2)
par(op)

residuos<-fit_01@fit$residuals
qqnorm(residuos, main = "QQ-Plot dos Resíduos (Distribuição t-Student)")
qqline(residuos, col = "red", lwd = 2)

# QQ-Plot dos resíduos
qqnorm(residuos, main = "QQ-Plot dos Resíduos do Modelo AR(4)")
qqline(residuos, col = "red", lwd = 2) # Linha de referência


length(log.retornos$Retornos)

spec.g <- ugarchspec(mean.model = list(armaOrder = c(0, 0), include.mean = FALSE),
                     variance.model = list(model = 'sGARCH', garchOrder = c(1, 1)),
                     distribution = 'std')
fit_0 <- ugarchfit(spec.g, log.retornos$Retornos, solver = 'hybrid')

plot(fit_0)

roll <- ugarchroll(
  spec = spec.g,
  data = log.retornos$Retornos,
  n.ahead = 1,               # Previsão de 1 passo à frente
  forecast.length = 1000,    # Últimas 1000 observações para backtesting
  refit.every = 1,           # Reestimamos a cada observação
  refit.window = "moving",   # Janela rolante
  solver = "hybrid"          # Método de otimização
)

VaR_1 <- as.numeric(roll@forecast$VaR[, "alpha(1%)"])
obs <- retornos[(length(retornos) - 999):length(retornos)]  # Últimas 1000 observações


violations <- sum(obs < VaR_1)  # Número de violações
proportion_violations <- violations / length(obs)

cat("Proporção de violações do VaR:", proportion_violations, "\n")


library(ggplot2)

df <- data.frame(
  Observacao = 1:1000,
  Retornos = obs,
  VaR = VaR_1
)

ggplot(df, aes(x = Observacao)) +
  geom_line(aes(y = Retornos, color = "Retornos")) +
  geom_line(aes(y = VaR, color = "VaR 1%"), linetype = "dashed") +
  scale_color_manual(values = c("Retornos" = "blue", "VaR 1%" = "red")) +
  labs(title = "Backtesting do VaR de 1%", x = "Observações", y = "Retornos / VaR") +
  theme_minimal()



library(rugarch)
janela_inicial <- 4176  # Número de observações iniciais na janela
forecast_horizon <- 1000  # Número de observações para previsão

spec <- ugarchspec(
  variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
  mean.model = list(armaOrder = c(0, 0), include.mean = TRUE),
  distribution.model = "std"  # Distribuição t-student
)

# Inicializando objetos para armazenar resultados
VaR_pred <- numeric(forecast_horizon)
obs <- log.retornos$Retornos[(janela_inicial + 1):(janela_inicial + forecast_horizon)]

for (i in 1:forecast_horizon) {
  start_idx <- janela_inicial + i - 1000  # Ajuste para garantir o intervalo correto
  end_idx <- janela_inicial + i - 1
  janela <- log.retornos$Retornos[start_idx:end_idx]  # Usando 'log.retornos$Retornos'
  
  fit <- ugarchfit(spec = spec, data = janela, solver = "hybrid")
  forecast <- ugarchforecast(fit, n.ahead = 1)
  
  sigma <- sigma(forecast)  # Volatilidade condicional
  mu <- fitted(forecast)    # Média ajustada
  
  # Para o VaR de 1%, usamos a quantil da distribuição t-Student
  VaR_pred[i] <- mu - qt(0.99, df = fit@fit$coef["shape"]) * sigma
}

# Número de violações do VaR
violations <- sum(obs < VaR_pred)  
proportion_violations <- violations / forecast_horizon

cat("Proporção de violações do VaR:", proportion_violations, "\n")


