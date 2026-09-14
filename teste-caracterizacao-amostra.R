## TESTE T - CARACTERIZACAO DA AMOSTRA
## (Idade, Massa corporal, Estatura, Gordura corporal, VO2max)
#-------------------------------------------------------------------------------
library(readxl)
library(dplyr)
#-------------------------------------------------------------------------------
arquivo <- "caracterizacao-amostra.xlsx"

# LEITURA DAS PLANILHAS
pla  <- read_excel(arquivo, sheet = "CARACTERIZACAO-AMOSTRA-PLA")
supl <- read_excel(arquivo, sheet = "CARACTERIZACAO-AMOSTRA-SUPL")

## VARIÁVEIS A COMPARAR (teste t independente, PLA vs SUPL)
variaveis <- c(
  "Idade (anos)",
  "Massa corporal (kg)",
  "Estatura (cm)",
  "Gordura corporal (%)",
  "VO2max (mlO2.kg.min)"
)

## TESTE T PARA CADA VARIÁVEL
resumo <- lapply(variaveis, function(v) {

  teste <- t.test(pla[[v]], supl[[v]])

  data.frame(
    Variavel   = v,
    Media_PLA  = mean(pla[[v]],  na.rm = TRUE),
    DP_PLA     = sd(pla[[v]],    na.rm = TRUE),
    n_PLA      = sum(!is.na(pla[[v]])),
    Media_SUPL = mean(supl[[v]], na.rm = TRUE),
    DP_SUPL    = sd(supl[[v]],   na.rm = TRUE),
    n_SUPL     = sum(!is.na(supl[[v]])),
    t          = unname(teste$statistic),
    df         = unname(teste$parameter),
    p          = teste$p.value
  )

})

resumo <- bind_rows(resumo)
print(resumo)

write.csv(resumo, "caracterizacao-amostra-resultado.csv", row.names = FALSE)
