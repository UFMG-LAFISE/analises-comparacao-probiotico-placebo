## MODELO LINEAR MISTO - FLANKER
## (Acuracia_percentual, TR, Acuracia_cong, Acuracia_incong, Acuracia_troca,
##  Acuracia_semtroca, TR_cong, TR_incong, TR_Troca, TR_Sem_Troca)
#-------------------------------------------------------------------------------
library(readr)
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
arquivo <- "dados/resultados-flanker-brutos.csv"

dados_brutos <- read_csv(arquivo, show_col_types = FALSE)

## GRUPO: a coluna "Grupo" do arquivo bruto vem codificada como A/B (cegamento).
## Cruzando "Sujeito" (mesma numeracao de participante usada nas demais
## planilhas do estudo) com a lista conhecida PLA = {1,4,6,8,9,12,13,16,18,20}
## e SUPL = {2,3,5,7,10,11,14,15,19}, confirma-se que Grupo A = SUPL e
## Grupo B = PLA para os 19 participantes.
n_check <- dados_brutos |> distinct(Sujeito, Grupo) |> count(Grupo)
stopifnot(n_check$n[n_check$Grupo == "B"] == 10)
stopifnot(n_check$n[n_check$Grupo == "A"] == 9)

## ORGANIZAÇÃO DOS DADOS
## Suplementacao = pre/pos periodo de intervencao (equivalente ao fator Tempo
## das demais analises). Momento = pre/pos corrida de 10 km.
dados <- dados_brutos |>
  mutate(
    Grupo = case_when(
      Grupo == "A" ~ "SUPL",
      Grupo == "B" ~ "PLA"
    ),
    Grupo        = factor(Grupo, levels = c("PLA", "SUPL")),
    Tempo        = factor(Suplementacao, levels = c("pre", "pos"), labels = c("Pre", "Pos")),
    Momento      = factor(Momento, levels = c("pre", "pos"), labels = c("Pre", "Pos")),
    Participante = factor(Sujeito)
  )

## FUNÇÃO AUXILIAR: RODA O MODELO E IMPRIME TODAS AS SAÍDAS
## nome_variavel = rótulo legível usado nos títulos dos gráficos
## slug          = versão curta sem espaços usada nos nomes dos arquivos .png
rodar_analise <- function(coluna, nome_variavel, slug) {

  dados_var <- dados |>
    rename(Valor = all_of(coluna))

  # MODELO LINEAR MISTO

  modelo <- lmer(
    Valor ~ Grupo * Momento * Tempo +
      (1 | Participante),
    data = dados_var
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
## ACURÁCIA (%)
#-------------------------------------------------------------------------------
modelo_acuracia <- rodar_analise(
  coluna        = "Acuracia_percentual",
  nome_variavel = "Flanker - Acuracia (%)",
  slug          = "flanker-acuracia"
)

#-------------------------------------------------------------------------------
## TEMPO DE REAÇÃO (TR, ms)
#-------------------------------------------------------------------------------
modelo_tr <- rodar_analise(
  coluna        = "TR",
  nome_variavel = "Flanker - Tempo de Reacao (ms)",
  slug          = "flanker-tr"
)

#-------------------------------------------------------------------------------
## ACURÁCIA POR CONDIÇÃO (congruente / incongruente / troca / sem troca)
#-------------------------------------------------------------------------------
modelo_acuracia_cong <- rodar_analise(
  coluna        = "Acuracia_cong",
  nome_variavel = "Flanker - Acuracia Congruente (%)",
  slug          = "flanker-acuracia-cong"
)

modelo_acuracia_incong <- rodar_analise(
  coluna        = "Acuracia_incong",
  nome_variavel = "Flanker - Acuracia Incongruente (%)",
  slug          = "flanker-acuracia-incong"
)

modelo_acuracia_troca <- rodar_analise(
  coluna        = "Acuracia_troca",
  nome_variavel = "Flanker - Acuracia com Troca (%)",
  slug          = "flanker-acuracia-troca"
)

modelo_acuracia_semtroca <- rodar_analise(
  coluna        = "Acuracia_semtroca",
  nome_variavel = "Flanker - Acuracia sem Troca (%)",
  slug          = "flanker-acuracia-semtroca"
)

#-------------------------------------------------------------------------------
## TEMPO DE REAÇÃO POR CONDIÇÃO (congruente / incongruente / troca / sem troca)
#-------------------------------------------------------------------------------
modelo_tr_cong <- rodar_analise(
  coluna        = "TR_cong",
  nome_variavel = "Flanker - TR Congruente (ms)",
  slug          = "flanker-tr-cong"
)

modelo_tr_incong <- rodar_analise(
  coluna        = "TR_incong",
  nome_variavel = "Flanker - TR Incongruente (ms)",
  slug          = "flanker-tr-incong"
)

modelo_tr_troca <- rodar_analise(
  coluna        = "TR_Troca",
  nome_variavel = "Flanker - TR com Troca (ms)",
  slug          = "flanker-tr-troca"
)

modelo_tr_semtroca <- rodar_analise(
  coluna        = "TR_Sem_Troca",
  nome_variavel = "Flanker - TR sem Troca (ms)",
  slug          = "flanker-tr-semtroca"
)
