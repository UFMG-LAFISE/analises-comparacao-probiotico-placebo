# Análises Comparação Probiótico x Placebo

Este repositório reúne os dados brutos, os scripts de análise estatística em R e os relatórios de um estudo que compara um grupo de suplementação (probiótico, identificado como SUPL nos dados) contra um grupo Placebo (PLA) em corredores submetidos a uma prova de 10 km, avaliados em dois períodos de intervenção (pré suplementação e pós suplementação).

## Sobre o estudo

O delineamento é de dois grupos independentes (PLA e SUPL), com N = 19 participantes no total: 10 no grupo PLA e 9 no grupo SUPL. Os participantes são identificados nos dados como participante1 até participante20, com o participante17 ausente de todas as coletas.

As variáveis dependentes foram coletadas em diferentes momentos, dependendo do bloco:

1. Ao longo do percurso da corrida de 10 km, em trechos de 1 km cada, tanto no período pré quanto no período pós intervenção.
2. Imediatamente antes e imediatamente depois da corrida de 10 km, também nos dois períodos de intervenção.
3. Uma única vez por sessão de corrida (sem distinção de antes/depois da corrida em si), nos dois períodos de intervenção.

Essa variação na estrutura de coleta é o motivo de a nomenclatura dos fatores `Momento` e `Tempo` mudar de significado entre blocos de variáveis. Isso está detalhado na seção "Abordagem estatística" abaixo e documentado no início de cada script.

## Estrutura de pastas

O repositório está organizado em três pastas principais, além de duas pastas de imagens:

- `dados/`: todas as planilhas `.xlsx` e o arquivo `.csv` de entrada, com os dados brutos usados pelos scripts.
- `scripts/`: todos os scripts `teste-*.R` de análise estatística.
- `relatorios/`: o relatório consolidado (`.md` e `.pdf`), os arquivos de post hoc do bloco 1, o rascunho de texto para artigo científico, e o resultado numérico da caracterização da amostra.
- `graficos-relatorio/`: gráficos de pressupostos e de resultado das dezenove variáveis originalmente incluídas no relatório consolidado, citados no texto da seção de anexos do relatório. Fica na raiz do repositório, não dentro de `relatorios/`, porque é referenciada assim no texto do relatório.
- `images/`: capturas de tela usadas em uma versão anterior do relatório.

Os scripts em `scripts/` assumem que são executados a partir da raiz do repositório (não de dentro da própria pasta `scripts/`), e leem os dados usando caminhos relativos como `dados/CT.xlsx`. Os gráficos que cada script gera ao rodar são salvos diretamente na raiz do repositório, não dentro de `scripts/` nem de `dados/`. Isso está detalhado na seção "Como reproduzir as análises" abaixo.

## Estrutura do repositório

### Bloco 1: variáveis fisiológicas e perceptivas medidas ao longo do percurso

Cada uma destas variáveis foi registrada a cada 1 km da corrida, nos dois períodos de intervenção, com o fator dentro dos sujeitos `Distância` (ou `Tempo`, dependendo do script) representando o trecho percorrido.

| Script | Planilha de dados | Variável |
|---|---|---|
| scripts/teste-ct.R | dados/CT.xlsx | CT (conforto térmico) |
| scripts/teste-fc.R | dados/FC.xlsx | Frequência cardíaca |
| scripts/teste-pacing.R | dados/pacing.xlsx | Ritmo de corrida (pacing) |
| scripts/teste-pse.R | dados/PSE.xlsx | Percepção subjetiva de esforço |
| scripts/teste-st.R | dados/ST.xlsx | Sensação térmica |
| scripts/teste-temperatura-interna.R | dados/temp-interna.xlsx | Temperatura interna |
| scripts/teste-temperatura-pele.R | dados/temp-pele.xlsx | Temperatura de pele |
| scripts/teste-temp-pele.R | dados/media-temp-pele.xlsx | Média da temperatura de pele |

### Bloco 2: marcadores de equilíbrio hídrico medidos antes e depois da corrida

Estas variáveis foram registradas imediatamente antes e imediatamente depois da corrida de 10 km, nos dois períodos de intervenção. Aqui o fator `Momento` representa o antes/depois da corrida e o fator `Tempo` representa o período de intervenção (pré ou pós suplementação), invertendo a convenção usada no bloco 1.

| Script | Planilha de dados | Variáveis |
|---|---|---|
| scripts/teste-equilibrio-eletrolitico.R | dados/equilibrio-eletrolitico.xlsx | Massa corporal, GEU (gravidade específica da urina), coloração da urina |

### Bloco 3: marcadores hematológicos

Mesma convenção de `Momento` e `Tempo` do bloco 2.

| Script | Planilha de dados | Variáveis |
|---|---|---|
| scripts/teste-sangue.R | dados/sangue.xlsx | HGB (hemoglobina), HCT (hematócrito) |

