## MODELO LINEAR MISTO - EQUILIBRIO ELETROLITICO 2
## (D massa corporal (kg), D massa corporal (%), liquido ingerido,
##  sudorese total, taxa de sudorese)
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
arquivo <- "dados/equilibrio-eletrolitico.xlsx"

# LEITURA DAS PLANILHAS
pla_pre  <- read_excel(arquivo, sheet = "PLA-preintervencao")
pla_pos  <- read_excel(arquivo, sheet = "PLA-posintervencao")
supl_pre <- read_excel(arquivo, sheet = "SUPL-preintervencao")
supl_pos <- read_excel(arquivo, sheet = "SUPL-posintervencao")

## ORGANIZAÇÃO DOS DADOS
## Cada variável aqui ocupa uma única linha por aba (não tem par pré/pós
## dentro da aba, como em massa corporal/GEU/coloração da urina). Por isso:
##   - Grupo   = PLA / SUPL -> qual conjunto de abas
##   - Momento = Pre / Pos  -> qual aba (preintervencao / posintervencao)
## Não há fator Tempo nesta análise (2 fatores: Grupo x Momento).
organizar <- function(df, rotulo_variavel, grupo, momento) {

  names(df)[1] <- "Variavel"

  df |>
    filter(Variavel == rotulo_variavel) |>
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

## FUNÇÃO AUXILIAR: MONTA "dados", RODA O MODELO E IMPRIME TODAS AS SAÍDAS
## nome_variavel = rótulo legível usado nos títulos dos gráficos
## slug          = versão curta sem espaços usada nos nomes dos arquivos .png
rodar_analise <- function(rotulo_variavel, nome_variavel, slug) {

  dados <- bind_rows(
    organizar(pla_pre , rotulo_variavel, "PLA" , "Pre"),
    organizar(pla_pos , rotulo_variavel, "PLA" , "Pos"),
    organizar(supl_pre, rotulo_variavel, "SUPL", "Pre"),
    organizar(supl_pos, rotulo_variavel, "SUPL", "Pos")
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
    ~ Grupo * Momento
  )
  print(emm)

  # PRÉ vs PÓS DENTRO DE CADA GRUPO
  emm_momento <- emmeans(
    modelo,
    ~ Momento | Grupo,
    weights = "equal"
  )
  print(pairs(emm_momento, adjust = "holm"))

  # PLA vs SUPL EM CADA MOMENTO
  emm_grupo <- emmeans(
    modelo,
    ~ Grupo | Momento,
    weights = "equal"
  )
  print(pairs(emm_grupo, adjust = "holm"))

  # GRÁFICO DAS MÉDIAS AJUSTADAS

  grafico_grupo_momento <-
    emmip(modelo, Grupo ~ Momento, CIs = TRUE) +
    labs(
      title = nome_variavel,
      subtitle = "Grupo x Momento (pre/pos intervencao)"
    )
  print(grafico_grupo_momento)
  ggsave(paste0("grafico-", slug, "-grupo-por-momento.png"), plot = grafico_grupo_momento, width = 8, height = 6)

  modelo
}

#-------------------------------------------------------------------------------
## D MASSA CORPORAL (kg)
#-------------------------------------------------------------------------------
modelo_d_massa_corporal_kg <- rodar_analise(
  rotulo_variavel = "D massa corporal (kg)",
  nome_variavel   = "D Massa Corporal (kg)",
  slug            = "d-massa-corporal-kg"
)

#-------------------------------------------------------------------------------
## D MASSA CORPORAL (%)
#-------------------------------------------------------------------------------
modelo_d_massa_corporal_pct <- rodar_analise(
  rotulo_variavel = "D massa corporal (%)",
  nome_variavel   = "D Massa Corporal (%)",
  slug            = "d-massa-corporal-pct"
)

#-------------------------------------------------------------------------------
## LÍQUIDO INGERIDO (mL)
#-------------------------------------------------------------------------------
modelo_liquido_ingerido <- rodar_analise(
  rotulo_variavel = "Líquido ingerido (mL)",
  nome_variavel   = "Liquido Ingerido (mL)",
  slug            = "liquido-ingerido"
)

#-------------------------------------------------------------------------------
## SUDORESE TOTAL (mL)
#-------------------------------------------------------------------------------
modelo_sudorese_total <- rodar_analise(
  rotulo_variavel = "Sudorese total (mL)",
  nome_variavel   = "Sudorese Total (mL)",
  slug            = "sudorese-total"
)

#-------------------------------------------------------------------------------
## TAXA DE SUDORESE (mL/min)
#-------------------------------------------------------------------------------
modelo_taxa_sudorese <- rodar_analise(
  rotulo_variavel = "Taxa de sudorese (mL/min)",
  nome_variavel   = "Taxa de Sudorese (mL/min)",
  slug            = "taxa-sudorese"
)
