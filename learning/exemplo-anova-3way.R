## EXEMPLO DIDATICO - MODELO LINEAR MISTO COMO ALTERNATIVA A UMA ANOVA DE 3 VIAS
## (fatores Grupo, Momento e Tempo)
##
## Este script usa dados FICTICIOS, criados dentro do proprio script, so para
## ensinar a estrutura de analise usada neste laboratorio. Ele nao le nenhum
## arquivo da pasta dados/ deste repositorio e pode ser rodado sozinho, de
## qualquer lugar, sem depender do resto do projeto.

## PACOTES NECESSARIOS ---------------------------------------------------------

# dplyr e tidyr: organizar e transformar tabelas de dados (juntar, empilhar,
# criar colunas novas)
library(dplyr)
library(tidyr)

# lme4: pacote que ajusta o modelo linear misto propriamente dito, atraves
# da funcao lmer()
library(lme4)

# lmerTest: adiciona ao lme4 o calculo dos valores de p dos efeitos fixos
# (sem este pacote, o lme4 sozinho mostra os coeficientes mas nao os p)
library(lmerTest)

# emmeans: calcula as medias ajustadas pelo modelo (estimated marginal
# means) e as comparacoes par a par entre grupos/momentos/tempos (o
# "post-hoc")
library(emmeans)

# performance: fornece a funcao check_model(), usada para verificar
# visualmente se os pressupostos do modelo estao razoavelmente atendidos
library(performance)

# ggplot2, see e patchwork: pacotes de graficos usados por baixo dos panos
# pelo check_model() e pelo emmip() (grafico das medias ajustadas)
library(ggplot2)
library(see)
library(patchwork)


#-------------------------------------------------------------------------------
## 1. CRIAR DADOS FICTICIOS
## Em uma analise real, esta secao seria substituida pela leitura de uma
## planilha de verdade, do jeito que e feito nos scripts da pasta scripts/
## deste repositorio. Aqui geramos os dados na mao, para o script funcionar
## sozinho sem depender de nenhum arquivo externo.

# fixa a "semente" do gerador de numeros aleatorios do R, so para este
# exemplo ser reproduzivel; nao e algo que voce precisa fazer ao analisar
# dados reais que ja existem
set.seed(123)

# numero de participantes em cada grupo, propositalmente diferente entre os
# grupos, porque um dos motivos de usar modelo misto em vez de ANOVA
# classica e justamente lidar bem com grupos de tamanhos diferentes
n_grupo_a <- 12
n_grupo_b <- 10

# identificador unico de texto para cada participante ("P1", "P2", ...)
participantes <- paste0("P", seq_len(n_grupo_a + n_grupo_b))

# vetor de grupo correspondente a cada participante
grupo <- c(rep("A", n_grupo_a), rep("B", n_grupo_b))

# tabela com uma linha por participante, contendo so o identificador e o
# grupo de cada um
dados_participantes <- data.frame(
  Participante = participantes,
  Grupo = grupo
)

# niveis do terceiro fator, Tempo. Aqui usamos so 2 niveis para simplificar
# a leitura do exemplo, mas poderia ser qualquer numero de niveis (por
# exemplo, c("Tempo1", "Tempo2", ..., "Tempo10") para representar 10
# trechos de um percurso)
niveis_tempo <- c("Pre", "Pos")

# cada participante tem 4 medidas no total: uma para cada combinacao de
# Momento (Pre/Pos) e Tempo (Pre/Pos). Para simular isso, cruzamos a tabela
# de participantes com todas as combinacoes de Momento e Tempo, usando
# expand_grid() (do pacote tidyr) e depois juntando com os dados dos
# participantes atraves de um "full join" implicito via merge de colunas
combinacoes_momento_tempo <- expand_grid(
  Momento = c("Pre", "Pos"),
  Tempo = niveis_tempo
)

# left_join() com relationship = "many-to-many" cruza cada participante com
# cada uma das combinacoes de Momento e Tempo, gerando uma linha para cada
# combinacao de participante x Momento x Tempo
dados <- dados_participantes |>
  left_join(combinacoes_momento_tempo, by = character(), relationship = "many-to-many")
