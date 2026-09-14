## MODELO LINEAR MISTO - TEMPO TOTAL PARA COMPLETAR OS 10 KM
#-------------------------------------------------------------------------------
library(readxl)
library(dplyr)
library(tidyr)
library(afex)
library(lme4)
library(lmerTest)
library(emmeans)
library(performance)
library(ggplot2)
library(see)
library(patchwork)
#-------------------------------------------------------------------------------
arquivo <- "dados/tempo-total-10km.xlsx"

# LEITURA DAS PLANILHAS
# obs.: a aba pós-intervenção do PLA esta grafada "PLA-posintervecao" (sem o "n")
pla_pre  <- read_excel(arquivo, sheet = "PLA-preintervencao")
pla_pos  <- read_excel(arquivo, sheet = "PLA-posintervecao")
supl_pre <- read_excel(arquivo, sheet = "SUPL-preintervencao")
supl_pos <- read_excel(arquivo, sheet = "SUPL-posintervencao")

## ORGANIZAÇÃO DOS DADOS
## Cada aba tem uma unica linha ("10 km") com um valor por participante.
## Cada participante correu os 10 km duas vezes (pre e pos intervencao), por
## isso o desenho e Grupo x Momento (repetido), sem fator Tempo.
organizar <- function(df, grupo, momento) {

  names(df)[1] <- "Variavel"

  df |>
    select(-Variavel) |>
    pivot_longer(
      everything(),
      names_to = "Participante",
      values_to = "Valor"
    ) |>
    mutate(
      Grupo = grupo,
      Momento = momento
    )

}

dados <-

  bind_rows(

    organizar(pla_pre , "PLA" , "Pre"),
    organizar(pla_pos , "PLA" , "Pos"),
    organizar(supl_pre, "SUPL", "Pre"),
    organizar(supl_pos, "SUPL", "Pos")

  )

## AJUSTES
dados$Grupo <- factor(dados$Grupo)

dados$Momento <- factor(
  dados$Momento,
  levels = c("Pre", "Pos")
)

dados$Participante <- factor(dados$Participante)

# MODELO LINEAR MISTO

modelo <- lmer(

  Valor ~ Grupo * Momento +

    (1 | Participante),

  data = dados

)
summary(modelo)

grafico_pressupostos <-
  plot(check_model(modelo)) +
  patchwork::plot_annotation(title = "Tempo Total 10 km (min)")

ggsave("pressupostos-modelo-tempo-total-10km.png", plot = grafico_pressupostos, width = 10, height = 8)

anova(modelo)

# MÉDIAS AJUSTADAS

emm <- emmeans(
  modelo,
  ~ Grupo * Momento
)
emm

# PRÉ vs PÓS DENTRO DE CADA GRUPO
emm_momento <- emmeans(
  modelo,
  ~ Momento | Grupo,
  weights = "equal"
)

pairs(
  emm_momento,
  adjust = "holm"
)

# PLA vs SUPL EM CADA MOMENTO
emm_grupo <- emmeans(
  modelo,
  ~ Grupo | Momento,
  weights = "equal"
)

pairs(
  emm_grupo,
  adjust = "holm"
)

# GRÁFICO DAS MÉDIAS AJUSTADAS

grafico_grupo_momento <-
  emmip(modelo, Grupo ~ Momento, CIs = TRUE) +
  labs(
    title = "Tempo Total 10 km (min)",
    subtitle = "Grupo x Momento (pre/pos intervencao)"
  )
grafico_grupo_momento
ggsave("grafico-tempo-total-10km-grupo-por-momento.png", plot = grafico_grupo_momento, width = 8, height = 6)