### Bloco 4: balanço hídrico e desempenho com medida única por sessão

Estas variáveis têm um único valor por sessão de corrida (não há distinção de antes/depois da corrida em si), então o modelo usado tem apenas os fatores `Grupo` e `Momento` (sem o terceiro fator `Tempo`).

| Script | Planilha de dados | Variáveis |
|---|---|---|
| scripts/teste-equilibrio-eletrolitico2.R | dados/equilibrio-eletrolitico.xlsx | Variação de massa corporal em kg, variação de massa corporal em percentual, líquido ingerido, sudorese total, taxa de sudorese |
| scripts/teste-tempo-total-10km.R | dados/tempo-total-10km.xlsx | Tempo total para completar os 10 km |

### Bloco 5: desempenho cognitivo, teste Flanker

Registrado antes e depois da corrida de 10 km, nos dois períodos de intervenção, mesma convenção de `Momento` e `Tempo` dos blocos 2 e 3.

| Script | Planilha de dados | Variáveis |
|---|---|---|
| scripts/teste-flanker.R | dados/resultados-flanker-brutos.csv | Acurácia geral, tempo de reação geral, e acurácia/tempo de reação desagregados por congruência (congruente, incongruente) e por troca de tarefa (com troca, sem troca), totalizando 10 variáveis |

O arquivo `dados/resultados-flanker-brutos.csv` traz o grupo codificado como A/B por cegamento do estudo. O script confere e converte automaticamente essa codificação para PLA/SUPL, usando o identificador de participante como referência, e interrompe a execução com um erro claro caso a contagem de participantes por grupo não bata com o esperado.

### Bloco 6: caracterização dietética

Uma única medida por período de intervenção (mesmo padrão do bloco 4, apenas `Grupo` e `Momento`).

| Script | Planilha de dados | Variáveis |
|---|---|---|
| scripts/teste-dieta-caracterizacao.R | dados/dieta-caracterizacao.xlsx | Proteínas em gramas e em percentual, carboidratos em gramas e em percentual, lipídeos em gramas e em percentual, consumo energético total em kcal |

### Caracterização da amostra

Comparação de características basais entre os grupos, feita por teste t de Welch para amostras independentes (não é um modelo linear misto, pois não há medida repetida nesta comparação).

| Script | Planilha de dados | Variáveis |
|---|---|---|
| scripts/teste-caracterizacao-amostra.R | dados/caracterizacao-amostra.xlsx | Idade, massa corporal, estatura, percentual de gordura corporal, VO2max |

O resultado numérico também fica salvo em `relatorios/caracterizacao-amostra-resultado.csv` após rodar o script.

### Outros arquivos

- `dados/template.xlsx`: modelo em branco usado como referência de formatação ao preparar novas planilhas de dados, não é uma planilha analisada.
- `relatorios/relatorio-analises-gerado-por-IA.md`: relatório consolidado com os resultados de todas as análises acima, incluindo tabelas de médias e desvios padrão, tabelas de valores de p, e a interpretação em texto de cada variável. É o principal documento de referência deste repositório.
- `relatorios/ralatorio-estatistico-barbara.pdf`: versão em PDF do relatório acima, gerada a partir do arquivo `.md`.
- `relatorios/posthoc-tempo-distancia.md` e `relatorios/posthoc-tempo-distancia.pdf`: comparações par a par entre todos os trechos de 1 km do bloco 1, feitas separadamente para cada grupo (PLA e SUPL).
- `relatorios/posthoc-tempo-distancia-grupos-combinados.md` e `relatorios/posthoc-tempo-distancia-grupos-combinados.pdf`: as mesmas comparações par a par entre trechos de 1 km, mas com os dois grupos combinados em uma única análise.
- `relatorios/statistical-analysis.docx`: rascunho de texto em inglês da seção de análise estatística para uso em artigo científico.
- `graficos-relatorio/`: gráficos de pressupostos do modelo (`pressupostos-<variavel>.png`) e gráficos de resultado (`resultado-<variavel>.png`) das dezenove variáveis originalmente incluídas no relatório consolidado, citados no texto da seção de anexos do relatório.
- `images/`: capturas de tela usadas em uma versão anterior do relatório.

Observação sobre o par de arquivos `posthoc-tempo-distancia`: a versão separada por grupo (`posthoc-tempo-distancia.md`) só é estatisticamente justificável para uma variável se a interação Grupo:Distância daquela variável for significativa no modelo principal. Na versão atual dos dados, nenhuma das oito variáveis do bloco 1 apresenta essa interação significativa, então a versão com os grupos combinados (`posthoc-tempo-distancia-grupos-combinados.md`) é a que deve ser usada como referência; a versão separada por grupo fica registrada apenas para consulta exploratória.

## Abordagem estatística