# by = character() faz um "cross join" (produto cartesiano): junta cada
# linha de dados_participantes com cada linha de combinacoes_momento_tempo,
# sem exigir nenhuma coluna em comum entre as duas tabelas

# gera a variavel de desfecho (o "Valor" que estamos medindo) de forma
# ficticia, somando: uma media geral, um efeito de grupo, um efeito de
# momento, um efeito de tempo, um efeito de interacao entre grupo e
# momento, e ruido aleatorio. Essa formula so existe aqui porque estamos
# inventando os dados; com dados reais voce nunca escreve uma formula
# assim, voce so le os valores medidos
dados <- dados |>
  mutate(
    Valor =
      50 +                                               # media geral de referencia
      ifelse(Grupo == "B", 5, 0) +                        # grupo B comeca, em media, um pouco mais alto
      ifelse(Momento == "Pos", -3, 0) +                   # todo mundo cai um pouco do Pre para o Pos (10 km)
      ifelse(Tempo == "Pos", -2, 0) +                     # todo mundo cai um pouco do Pre para o Pos (intervencao)
      ifelse(Grupo == "B" & Momento == "Pos", -6, 0) +    # grupo B cai mais ainda no Pos, dentro do 10 km (interacao Grupo:Momento)
      rnorm(n(), mean = 0, sd = 4)                        # ruido aleatorio (variacao individual em torno da media)
  )


#-------------------------------------------------------------------------------
## 2. AJUSTAR OS TIPOS DAS COLUNAS (TRANSFORMAR EM FATORES)
## O R precisa saber que Grupo, Momento, Tempo e Participante sao variaveis
## categoricas (fatores), e nao texto livre ou numeros continuos, para o
## lmer() e o emmeans() interpretarem a formula corretamente.

# Grupo como fator, com "A" como categoria de referencia
dados$Grupo <- factor(dados$Grupo, levels = c("A", "B"))

# Momento como fator, com "Pre" como referencia e "Pos" comparado contra ela
dados$Momento <- factor(dados$Momento, levels = c("Pre", "Pos"))

# Tempo como fator. Se os seus dados tiverem mais de 2 niveis de Tempo (por
# exemplo, varios trechos de um percurso), liste todos os niveis aqui, na
# ordem que fizer sentido (por exemplo, c("0-1km", "1-2km", ..., "9-10km")) # se não entendeu, veja as analises que foram feitos para o trabalho da barbara, lá eu usei essa estrutura explicada
dados$Tempo <- factor(dados$Tempo, levels = niveis_tempo)

# Participante como fator, so para o lmer() reconhecer como um agrupamento
# (efeito aleatorio), e nao como um numero comum. A ordem dos niveis aqui
# nao importa
dados$Participante <- factor(dados$Participante)


#-------------------------------------------------------------------------------
## 3. AJUSTAR O MODELO LINEAR MISTO

modelo <- lmer(
  Valor ~ Grupo * Momento * Tempo + (1 | Participante),
  data = dados
)
# como ler a formula acima:
#   Valor ~ Grupo * Momento * Tempo
#     "explique o Valor pelos tres fatores (Grupo, Momento, Tempo) e por
#     todas as interacoes possiveis entre eles".
#   + (1 | Participante)
#     "cada Participante tem o seu proprio ponto de partida (intercepto)".
#     Isto modela o fato de que a mesma pessoa foi medida 4 vezes (uma para
#     cada combinacao de Momento e Tempo), entao essas medidas nao sao
#     estatisticamente independentes entre si, elas vem da mesma pessoa

# imprime a tabela de efeitos fixos (os coeficientes estimados pelo
# modelo). Usamos coef(summary(modelo)) em vez de so summary(modelo) porque
# algumas instalacoes do pacote lme4 tem um problema conhecido ao formatar
# a parte de efeitos aleatorios dentro de summary(); coef(summary(modelo))
# evita esse trecho e mostra direto a tabela de coeficientes
cat("\n=== Efeitos fixos (coeficientes do modelo) ===\n")
print(coef(summary(modelo)))

# imprime os efeitos aleatorios 
cat("\n=== Efeitos aleatorios (variancia entre participantes e residuo) ===\n")
print(as.data.frame(VarCorr(modelo)))


