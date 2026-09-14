## MODELO LINEAR MISTO - EQUILIBRIO ELETROLITICO
## (massa corporal, GEU, coloracao da urina)
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
arquivo <- "equilibrio-eletrolitico.xlsx"

# LEITURA DAS PLANILHAS
pla_pre  <- read_excel(arquivo, sheet = "PLA-preintervencao")
pla_pos  <- read_excel(arquivo, sheet = "PLA-posintervencao")
supl_pre <- read_excel(arquivo, sheet = "SUPL-preintervencao")
supl_pos <- read_excel(arquivo, sheet = "SUPL-posintervencao")

## ORGANIZAÇÃO DOS DADOS
## Nesta planilha (diferente das demais), cada aba ja contem as linhas
## "pre" e "pos" da corrida de 10 km na coluna 1. Por isso, aqui:
##   - Grupo   = PLA / SUPL            -> qual conjunto de abas
##   - Tempo   = Pre / Pos intervencao -> qual aba (preintervencao / posintervencao)
##   - Momento = Pre / Pos 10 km       -> qual linha dentro da aba
organizar <- function(df, rotulos_pre, rotulos_pos, grupo, tempo) {

  names(df)[1] <- "Variavel"

  df |>
    filter(Variavel %in% c(rotulos_pre, rotulos_pos)) |>
    mutate(Momento = if_else(Variavel %in% rotulos_pre, "Pre", "Pos")) |>
    select(-Variavel) |>
    pivot_longer(
      -Momento,
      names_to = "Participante",
      values_to = "Valor"
    ) |>
    mutate(
      Grupo = grupo,
      Tempo = tempo
    )

}

## FUNÇÃO AUXILIAR: MONTA "dados", RODA O MODELO E IMPRIME TODAS AS SAÍDAS
## nome_variavel = rótulo legível usado nos títulos dos gráficos (ex.: "Massa Corporal (kg)")
## slug          = versão curta sem espaços usada nos nomes dos arquivos .png (ex.: "massa-corporal")
rodar_analise <- function(rotulos_pre, rotulos_pos, nome_variavel, slug) {

  dados <- bind_rows(
    organizar(pla_pre , rotulos_pre, rotulos_pos, "PLA" , "Pre"),
    organizar(pla_pos , rotulos_pre, rotulos_pos, "PLA" , "Pos"),
    organizar(supl_pre, rotulos_pre, rotulos_pos, "SUPL", "Pre"),
    organizar(supl_pos, rotulos_pre, rotulos_pos, "SUPL", "Pos")
  )

  ## AJUSTES
  dados$Grupo <- factor(dados$Grupo)

  dados$Momento <- factor(
    dados$Momento,
    levels = c("Pre", "Pos")
  )

  dados$Tempo <- factor(
    dados$Tempo,
    levels = c("Pre", "Pos")
  )

  dados$Participante <- factor(dados$Participante)

  # MODELO LINEAR MISTO

  modelo <- lmer(
    Valor ~ Grupo * Momento * Tempo +
      (1 | Participante),
    data = dados
  )
  print(summary(modelo))

  grafico_pressupostos <-
    plot(check_model(modelo)) +
    patchwork::plot_annotation(title = nome_variavel)

  ggsave(
    paste0("pressupostos-modelo-", slug, ".png"),
    plot = grafico_pressupostos,
    width = 10, height = 8
  )

  print(anova(modelo))

  # MÉDIAS AJUSTADAS

  emm <- emmeans(
    modelo,
    ~ Grupo * Momento * Tempo
  )
  print(emm)

  # PRÉ vs PÓS 10 KM DENTRO DE CADA GRUPO
  emm_momento <- emmeans(
    modelo,
    ~ Momento | Grupo,
    weights = "equal"
  )
  print(pairs(emm_momento, adjust = "holm"))

  # PLA vs SUPL EM CADA MOMENTO (PRÉ/PÓS 10 KM)
  emm_grupo <- emmeans(
    modelo,
    ~ Grupo | Momento,
    weights = "equal"
  )
  print(pairs(emm_grupo, adjust = "holm"))

  ## PLA vs SUPL EM CADA TEMPO (PRÉ/PÓS INTERVENÇÃO)
  emm_tempo <- emmeans(
    modelo,
    ~ Grupo | Tempo,
    weights = "equal"
  )
  print(pairs(emm_tempo, adjust = "holm"))

  # GRÁFICOS DAS MÉDIAS AJUSTADAS

  grafico_grupo_tempo <-
    emmip(modelo, Grupo ~ Tempo | Momento, CIs = TRUE) +
    labs(
      title = nome_variavel,
      subtitle = "Grupo x Tempo de intervencao, por Momento (pre/pos 10 km)"
    )
  print(grafico_grupo_tempo)
  ggsave(paste0("grafico-", slug, "-grupo-tempo-por-momento.png"), plot = grafico_grupo_tempo, width = 8, height = 6)

  grafico_momento_tempo <-
    emmip(modelo, Momento ~ Tempo | Grupo, CIs = TRUE) +
    labs(
      title = nome_variavel,
      subtitle = "Momento (pre/pos 10 km) x Tempo de intervencao, por Grupo"
    )
  print(grafico_momento_tempo)
  ggsave(paste0("grafico-", slug, "-momento-tempo-por-grupo.png"), plot = grafico_momento_tempo, width = 8, height = 6)

  grafico_grupo_momento <-
    emmip(modelo, Grupo ~ Momento, CIs = TRUE) +
    labs(
      title = nome_variavel,
      subtitle = "Grupo x Momento (pre/pos 10 km)"
    )
  print(grafico_grupo_momento)
  ggsave(paste0("grafico-", slug, "-grupo-por-momento.png"), plot = grafico_grupo_momento, width = 8, height = 6)

  modelo
}

#-------------------------------------------------------------------------------
## MASSA CORPORAL
## obs.: a planilha grafa a linha "pre" como "Massa coporal pré (kg)" (sem o r) -
## os dois rótulos ficam listados abaixo para o filtro funcionar mesmo se o
## erro de digitação for corrigido na planilha no futuro.
#-------------------------------------------------------------------------------
modelo_massa_corporal <- rodar_analise(
  rotulos_pre    = c("Massa coporal pré (kg)", "Massa corporal pré (kg)"),
  rotulos_pos    = "Massa corporal pós (kg)",
  nome_variavel  = "Massa Corporal (kg)",
  slug           = "massa-corporal"
)

#-------------------------------------------------------------------------------
## GEU (GRAVIDADE ESPECÍFICA DA URINA)
#-------------------------------------------------------------------------------
modelo_geu <- rodar_analise(
  rotulos_pre    = "GEU pré",
  rotulos_pos    = "GEU pós",
  nome_variavel  = "GEU (Gravidade Especifica da Urina)",
  slug           = "geu"
)

#-------------------------------------------------------------------------------
## COLORAÇÃO DA URINA
#-------------------------------------------------------------------------------
modelo_coloracao_urina <- rodar_analise(
  rotulos_pre    = "Coloração urina pré",
  rotulos_pos    = "Coloração urina pós",
  nome_variavel  = "Coloracao da Urina",
  slug           = "coloracao-urina"
)
