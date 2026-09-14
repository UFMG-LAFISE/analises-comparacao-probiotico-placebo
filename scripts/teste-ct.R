## MODELO LINEAR MISTO - CT
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
#-------------------------------------------------------------------------------
arquivo <- "dados/CT.xlsx"

# LEITURA DAS PLANILHAS
pla_pre  <- read_excel(arquivo, sheet = "PLA-preintervencao")
pla_pos  <- read_excel(arquivo, sheet = "PLA-posintervencao")
supl_pre <- read_excel(arquivo, sheet = "SULP-preintervencao")
supl_pos <- read_excel(arquivo, sheet = "SULP-posintervencao")

## ORGANIZAÇÃO DOS DADOS
organizar <- function(df, grupo, momento){
  
  names(df)[1] <- "Tempo"
  
  df |>
    pivot_longer(
      -Tempo,
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
    
    organizar(pla_pre ,"PLA" ,"Pre"),
    organizar(pla_pos ,"PLA" ,"Pos"),
    organizar(supl_pre,"SUPL","Pre"),
    organizar(supl_pos,"SUPL","Pos")
    
  )

## AJUSTES
dados$Grupo <- factor(dados$Grupo)

dados$Momento <- factor(
  dados$Momento,
  levels = c("Pre","Pos")
)

dados$Participante <- factor(dados$Participante)

dados$Tempo <- factor(
  dados$Tempo,
  levels = c(
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10"
  )
)

# REMOVER TEMPO 0 (BASELINE) DA ANALISE
dados <- dados |> 
  filter(Tempo != '0') |>
  mutate(Tempo = droplevels(Tempo))

# MODELO LINEAR MISTO

modelo <- lmer(
  
  Valor ~ Grupo * Momento * Tempo +
    
    (1 | Participante),
  
  data = dados
  
)
summary(modelo)


ggsave("pressupostos-modelo-ct.png", plot = plot(check_model(modelo)), width = 10, height = 8)

anova(modelo)


# MÉDIAS AJUSTADAS

emm <- emmeans(
  modelo,
  ~ Grupo * Momento * Tempo
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

## PLA vs SUPL EM CADA TRECHO
emm_tempo <- emmeans(
  modelo,
  ~ Grupo | Tempo,
  weights = "equal"
)

pairs(
  emm_tempo,
  adjust = "holm"
)

# GRÁFICOS DAS MÉDIAS AJUSTADAS

emmip(
  modelo,
  Grupo ~ Tempo | Momento,
  CIs = TRUE
)

emmip(
  modelo,
  Momento ~ Tempo | Grupo,
  CIs = TRUE
)

emmip(
  modelo,
  Grupo ~ Momento,
  CIs = TRUE
)