#-------------------------------------------------------------------------------
## 4. VERIFICAR OS PRESSUPOSTOS DO MODELO
## Antes de interpretar os resultados, vale checar visualmente se o modelo
## esta bem ajustado: residuos aproximadamente normais, variancia
## homogenea entre os grupos, nenhuma observacao com influencia
## desproporcional sobre o resultado, e assim por diante.

check_model(modelo)
# este comando abre uma janela com um painel de graficos de diagnostico.
# Se voce quiser salvar esse painel em um arquivo em vez de so exibi-lo na
# tela, use ggsave() como e feito nos scripts da pasta scripts/ deste
# repositorio, por exemplo:
#   grafico_pressupostos <- plot(check_model(modelo))
#   ggsave("meus-pressupostos.png", plot = grafico_pressupostos, width = 10, height = 8)


#-------------------------------------------------------------------------------
## 5. TABELA DE ANOVA (TESTE DE SIGNIFICANCIA DOS EFEITOS) 
## Esta e a etapa que corresponde a "fazer a ANOVA": pegamos o modelo misto
## ja ajustado e testamos se cada efeito e estatisticamente significativo.
## Usamos soma de quadrados Tipo III (padrao quando o desenho tem
## interacoes) e a aproximacao de Satterthwaite para os graus de liberdade,
## que funciona melhor que a aproximacao classica quando os grupos sao
## desbalanceados, como e o caso aqui de proposito.

cat("\n=== ANOVA (Tipo III, aproximacao de Satterthwaite) ===\n")
print(anova(modelo))

# como ler a tabela de ANOVA, linha por linha:
#   Grupo               -> o grupo A difere do grupo B, em media, ignorando Momento e Tempo?
#   Momento              -> o momento Pre difere do momento Pos, em media, ignorando Grupo e Tempo?
#   Tempo                -> o Tempo Pre difere do Tempo Pos, em media, ignorando Grupo e Momento?
#   Grupo:Momento        -> o efeito do Momento e diferente dependendo do Grupo?
#   Grupo:Tempo          -> o efeito do Tempo e diferente dependendo do Grupo?
#   Momento:Tempo        -> o efeito do Tempo e diferente dependendo do Momento?
#   Grupo:Momento:Tempo  -> a propria interacao Grupo:Momento muda de forma dependendo do Tempo
#                           (ou, de forma equivalente, a interacao Grupo:Tempo muda dependendo
#                           do Momento)
#
# se alguma interacao for significativa (valor de p menor que 0,05), nao
# faz sentido interpretar isoladamente os efeitos principais ou as
# interacoes de ordem mais baixa que a compoem; e preciso decompor a
# interacao significativa, o que fazemos na proxima secao


#-------------------------------------------------------------------------------
## 6. MEDIAS AJUSTADAS E COMPARACOES POST-HOC (EMMEANS)
## emmeans calcula as "estimated marginal means": as medias previstas pelo
## modelo para cada combinacao de Grupo, Momento e Tempo, ja levando em
## conta toda a estrutura do modelo misto.

medias_ajustadas <- emmeans(modelo, ~ Grupo * Momento * Tempo)
cat("\n=== Medias ajustadas por Grupo, Momento e Tempo ===\n")
print(medias_ajustadas)

# regra importante sobre quando fazer comparacoes post-hoc: so faz sentido
# reportar comparacoes par a par quando a interacao correspondente deu
# significativa na ANOVA da secao 5. Decompor uma interacao que nao e
# significativa infla a taxa de erro Tipo I, ou seja, aumenta a chance de
# "encontrar" uma diferenca que na verdade e so ruido estatistico. As tres
# comparacoes abaixo seguem o mesmo padrao usado nos scripts da pasta
# scripts/ deste repositorio.

# comparacao 1: Pre vs Pos (Momento), dentro de cada Grupo separadamente.
# So faz sentido reportar isto se Grupo:Momento deu significativo
comparacao_momento_por_grupo <- emmeans(modelo, ~ Momento | Grupo, weights = "equal")
cat("\n=== Momento (Pre vs Pos), dentro de cada Grupo ===\n")
print(pairs(comparacao_momento_por_grupo, adjust = "holm"))
# adjust = "holm" corrige os valores de p para o fato de estarmos fazendo
# mais de uma comparacao na mesma analise, evitando inflar a taxa de erro
# Tipo I (metodo de Holm, um pouco menos conservador que o de Bonferroni) 
# para mudar isso é so mudar dentro da função