Em vez de uma ANOVA de medidas repetidas ou ANOVA mista clássica, todas as análises usam modelo linear misto (LMM), ajustado com a função `lmer()` do pacote `lme4`. A escolha do LMM em vez da ANOVA clássica se deve a dois fatores: o desbalanceamento amostral entre os grupos (10 participantes no PLA contra 9 no SUPL) e a presença de dados omissos em algumas variáveis, duas condições em que a ANOVA de medidas repetidas perde validade ou exige exclusão listwise de participantes, enquanto o LMM lida com ambas de forma nativa por estimação de máxima verossimilhança.

A fórmula do modelo muda conforme o bloco de variáveis:

```
Valor ~ Grupo * Momento * Tempo + (1 | Participante)   quando existe um terceiro fator Tempo (blocos 1, 2, 3 e 5)
Valor ~ Grupo * Momento + (1 | Participante)             quando não existe fator Tempo (blocos 4 e 6)
```

Em todos os casos, `Participante` entra como efeito aleatório de intercepto, para modelar a estrutura de medidas repetidas dentro de cada pessoa.

A significância dos efeitos fixos é avaliada por ANOVA Tipo III com aproximação de graus de liberdade de Satterthwaite, usando o pacote `lmerTest`. As médias ajustadas e as comparações par a par (post hoc) são obtidas com o pacote `emmeans`, usando graus de liberdade de Kenward-Roger e ajuste de Holm para comparações múltiplas.

Critério para relato de comparações post hoc: uma comparação par a par só é estatisticamente justificável quando a interação correspondente no modelo é significativa (p menor que 0,05). Decompor um fator sem uma interação significativa infla a taxa de erro tipo I. Por isso, o conjunto completo de comparações pareadas só é apresentado, no relatório consolidado, nas variáveis em que a interação relevante atingiu significância estatística. Tendências (0,05 menor ou igual a p menor que 0,10) não habilitam a apresentação de post hoc.

Legenda de significância usada no relatório: `***` para p menor que 0,001, `**` para p menor que 0,01, `*` para p menor que 0,05, `.` para 0,05 menor ou igual a p menor que 0,10 (tendência), `ns` para p maior ou igual a 0,10.

Os pressupostos de cada modelo (linearidade, homogeneidade de variância, normalidade dos resíduos, normalidade dos efeitos aleatórios, observações influentes e colinearidade) são verificados com a função `check_model()` do pacote `performance`, e a checagem formal de observações influentes com a função `check_outliers()` do mesmo pacote.

## Como reproduzir as análises

É necessário ter o R instalado, junto com os seguintes pacotes: `readxl`, `readr`, `dplyr`, `tidyr`, `afex`, `lme4`, `lmerTest`, `emmeans`, `performance`, `ggplot2`, `see`, `patchwork`.

Cada script em `scripts/teste-*.R` é independente e pode ser rodado sozinho, mas precisa ser executado a partir da raiz do repositório (não de dentro da pasta `scripts/`), porque o caminho até os dados dentro do script é escrito como `dados/<arquivo>`. Por exemplo, estando na raiz do repositório:

```
Rscript scripts/teste-ct.R
```

Ao rodar, cada script imprime no console o resumo do modelo, a tabela de ANOVA, as médias ajustadas e as comparações post hoc, além de salvar dois tipos de gráfico diretamente na raiz do repositório (não dentro de `scripts/` nem de `dados/`): um painel de pressupostos do modelo (`pressupostos-modelo-<variavel>.png`) e um ou mais gráficos das médias ajustadas (`grafico-<variavel>-*.png`). Esses arquivos gerados não ficam versionados neste repositório (ver `.gitignore`), já que são reproduzíveis a qualquer momento rodando o script correspondente novamente.

Observação sobre um problema conhecido do ambiente: em algumas instalações do pacote `lme4`, a chamada `print(summary(modelo))` pode falhar com o erro `could not find function "%||%"`, por uma incompatibilidade interna do pacote na formatação da tabela de efeitos aleatórios. Os scripts mais recentes deste repositório (a partir de `teste-flanker.R`) já contornam esse problema imprimindo `coef(summary(modelo))` e `as.data.frame(VarCorr(modelo))` separadamente em vez de `summary(modelo)` diretamente, o que produz a mesma informação sem acionar o trecho de código com o problema.

## Relatório final

O documento `relatorios/relatorio-analises-gerado-por-IA.md` é o relatório consolidado com os resultados de todas as variáveis analisadas neste repositório, organizado em seções: introdução, método, resultados por bloco de variáveis (cada variável com tabela de médias e desvios padrão, tabela de valores de p, e um parágrafo de interpretação), síntese geral dos achados, e anexos com a verificação de pressupostos dos modelos. A versão em PDF (`relatorios/ralatorio-estatistico-barbara.pdf`) é gerada a partir deste arquivo `.md` e deve ser atualizada sempre que o `.md` for alterado, para os dois arquivos não ficarem desatualizados um em relação ao outro.
