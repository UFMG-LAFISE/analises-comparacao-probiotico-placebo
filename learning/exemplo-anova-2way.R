## EXEMPLO DIDATICO - MODELO LINEAR MISTO COMO ALTERNATIVA A UMA ANOVA DE 2 VIAS
## (fatores Grupo e Momento, sem um terceiro fator)
##
## Este script usa dados FICTICIOS, criados dentro do proprio script, so para
## ensinar a estrutura de analise usada neste laboratorio. Ele nao le nenhum
## arquivo da pasta dados/ deste repositorio e pode ser rodado sozinho, de
## qualquer lugar, sem depender do resto do projeto.
##
## Quando usar este modelo de 2 vias (sem fator Tempo): quando cada
## participante tem uma unica medida por Momento, por exemplo, um valor
## antes da intervencao e um valor depois da intervencao, sem uma terceira
## dimensao repetida dentro do mesmo Momento (como varios trechos de um
## percurso, ou varias tentativas de uma tarefa). Se os seus dados tem essa
## terceira dimensao, veja o exemplo em exemplo-anova-3way.R, na mesma pasta.
#-------------------------------------------------------------------------------


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
# means) e as comparacoes par a par entre grupos/momentos (o "post-hoc")
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
## 1. CRIAR DADOS FICTICIOS -----------------------------------------------------
## Em uma analise real, esta secao seria substituida pela leitura de uma
## planilha de verdade, por exemplo com readxl::read_excel("dados/arquivo.xlsx"),
## do jeito que e feito nos scripts da pasta scripts/ deste repositorio. Aqui
## geramos os dados na mao, para o script funcionar sozinho sem depender de
## nenhum arquivo externo.

# fixa a "semente" do gerador de numeros aleatorios do R: rodando este
# script de novo, os numeros "aleatorios" gerados abaixo serao sempre os
# mesmos. Isso serve so para este exemplo ser reproduzivel; nao e algo que
# voce precisa fazer ao analisar dados reais que ja existem
set.seed(123)

# numero de participantes em cada grupo. Propositalmente diferente entre os
# grupos (12 contra 10), porque um dos motivos de usar modelo misto em vez
# de ANOVA classica e justamente lidar bem com grupos de tamanhos diferentes
n_grupo_a <- 12
n_grupo_b <- 10

# cria um identificador unico de texto para cada participante, por exemplo
# "P1", "P2", ..., ate o numero total de participantes dos dois grupos
participantes <- paste0("P", seq_len(n_grupo_a + n_grupo_b))

# cria o vetor de grupo correspondente: os primeiros n_grupo_a
# participantes sao do grupo "A", os demais sao do grupo "B"
grupo <- c(rep("A", n_grupo_a), rep("B", n_grupo_b))

# monta uma tabela com uma linha por participante, contendo so o
# identificador e o grupo de cada um
dados_participantes <- data.frame(
  Participante = participantes,
  Grupo = grupo
)

# cada participante tem duas medidas, uma no Momento "Pre" e outra no
# Momento "Pos". Para simular isso, duplicamos a tabela de participantes
# (uma copia marcada como "Pre", outra como "Pos") e empilhamos as duas
# tabelas uma embaixo da outra com bind_rows()
dados <- bind_rows(
  dados_participantes |> mutate(Momento = "Pre"),
  dados_participantes |> mutate(Momento = "Pos")
)

# gera a variavel de desfecho (o "Valor" que estamos medindo) de forma
# ficticia, somando: uma media geral, um efeito de grupo, um efeito de
# momento, um efeito de interacao entre grupo e momento, e ruido aleatorio.
# Essa formula so existe aqui porque estamos inventando os dados; com dados
# reais voce nunca escreve uma formula assim, voce so le os valores medidos
dados <- dados |>
  mutate(
    Valor =
      50 +                                               # media geral de referencia
      ifelse(Grupo == "B", 5, 0) +                        # grupo B comeca, em media, um pouco mais alto
      ifelse(Momento == "Pos", -3, 0) +                   # todo mundo cai um pouco do Pre para o Pos
      ifelse(Grupo == "B" & Momento == "Pos", -12, 0) +   # grupo B cai mais ainda no Pos (isto e a interacao)
      rnorm(n(), mean = 0, sd = 4)                        # ruido aleatorio (variacao individual em torno da media)
  )


