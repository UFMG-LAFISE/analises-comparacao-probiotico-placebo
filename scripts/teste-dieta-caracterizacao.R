## MODELO LINEAR MISTO - CARACTERIZACAO DA DIETA
## (Proteinas g/%, Carboidratos g/%, Lipideos g/%, Consumo energetico kcal)
#-------------------------------------------------------------------------------
library(readxl)
library(dplyr)
library(tidyr)
library(lme4)
library(lmerTest)
library(emmeans)
library(performance)
library(ggplot2)
library(see)
library(patchwork)
#-------------------------------------------------------------------------------
arquivo <- "dados/dieta-caracterizacao.xlsx"

# LEITURA DAS PLANILHAS
pla_pre  <- read_excel(arquivo, sheet = "PLA-preintervencao")
pla_pos  <- read_excel(arquivo, sheet = "PLA-posintervencao")
supl_pre <- read_excel(arquivo, sheet = "SUPL-preintervencao")
supl_pos <- read_excel(arquivo, sheet = "SUPL-posintervencao")

## ORGANIZAÇÃO DOS DADOS
## Cada variável ocupa uma única linha por aba (sem par pré/pós corrida dentro
## da aba). Por isso, mesmo padrão de equilibrio-eletrolitico2/caracterizacao-amostra:
##   - Grupo   = PLA / SUPL -> qual conjunto de abas
##   - Momento = Pre / Pos  -> qual aba (preintervencao / posintervencao)
## Não há fator Tempo nesta análise (2 fatores: Grupo x Momento).
##
## obs.: a linha de "Lipídeos %" vem grafada como "Lipídeos %" nas abas PLA e
## como "Lipídeos (g)%" nas abas SUPL — os dois rótulos ficam listados no
## argumento rotulo_variavel para o filtro funcionar independente da aba.
organizar <- function(df, rotulo_variavel, grupo, momento) {

  names(df)[1] <- "Variavel"

  df |>
    filter(Variavel %in% rotulo_variavel) |>
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
  # (dados com NA - participante10 e participante11 do SUPL nao tem coleta no
  # pos-intervencao - sao descartados automaticamente pelo lmer)

  modelo <- lmer(
    Valor ~ Grupo * Momento +
      (1 | Participante),
    data = dados
  )
  # NOTA: usar coef(summary()) + VarCorr() em vez de print(summary(modelo))
  # diretamente porque este ambiente tem um bug conhecido no lme4
  # (print.VarCorr.merMod -> formatVC -> format_sdvar não encontra "%||%").
  cat("\n=== Efeitos fixos ===\n")
  print(coef(summary(modelo)))
  cat("\n=== Efeitos aleatorios (variancia) ===\n")
  print(as.data.frame(VarCorr(modelo)))

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
## PROTEÍNAS
#-------------------------------------------------------------------------------
modelo_proteinas_g <- rodar_analise(
  rotulo_variavel = "Proteínas (g)",
  nome_variavel   = "Proteinas (g)",
  slug            = "dieta-proteinas-g"
)

modelo_proteinas_pct <- rodar_analise(
  rotulo_variavel = "Proteínas %",
  nome_variavel   = "Proteinas (%)",
  slug            = "dieta-proteinas-pct"
)

#-------------------------------------------------------------------------------
## CARBOIDRATOS
#-------------------------------------------------------------------------------
modelo_carboidratos_g <- rodar_analise(
  rotulo_variavel = "Cardoidratos (g)",
  nome_variavel   = "Carboidratos (g)",
  slug            = "dieta-carboidratos-g"
)

modelo_carboidratos_pct <- rodar_analise(
  rotulo_variavel = "Cardoidratos %",
  nome_variavel   = "Carboidratos (%)",
  slug            = "dieta-carboidratos-pct"
)

#-------------------------------------------------------------------------------
## LIPÍDEOS
#-------------------------------------------------------------------------------
modelo_lipideos_g <- rodar_analise(
  rotulo_variavel = "Lipídeos (g)",
  nome_variavel   = "Lipideos (g)",
  slug            = "dieta-lipideos-g"
)

modelo_lipideos_pct <- rodar_analise(
  rotulo_variavel = c("Lipídeos %", "Lipídeos (g)%"),
  nome_variavel   = "Lipideos (%)",
  slug            = "dieta-lipideos-pct"
)

#-------------------------------------------------------------------------------
## CONSUMO ENERGÉTICO (kcal)
#-------------------------------------------------------------------------------
modelo_consumo_energetico <- rodar_analise(
  rotulo_variavel = "Consumo energético (kcal)",
  nome_variavel   = "Consumo Energetico (kcal)",
  slug            = "dieta-consumo-energetico"
)