# comparacao 2: Grupo A vs Grupo B, dentro de cada Momento separadamente.
# So faz sentido reportar isto se Grupo:Momento deu significativo
comparacao_grupo_por_momento <- emmeans(modelo, ~ Grupo | Momento, weights = "equal")
cat("\n=== Grupo (A vs B), dentro de cada Momento ===\n")
print(pairs(comparacao_grupo_por_momento, adjust = "holm"))

# comparacao 3: Grupo A vs Grupo B, dentro de cada Tempo separadamente. So
# faz sentido reportar isto se Grupo:Tempo (ou a interacao tripla) deu
# significativo
comparacao_grupo_por_tempo <- emmeans(modelo, ~ Grupo | Tempo, weights = "equal")
cat("\n=== Grupo (A vs B), dentro de cada Tempo ===\n")
print(pairs(comparacao_grupo_por_tempo, adjust = "holm"))


#-------------------------------------------------------------------------------
## 7. GRAFICOS DAS MEDIAS AJUSTADAS
## emmip() desenha as medias ajustadas com barras de erro (intervalo de
## confianca de 95%). Com 3 fatores, geralmente e util olhar mais de uma
## combinacao de eixos para entender a interacao tripla.

grafico_grupo_tempo_por_momento <- emmip(modelo, Grupo ~ Tempo | Momento, CIs = TRUE) +
  labs(
    title = "Exemplo didatico de 3 vias: Grupo x Tempo, por Momento",
    subtitle = "Medias ajustadas pelo modelo, com intervalo de confianca de 95%"
  )
print(grafico_grupo_tempo_por_momento)

grafico_momento_tempo_por_grupo <- emmip(modelo, Momento ~ Tempo | Grupo, CIs = TRUE) +
  labs(
    title = "Exemplo didatico de 3 vias: Momento x Tempo, por Grupo",
    subtitle = "Medias ajustadas pelo modelo, com intervalo de confianca de 95%"
  )
print(grafico_momento_tempo_por_grupo)

# para salvar os graficos em arquivo em vez de so exibi-los na tela, use
# ggsave(), do mesmo jeito que e feito nos scripts da pasta scripts/ deste
# repositorio:
#   ggsave("meu-grafico.png", plot = grafico_grupo_tempo_por_momento, width = 8, height = 6)


#-------------------------------------------------------------------------------
## PARA ADAPTAR ESTE SCRIPT PARA OS SEUS PROPRIOS DADOS 
## 1. Troque a secao 1 (dados ficticios) por uma leitura de dados real, por
##    exemplo:
##      dados <- readxl::read_excel("dados/minha-planilha.xlsx")
##    garantindo que a tabela final tenha uma linha por participante por
##    combinacao de Momento e Tempo, com colunas Participante, Grupo,
##    Momento, Tempo e a variavel de desfecho que voce quer analisar.
## 2. Troque o nome "Valor" pelo nome real da sua coluna de desfecho em
##    todas as formulas (lmer, emmeans) e nos textos dentro dos cat().
## 3. Se os nomes das suas categorias forem diferentes de "A"/"B",
##    "Pre"/"Pos" (Momento) ou "Pre"/"Pos" (Tempo), ajuste os
##    levels = c(...) na secao 2 para os nomes reais das suas categorias,
##    na ordem que voce quer usar como referencia.
## 4. Se o seu fator Tempo tiver mais de 2 niveis (por exemplo, 10 trechos
##    de um percurso), so precisa listar todos os niveis em niveis_tempo,
##    na secao 1, e em levels = c(...) na secao 2; o resto do script
##    continua funcionando do mesmo jeito, so a tabela de resultados fica
##    maior.
## 5. Se os seus dados nao tiverem essa terceira dimensao (cada
##    participante so tem uma medida por Momento, sem repeticao dentro
##    dele), este desenho de 3 vias e desnecessario: veja o exemplo mais
##    simples em exemplo-anova-2way.R, na mesma pasta.