#-------------------------------------------------------------------------------
## 2. AJUSTAR OS TIPOS DAS COLUNAS (TRANSFORMAR EM FATORES) --------------------
## O R precisa saber que Grupo, Momento e Participante sao variaveis
## categoricas (fatores), e nao texto livre ou numeros continuos, para o
## lmer() e o emmeans() interpretarem a formula corretamente.

# define Grupo como fator, com "A" como categoria de referencia (aparece
# primeiro na lista de levels) e "B" como a categoria comparada contra ela
dados$Grupo <- factor(dados$Grupo, levels = c("A", "B"))

# define Momento como fator, com "Pre" como referencia e "Pos" comparado
# contra ela. A ordem aqui importa para a leitura dos coeficientes do
# modelo mais adiante
dados$Momento <- factor(dados$Momento, levels = c("Pre", "Pos"))

# define Participante como fator. A ordem dos niveis nao importa aqui, o
# fator so precisa existir para o lmer() reconhecer Participante como um
# agrupamento (efeito aleatorio), e nao como um numero comum
dados$Participante <- factor(dados$Participante)


#-------------------------------------------------------------------------------
## 3. AJUSTAR O MODELO LINEAR MISTO ---------------------------------------------
## Por que um modelo misto (LMM) em vez de uma ANOVA de medidas repetidas
## classica? A ANOVA classica exige grupos de tamanho igual e nao aceita
## dados faltantes (qualquer participante com uma medida faltando e
## excluido inteiro da analise). O LMM lida bem com os dois problemas,
## porque estima os efeitos por maxima verossimilhanca, aproveitando toda a
## informacao disponivel, em vez de exigir uma tabela perfeitamente
## retangular e balanceada.

modelo <- lmer(
  Valor ~ Grupo * Momento + (1 | Participante),
  data = dados
)
# como ler a formula acima:
#   Valor ~ Grupo * Momento
#     "explique o Valor pelo Grupo, pelo Momento, e pela interacao entre os
#     dois". Em R, "Grupo * Momento" e um atalho que expande sozinho para
#     "Grupo + Momento + Grupo:Momento" (os dois efeitos principais mais a
#     interacao entre eles)
#   + (1 | Participante)
#     "cada Participante tem o seu proprio ponto de partida (intercepto)".
#     Isto modela o fato de que a mesma pessoa foi medida duas vezes (Pre e
#     Pos), entao essas duas medidas nao sao estatisticamente independentes
#     entre si, elas vem da mesma pessoa

# imprime a tabela de efeitos fixos (os coeficientes estimados pelo
# modelo). Usamos coef(summary(modelo)) em vez de so summary(modelo) porque
# algumas instalacoes do pacote lme4 tem um problema conhecido ao formatar
# a parte de efeitos aleatorios dentro de summary(); coef(summary(modelo))
# evita esse trecho e mostra direto a tabela de coeficientes
cat("\n=== Efeitos fixos (coeficientes do modelo) ===\n")
print(coef(summary(modelo)))

# imprime os efeitos aleatorios (o quanto os participantes variam entre si,
# em media, e o quanto sobra de variancia nao explicada, o residuo)
cat("\n=== Efeitos aleatorios (variancia entre participantes e residuo) ===\n")
print(as.data.frame(VarCorr(modelo)))


#-------------------------------------------------------------------------------
## 4. VERIFICAR OS PRESSUPOSTOS DO MODELO ---------------------------------------
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
## 5. TABELA DE ANOVA (TESTE DE SIGNIFICANCIA DOS EFEITOS) ---------------------
## Esta e a etapa que corresponde a "fazer a ANOVA": pegamos o modelo misto
## ja ajustado e testamos se cada efeito (Grupo, Momento, interacao) e
## estatisticamente significativo. Usamos soma de quadrados Tipo III
## (padrao quando o desenho tem interacoes) e a aproximacao de
## Satterthwaite para os graus de liberdade, que funciona melhor que a
## aproximacao classica quando os grupos sao desbalanceados, como e o caso
## aqui de proposito (12 participantes no grupo A contra 10 no grupo B).

cat("\n=== ANOVA (Tipo III, aproximacao de Satterthwaite) ===\n")
print(anova(modelo))

# como ler a tabela de ANOVA:
#   Grupo         -> o grupo A difere do grupo B, em media, ignorando o momento?
#   Momento       -> o momento Pre difere do momento Pos, em media, ignorando o grupo?
#   Grupo:Momento -> o efeito do momento e diferente dependendo do grupo (ou, de
#                    forma equivalente, o efeito do grupo e diferente dependendo
#                    do momento)?
#
# se a interacao Grupo:Momento for significativa (valor de p menor que
# 0,05), isso quer dizer que nao faz sentido interpretar os efeitos
# principais de Grupo e de Momento isoladamente; e preciso decompor a
# interacao, o que fazemos na proxima secao


#-------------------------------------------------------------------------------
## 6. MEDIAS AJUSTADAS E COMPARACOES POST-HOC (EMMEANS) ------------------------
## emmeans calcula as "estimated marginal means": as medias previstas pelo
## modelo para cada combinacao de Grupo e Momento, ja levando em conta toda
## a estrutura do modelo misto (nao e simplesmente a media bruta dos dados
## originais).

medias_ajustadas <- emmeans(modelo, ~ Grupo * Momento)
cat("\n=== Medias ajustadas por Grupo e Momento ===\n")
print(medias_ajustadas)

# regra importante sobre quando fazer comparacoes post-hoc: so faz sentido
# reportar comparacoes par a par quando a interacao correspondente deu
# significativa na ANOVA da secao 5. Decompor uma interacao que nao e
# significativa infla a taxa de erro Tipo I, ou seja, aumenta a chance de
# "encontrar" uma diferenca que na verdade e so ruido estatistico

# comparacao 1: Pre vs Pos, dentro de cada Grupo separadamente. So faz
# sentido reportar isto se Grupo:Momento deu significativo na secao 5
comparacao_momento_por_grupo <- emmeans(modelo, ~ Momento | Grupo, weights = "equal")
cat("\n=== Pre vs Pos, dentro de cada Grupo ===\n")
print(pairs(comparacao_momento_por_grupo, adjust = "holm"))
# adjust = "holm" corrige os valores de p para o fato de estarmos fazendo
# mais de uma comparacao na mesma analise, evitando inflar a taxa de erro
# Tipo I (metodo de Holm, um pouco menos conservador que o de Bonferroni)

# comparacao 2: Grupo A vs Grupo B, dentro de cada Momento separadamente.
# Tambem so faz sentido reportar isto se Grupo:Momento deu significativo
comparacao_grupo_por_momento <- emmeans(modelo, ~ Grupo | Momento, weights = "equal")
cat("\n=== Grupo A vs Grupo B, dentro de cada Momento ===\n")
print(pairs(comparacao_grupo_por_momento, adjust = "holm"))


#-------------------------------------------------------------------------------
## 7. GRAFICO DAS MEDIAS AJUSTADAS ----------------------------------------------
## emmip() desenha as medias ajustadas com barras de erro (intervalo de
## confianca de 95%), o que ajuda a visualizar a interacao entre Grupo e
## Momento de forma mais intuitiva do que so olhando a tabela de numeros.

grafico <- emmip(modelo, Grupo ~ Momento, CIs = TRUE) +
  labs(
    title = "Exemplo didatico de 2 vias: Grupo x Momento",
    subtitle = "Medias ajustadas pelo modelo, com intervalo de confianca de 95%"
  )
print(grafico)

# para salvar o grafico em um arquivo em vez de so exibi-lo na tela, use
# ggsave(), do mesmo jeito que e feito nos scripts da pasta scripts/ deste
# repositorio:
#   ggsave("meu-grafico.png", plot = grafico, width = 8, height = 6)


#-------------------------------------------------------------------------------
## PARA ADAPTAR ESTE SCRIPT PARA OS SEUS PROPRIOS DADOS -------------------------
## 1. Troque a secao 1 (dados ficticios) por uma leitura de dados real, por
##    exemplo:
##      dados <- readxl::read_excel("dados/minha-planilha.xlsx")
##    garantindo que a tabela final tenha uma linha por participante por
##    Momento, com colunas Participante, Grupo, Momento e a variavel de
##    desfecho que voce quer analisar.
## 2. Troque o nome "Valor" pelo nome real da sua coluna de desfecho em
##    todas as formulas (lmer, emmeans) e nos textos dentro dos cat().
## 3. Se os nomes das suas categorias forem diferentes de "A"/"B" ou de
##    "Pre"/"Pos", ajuste os levels = c(...) na secao 2 para os nomes reais
##    das suas categorias, na ordem que voce quer usar como referencia.
## 4. Se os seus dados tiverem uma terceira dimensao dentro de cada
##    Momento (por exemplo, varios trechos de um percurso, varias
##    tentativas de uma tarefa, ou um segundo periodo de intervencao), este
##    desenho de 2 vias nao e suficiente: veja o exemplo em
##    exemplo-anova-3way.R, na mesma pasta.
