# Relatório das Análises Estatísticas

## Estudo de Suplementação em Corrida de 10 km: Comparação entre Grupos Placebo e Suplementação

Autor do código R: Letícia Gontijo

------------------------------------------------------------------------

## 1. Introdução

Este relatório apresenta os resultados das analises estatísticas de um estudo com dois grupos (Placebo, PLA; Suplementacao, SUPL) em corredores submetidos a uma prova de 10 km em dois periodos de intervencao (pre e pos-suplementacao). Trinta e seis variáveis dependentes foram analisadas, agrupadas em seis blocos conforme a estrutura da coleta de dados: (i) variaveis fisiologicas e perceptivas medidas ao longo do percurso (CT, FC, Pacing, PSE, ST, temperatura interna, temperatura de pele, media da temperatura de pele); (ii) marcadores de equilibrio hidrico medidos pre/pos-corrida (massa corporal, GEU, coloracao da urina); (iii) marcadores hematologicos (HGB, HCT); (iv) variaveis de balanco hidrico e desempenho com medida unica por sessao (variacao de massa corporal em kg e em %, liquido ingerido, sudorese total, taxa de sudorese, tempo total de prova); (v) desempenho cognitivo medido pre/pos-corrida por meio do teste Flanker (acuracia geral, TR geral, e acuracia/TR desagregados por congruencia e por troca de tarefa: congruente, incongruente, com troca, sem troca); e (vi) caracterizacao dietetica com medida unica por periodo de intervencao (proteinas, carboidratos e lipideos em gramas e em percentual, consumo energetico total).

## 2. Método

**Delineamento:** N = 19 participantes (10 no grupo PLA, 9 no grupo SUPL). O fator `Grupo` e *between-subjects*; os fatores `Momento` e, quando aplicavel, `Distancia` são *within-subjects* (medidas repetidas no mesmo participante).

**Modelo estatístico:** Para substituir a ANOVA mista (inadequada aqui pelo desbalanceamento amostral (10 vs. 9) e pela presenca de dados omissos), ajustou-se um modelo linear misto (LMM) por participante:

```         
Valor ~ Grupo * Momento * Tempo + (1 | Participante)      [quando ha fator Tempo]
Valor ~ Grupo * Momento + (1 | Participante)               [quando nao ha fator Tempo]
```

Os testes de significancia dos efeitos fixos utilizaram ANOVA Tipo III com aproximacao de graus de liberdade de Satterthwaite (pacote `lmerTest`). As comparações post-hoc foram obtidas via `emmeans`, com graus de liberdade de Kenward-Roger e ajuste de Holm para comparacoes multiplas.

**Nomenclatura dos fatores por bloco:** No bloco (i) e no bloco (iv), que usam medida unica por sessao, `Momento` = pre/pos periodo de intervencao. Nos blocos (ii) (massa corporal, GEU, coloracao da urina), (iii) (HGB, HCT) e (v) (Flanker), a estrutura da planilha/arquivo de origem inverte essa convencao: `Momento` = pre/pos corrida de 10 km, e `Tempo` = pre/pos periodo de intervenção.

**Decodificação do Grupo no Flanker:** O arquivo `Resultados Flanker - brutos.csv` traz o Grupo codificado como "A"/"B" (cegamento). Cruzando o identificador de participante (`Sujeito`) com a composição de grupo já conhecida das demais planilhas, confirmou-se que Grupo A = SUPL e Grupo B = PLA para os 19 participantes; essa recodificação foi aplicada antes da análise.

**Criterio para relato de comparacoes post-hoc:** Comparacoes post-hoc só são estatisticamente justificaveis quando a interação correspondente é significativa (p \< 0,05); decompor um fator sem uma interacao significativa infla a taxa de erro [Tipo I]{.underline}. Por isso, o conjunto completo de comparações pareadas so e apresentado nas seçoes em que a interação relevante atingiu significancia estatistica. Tendencias (0,05 \<= p \< 0,10) não habilitam a apresentacao de post-hoc.

**Tratamento de dados:** Antes das analises estatisticas, foram identificados e corrigidos sete valores de digitação incompatíveis com a faixa fisiologica esperada nas planilhas `temp-interna.xlsx`, `temp-pele.xlsx`, `media-temp-pele.xlsx`, `equilibrio-eletrolitico.xlsx` e `sangue.xlsx` . Todas as analises abaixo foram feitas com os dados corrigidos.

**Legenda de significância:** `***` p \< 0,001; `**` p \< 0,01; `*` p \< 0,05; `.` 0,05 \<= p \< 0,10 (tendencia); `ns` p \>= 0,10. Nas tabelas, "Media +/- DP" refere-se a estatisticas descritivas brutas (não as medias ajustadas do modelo).

------------------------------------------------------------------------

## 3. Resultados

### 3.0 Caracterização da Amostra

Comparação das características basais entre os grupos por teste t de Welch para amostras independentes (`t.test()`, variâncias não assumidas iguais).

| Variável             | PLA (n=10)      | SUPL (n=9)      | p     | Sig. |
|----------------------|-----------------|-----------------|-------|------|
| Idade (anos)         | 33,50 +/- 7,59  | 32,22 +/- 4,63  | 0,661 | ns   |
| Massa corporal (kg)  | 64,13 +/- 9,71  | 70,22 +/- 15,26 | 0,323 | ns   |
| Estatura (cm)        | 167,70 +/- 7,36 | 169,11 +/- 9,40 | 0,723 | ns   |
| Gordura corporal (%) | 14,86 +/- 4,20  | 14,13 +/- 8,34  | 0,818 | ns   |
| VO2max (mlO2/kg/min) | 45,72 +/- 5,99  | 43,99 +/- 5,89  | 0,534 | ns   |

Os grupos PLA e SUPL não diferiram significativamente em nenhuma das características avaliadas: idade (p=0,661), massa corporal (p=0,323), estatura (p=0,723), percentual de gordura corporal (p=0,818) e VO2max (p=0,534).

------------------------------------------------------------------------

### 3.1 Variáveis medidas ao longo do percurso (Grupo x Momento x Ditância)

#### 3.1.1 CT

| Grupo | Momento | Media | DP   | n   |
|-------|---------|-------|------|-----|
| PLA   | Pre     | 2,51  | 1,04 | 100 |
| PLA   | Pos     | 2,65  | 1,01 | 100 |
| SUPL  | Pre     | 2,99  | 0,98 | 90  |
| SUPL  | Pos     | 3,29  | 0,82 | 90  |

| Efeito                  | p       | Sig.   |
|-------------------------|---------|--------|
| Grupo                   | 0,087   | .      |
| Momento                 | \<0,001 | \*\*\* |
| Distância               | \<0,001 | \*\*\* |
| Grupo:Momento           | 0,109   | ns     |
| Grupo:Distância         | 0,201   | ns     |
| Momento:Distância       | 0,337   | ns     |
| Grupo:Momento:Distância | 0,199   | ns     |

O CT apresentou efeito principal significativo de Momento (Pre: 2,74+/-1,04; Pos: 2,95+/-0,98; p\<0,001) e de Distância ao longo do percurso (p\<0,001), com aumento esperado a medida que a corrida avançava. O efeito de Grupo apareceu em nível de tendência (PLA: 2,58+/-1,02; SUPL: 3,14+/-0,91; p=0,087). Nenhuma interação envolvendo Grupo atingiu significância estatística (Grupo:Momento p=0,109; Grupo:Distância p=0,201; Grupo:Momento:Distância p=0,199); portanto, comparações post-hoc entre grupos não serão reportadas.

------------------------------------------------------------------------

#### 3.1.2 FC

| Grupo | Momento | Media  | DP    | n   |
|-------|---------|--------|-------|-----|
| PLA   | Pre     | 164,74 | 15,28 | 100 |
| PLA   | Pos     | 159,20 | 12,21 | 100 |
| SUPL  | Pre     | 169,97 | 14,29 | 90  |
| SUPL  | Pos     | 169,09 | 15,28 | 90  |

| Efeito                  | p       | Sig.   |
|-------------------------|---------|--------|
| Grupo                   | 0,171   | ns     |
| Momento                 | \<0,001 | \*\*\* |
| Distância               | \<0,001 | \*\*\* |
| Grupo:Momento           | 0,001   | \*\*   |
| Grupo:Distância         | 0,965   | ns     |
| Momento:Distância       | 0,876   | ns     |
| Grupo:Momento:Distância | 0,990   | ns     |

[**Comparacoes post-hoc :**]{.underline}

**Momento dentro de cada Grupo:**

\- PLA: Pre (164,74+/-15,28) vs. Pos (159,20+/-12,21): redução de 5,54 bpm, estatisticamente significativa (p\<0,0001).

\- SUPL: Pre (169,97+/-14,29) vs. Pos (169,09+/-15,28): redução de 0,88 bpm, não significativa (p=0,391).

**Grupo dentro de cada Momento:**

\- Pre: PLA (164,74+/-15,28) vs. SUPL (169,97+/-14,29): diferença não significativa (p=0,340).

\- Pos: PLA (159,20+/-12,21) vs. SUPL (169,09+/-15,28) : diferença de tendência, não significativa a 5% (p=0,081).

A FC apresentou efeito principal significativo de Distância (p\<0,001), com elevacao esperada ao longo do percurso, sem interação com Grupo (Grupo:Distância p=0,965).

------------------------------------------------------------------------

#### 3.1.3 Pacing

| Grupo | Momento | Media | DP   | n   |
|-------|---------|-------|------|-----|
| PLA   | Pre     | 5,60  | 0,87 | 100 |
| PLA   | Pos     | 5,89  | 1,36 | 100 |
| SUPL  | Pre     | 6,06  | 0,95 | 90  |
| SUPL  | Pos     | 6,17  | 1,29 | 90  |

| Efeito                  | p     | Sig. |
|-------------------------|-------|------|
| Grupo                   | 0,444 | ns   |
| Momento                 | 0,001 | \*\* |
| Distância               | 0,005 | \*\* |
| Grupo:Momento           | 0,138 | ns   |
| Grupo:Distância         | 0,741 | ns   |
| Momento:Distância       | 0,825 | ns   |
| Grupo:Momento:Distância | 0,981 | ns   |

Foi observado um efeito principal significativo de Momento (Pre: 5,81+/-0,93; Pos: 6,02+/-1,33; p=0,001) e de Distância (variação de ritmo entre trechos do percurso, p=0,005). O efeito de Grupo não foi significativo (PLA: 5,74+/-1,15; SUPL: 6,11+/-1,13; p=0,444), tampouco nenhuma interação envolvendo Grupo (todas p\>=0,138).

------------------------------------------------------------------------

#### 3.1.4 PSE

| Grupo | Momento | Media | DP   | n   |
|-------|---------|-------|------|-----|
| PLA   | Pre     | 12,75 | 4,13 | 100 |
| PLA   | Pos     | 12,08 | 3,71 | 100 |
| SUPL  | Pre     | 14,91 | 2,87 | 90  |
| SUPL  | Pos     | 15,74 | 2,74 | 90  |

| Efeito                  | p       | Sig.   |
|-------------------------|---------|--------|
| Grupo                   | 0,024   | \*     |
| Momento                 | 0,542   | ns     |
| Distância               | \<0,001 | \*\*\* |
| Grupo:Momento           | \<0,001 | \*\*\* |
| Grupo:Distância         | 0,786   | ns     |
| Momento:Distância       | 0,754   | ns     |
| Grupo:Momento:Distância | 0,963   | ns     |

[**Comparacoes post-hoc:**]{.underline}

**Momento dentro de cada Grupo:**

\- PLA: Pre (12,75+/-4,13) vs. Pos (12,08+/-3,71): redução significativa da percepção de esforço (p=0,0003).

\- SUPL: Pre (14,91+/-2,87) vs. Pos (15,74+/-2,74): aumento significativo da percepção de esforço (p\<0,0001).

As duas comparacoes indicam direções opostas entre os grupos: o grupo PLA reduziu a percepcao de esforco do periodo pre para o pos-intervencao, enquanto o grupo SUPL a aumentou.

**Grupo dentro de cada Momento:**

\- Pre: PLA (12,75+/-4,13) vs. SUPL (14,91+/-2,87): diferenca de tendencia, nao significativa a 5% (p=0,084).

\- Pos: PLA (12,08+/-3,71) vs. SUPL (15,74+/-2,74): diferenca estatisticamente significativa (p=0,0063).

O efeito de Grupo também foi significativo (PLA: 12,42+/-3,93; SUPL: 15,33+/-2,82; p=0,024). Não houve interação com Distância (Grupo:Distância p=0,786), indicando que a diferença entre grupos e estável ao longo de todo o percurso, e não concentrada em um trecho específico.

------------------------------------------------------------------------

#### 3.1.5 ST

| Grupo | Momento | Media | DP   | n   |
|-------|---------|-------|------|-----|
| PLA   | Pre     | 5,73  | 0,91 | 100 |
| PLA   | Pos     | 5,76  | 0,91 | 100 |
| SUPL  | Pre     | 6,12  | 0,73 | 90  |
| SUPL  | Pos     | 6,20  | 0,72 | 90  |

| Efeito                  | p       | Sig.   |
|-------------------------|---------|--------|
| Grupo                   | 0,100   | .      |
| Momento                 | 0,249   | ns     |
| Distância               | \<0,001 | \*\*\* |
| Grupo:Momento           | 0,609   | ns     |
| Grupo:Distância         | 0,346   | ns     |
| Momento:Distância       | 0,999   | ns     |
| Grupo:Momento:Distância | 0,126   | ns     |

Apenas o efeito principal de Distância foi estatisticamente significativo (p\<0,001), refletindo a elevacao esperada da sensaçao térmica ao longo da prova. O efeito de Grupo não apresentou diferença estatística (PLA: 5,75+/-0,91; SUPL: 6,16+/-0,72; p=0,100), e nenhuma interação atingiu significância (todas p\>=0,126).

------------------------------------------------------------------------

#### 3.1.6 Temperatura Interna

| Grupo | Momento | Media | DP   | n   |
|-------|---------|-------|------|-----|
| PLA   | Pre     | 38,56 | 0,76 | 100 |
| PLA   | Pos     | 38,29 | 1,11 | 90  |
| SUPL  | Pre     | 38,67 | 0,76 | 90  |
| SUPL  | Pos     | 38,70 | 0,92 | 80  |

| Efeito                  | p       | Sig.   |
|-------------------------|---------|--------|
| Grupo                   | 0,146   | ns     |
| Momento                 | 0,014   | \*     |
| Distância               | \<0,001 | \*\*\* |
| Grupo:Momento           | 0,005   | \*\*   |
| Grupo:Distância         | 0,527   | ns     |
| Momento:Distância       | 0,851   | ns     |
| Grupo:Momento:Distância | 0,654   | ns     |

[**Comparacoes post-hoc :**]{.underline}

**Momento dentro de cada Grupo:**

\- PLA: Pre (38,56+/-0,76) vs. Pos (38,29+/-1,11): redução significativa da temperatura interna (p=0,0002).

\- SUPL: Pre (38,67+/-0,76) vs. Pos (38,70+/-0,92): variação não significativa (p=0,816).

**Grupo dentro de cada Momento:**

\- Pre: PLA (38,56+/-0,76) vs. SUPL (38,67+/-0,76): diferença nao significativa (p=0,577).

\- Pos: PLA (38,29+/-1,11) vs. SUPL (38,70+/-0,92): diferença estatisticamente significativa (p=0,031).

Os tamanhos amostrais das celulas variam (n=80 a 100) em funcao de dados omissos remanescentes de um participante cujo sensor interrompeu a coleta no periodo pos-intervenção.

------------------------------------------------------------------------

#### 3.1.7 Temperatura de Pele (skin-calera)

| Grupo | Momento | Media | DP   | n   |
|-------|---------|-------|------|-----|
| PLA   | Pre     | 35,33 | 1,07 | 100 |
| PLA   | Pos     | 35,10 | 1,50 | 100 |
| SUPL  | Pre     | 35,25 | 0,92 | 90  |
| SUPL  | Pos     | 35,32 | 1,39 | 80  |

| Efeito                  | p     | Sig.   |
|-------------------------|-------|--------|
| Grupo                   | 0,939 | ns     |
| Momento                 | 0,193 | ns     |
| Distância               | 0,001 | \*\*\* |
| Grupo:Momento           | 0,149 | ns     |
| Grupo:Distância         | 0,843 | ns     |
| Momento:Distância       | 0,916 | ns     |
| Grupo:Momento:Distância | 0,993 | ns     |

Apenas o efeito de Distância foi estatisticamente significativo (p=0,001). Sem comparacoes post-hoc a reportar.

------------------------------------------------------------------------

#### 3.1.8 Media (calculada) da Temperatura de Pele

| Grupo | Momento | Media | DP   | n   |
|-------|---------|-------|------|-----|
| PLA   | Pre     | 33,72 | 0,76 | 100 |
| PLA   | Pos     | 33,79 | 1,22 | 100 |
| SUPL  | Pre     | 33,60 | 0,74 | 90  |
| SUPL  | Pos     | 33,48 | 0,67 | 90  |

| Efeito                  | p       | Sig.   |
|-------------------------|---------|--------|
| Grupo                   | 0,433   | ns     |
| Momento                 | 0,784   | ns     |
| Distância               | \<0,001 | \*\*\* |
| Grupo:Momento           | 0,162   | ns     |
| Grupo:Distância         | 0,633   | ns     |
| Momento:Distância       | 0,986   | ns     |
| Grupo:Momento:Distância | 0,919   | ns     |

Apenas o efeito de Tempo foi estatisticamente significativo (p\<0,001). Nenhuma interacao envolvendo Grupo atingiu significancia. Sem comparacoes post-hoc a reportar.

------------------------------------------------------------------------

### 3.2 Marcadores de equilibrio hidrico pre/pos-corrida (Momento = pre/pos 10 km; Tempo = pre/pos intervencao)

#### 3.2.1 Massa Corporal (kg)

| Grupo | Momento (10 km) | Media | DP    | n   |
|-------|-----------------|-------|-------|-----|
| PLA   | Pre             | 64,99 | 9,02  | 20  |
| PLA   | Pos             | 64,30 | 8,94  | 20  |
| SUPL  | Pre             | 67,76 | 14,35 | 18  |
| SUPL  | Pos             | 66,84 | 13,96 | 18  |

| Efeito              | p       | Sig.   |
|---------------------|---------|--------|
| Grupo               | 0,637   | ns     |
| Momento (10 km)     | \<0,001 | \*\*\* |
| Tempo (interv.)     | \<0,001 | \*\*\* |
| Grupo:Momento       | 0,403   | ns     |
| Grupo:Tempo         | 0,659   | ns     |
| Momento:Tempo       | 0,816   | ns     |
| Grupo:Momento:Tempo | 0,879   | ns     |

A massa corporal reduziu-se significativamente do periodo pre para o pos-corrida (Pre: 66,30+/-11,76; Pos: 65,51+/-11,50; p\<0,001), compativel com perda hidrica por sudorese durante os 10 km, e diferiu tambem entre os periodos pre/pos-intervencao (p\<0,001). O efeito de Grupo nao foi significativo (PLA: 64,65+/-8,87; SUPL: 67,30+/-13,96; p=0,637), nem nenhuma interacao (todas p\>=0,403). Sem comparacoes post-hoc a reportar.

------------------------------------------------------------------------

#### 3.2.2 GEU (Gravidade Especifica da Urina)

| Grupo | Tempo (interv.) | Media  | DP     | n   |
|-------|-----------------|--------|--------|-----|
| PLA   | Pre             | 1,0097 | 0,0054 | 20  |
| PLA   | Pos             | 1,0132 | 0,0080 | 20  |
| SUPL  | Pre             | 1,0140 | 0,0092 | 18  |
| SUPL  | Pos             | 1,0104 | 0,0084 | 18  |

| Efeito              | p     | Sig. |
|---------------------|-------|------|
| Grupo               | 0,793 | ns   |
| Momento (10 km)     | 0,258 | ns   |
| Tempo (interv.)     | 0,966 | ns   |
| Grupo:Momento       | 0,646 | ns   |
| Grupo:Tempo         | 0,007 | \*\* |
| Momento:Tempo       | 0,494 | ns   |
| Grupo:Momento:Tempo | 0,878 | ns   |

[**Comparacoes post-hoc:**]{.underline}

**Tempo (intervenção) dentro de cada Grupo:**

\- PLA: Pre (1,0097+/-0,0054) vs. Pos (1,0132+/-0,0080): aumento estatisticamente significativo (p=0,0495).

\- SUPL: Pre (1,0140+/-0,0092) vs. Pos (1,0104+/-0,0084): reduçao de tendencia, não significativa a 5% (p=0,0546).

**Grupo dentro de cada Tempo:**

\- Pre-intervencao: PLA (1,0097+/-0,0054) vs. SUPL (1,0140+/-0,0092): diferenca nao significativa (p=0,197).

\- Pos-intervencao: PLA (1,0132+/-0,0080) vs. SUPL (1,0104+/-0,0084): diferenca nao significativa (p=0,412).

O GEU aumenta no grupo PLA e diminui no grupo SUPL entre os periodos de intervencao, com a comparacao dentro do PLA atingindo significancia individual. A magnitude das diferencas e pequena (da ordem de 0,003 a 0,004 na gravidade especifica).

------------------------------------------------------------------------

#### 3.2.3 Coloracao da Urina

| Grupo | Momento (10 km) | Media | DP   | n   |
|-------|-----------------|-------|------|-----|
| PLA   | Pre             | 3,75  | 1,25 | 20  |
| PLA   | Pos             | 4,40  | 1,64 | 20  |
| SUPL  | Pre             | 3,50  | 1,54 | 18  |
| SUPL  | Pos             | 4,56  | 1,62 | 18  |

| Efeito              | p     | Sig. |
|---------------------|-------|------|
| Grupo               | 0,931 | ns   |
| Momento (10 km)     | 0,002 | \*\* |
| Tempo (interv.)     | 0,032 | \*   |
| Grupo:Momento       | 0,431 | ns   |
| Grupo:Tempo         | 0,268 | ns   |
| Momento:Tempo       | 0,820 | ns   |
| Grupo:Momento:Tempo | 0,673 | ns   |

A coloração da urina apresentou aumento significativo do periodo pre para o pos-corrida (Pre: 3,63+/-1,39; Pos: 4,47+/-1,61; p=0,002), e também diferiu entre os periodos de intervencao (p=0,032). O efeito de Grupo nao foi significativo (p=0,931), nem nenhuma interação (todas p\>=0,268). Sem comparacoes post-hoc a reportar. O achado e consistente com o de massa corporal (3.2.1): ambos os marcadores de hidratação respondem a corrida, sem diferença atribuivel a suplementação.

------------------------------------------------------------------------

### 3.3 Marcadores hematologicos (Momento = pre/pos 10 km; Tempo = pre/pos intervencao)

#### 3.3.1 HGB (Hemoglobina)

| Grupo | Momento (10 km) | Media | DP   | n   |
|-------|-----------------|-------|------|-----|
| PLA   | Pre             | 13,42 | 1,15 | 20  |
| PLA   | Pos             | 13,67 | 1,24 | 20  |
| SUPL  | Pre             | 13,44 | 1,62 | 18  |
| SUPL  | Pos             | 13,79 | 1,67 | 18  |

| Efeito              | p     | Sig. |
|---------------------|-------|------|
| Grupo               | 0,908 | ns   |
| Momento (10 km)     | 0,014 | \*   |
| Tempo (interv.)     | 0,012 | \*   |
| Grupo:Momento       | 0,675 | ns   |
| Grupo:Tempo         | 0,554 | ns   |
| Momento:Tempo       | 0,776 | ns   |
| Grupo:Momento:Tempo | 0,432 | ns   |

A HGB aumentou significativamente do período pre para o pos-corrida (Pre: 13,43+/-1,37; Pos: 13,73+/-1,44; p=0,014) e diferiu entre os periodos de intervencao (p=0,012), padrão compatível com hemoconcentração por perda hidrica durante o exercicio. O efeito de Grupo nao foi significativo (p=0,908), nem nenhuma interação (todas p\>=0,432). Sem comparacoes post-hoc a reportar.

------------------------------------------------------------------------

#### 3.3.2 HCT (Hematocrito)

| Grupo | Momento (10 km) | Media | DP   | n   |
|-------|-----------------|-------|------|-----|
| PLA   | Pre             | 40,31 | 2,85 | 20  |
| PLA   | Pos             | 41,18 | 3,24 | 20  |
| SUPL  | Pre             | 39,98 | 4,49 | 18  |
| SUPL  | Pos             | 41,35 | 4,55 | 18  |

| Efeito              | p     | Sig. |
|---------------------|-------|------|
| Grupo               | 0,965 | ns   |
| Momento (10 km)     | 0,002 | \*\* |
| Tempo (interv.)     | 0,324 | ns   |
| Grupo:Momento       | 0,476 | ns   |
| Grupo:Tempo         | 0,427 | ns   |
| Momento:Tempo       | 0,301 | ns   |
| Grupo:Momento:Tempo | 0,463 | ns   |

O HCT aumentou significativamente do período pre para o pos-corrida (Pre: 40,15+/-3,67; Pos: 41,26+/-3,86; p=0,002), mesmo padrão observado para a HGB, compatível com hemoconcentração. O efeito de Grupo não foi significativo (p=0,965), nem nenhuma interação (todas p\>=0,301). Sem comparacoes post-hoc a reportar.

------------------------------------------------------------------------

### 3.4 Balanco hidrico e desempenho — medida unica por sessao (Grupo x Momento, sem fator Tempo)

#### 3.4.1 D Massa Corporal (kg)

| Grupo | Momento | Media  | DP    | n   |
|-------|---------|--------|-------|-----|
| PLA   | Pre     | -0,678 | 0,230 | 10  |
| PLA   | Pos     | -0,700 | 0,483 | 10  |
| SUPL  | Pre     | -0,864 | 0,459 | 9   |
| SUPL  | Pos     | -0,969 | 0,509 | 9   |

| Efeito        | p     | Sig. |
|---------------|-------|------|
| Grupo         | 0,193 | ns   |
| Momento       | 0,557 | ns   |
| Grupo:Momento | 0,701 | ns   |

Nenhum efeito atingiu significancia estatistica (Grupo p=0,193; Momento p=0,557; Grupo:Momento p=0,701). Sem comparacoes post-hoc a reportar.

------------------------------------------------------------------------

#### 3.4.2 D Massa Corporal (%)

| Grupo | Momento | Media | DP   | n   |
|-------|---------|-------|------|-----|
| PLA   | Pre     | -1,06 | 0,44 | 10  |
| PLA   | Pos     | -1,06 | 0,75 | 10  |
| SUPL  | Pre     | -1,22 | 0,49 | 9   |
| SUPL  | Pos     | -1,37 | 0,54 | 9   |

| Efeito        | p     | Sig. |
|---------------|-------|------|
| Grupo         | 0,231 | ns   |
| Momento       | 0,695 | ns   |
| Grupo:Momento | 0,667 | ns   |

Nenhum efeito significativo (todas p\>=0,231). A perda percentual de massa corporal situou-se entre 1,06% e 1,37% em media nas quatro celulas. Sem comparacoes post-hoc a reportar.

------------------------------------------------------------------------

#### 3.4.3 Liquido Ingerido (mL)

| Grupo | Momento | Media | DP    | n   |
|-------|---------|-------|-------|-----|
| PLA   | Pre     | 534,0 | 205,7 | 10  |
| PLA   | Pos     | 709,2 | 269,2 | 10  |
| SUPL  | Pre     | 412,4 | 175,4 | 9   |
| SUPL  | Pos     | 613,3 | 242,5 | 9   |

| Efeito        | p     | Sig. |
|---------------|-------|------|
| Grupo         | 0,149 | ns   |
| Momento       | 0,015 | \*   |
| Grupo:Momento | 0,863 | ns   |

O líquido ingerido aumentou significativamente do período pré para o pós-intervenção (Pré: 476,4+/-196,8; Pós: 663,8+/-254,5; p=0,015). O efeito de Grupo não foi significativo (PLA: 621,6+/-249,9; SUPL: 512,9+/-229,9; p=0,149), nem a interação Grupo:Momento (p=0,863). Sem comparacoes post-hoc a reportar.

------------------------------------------------------------------------

#### 3.4.4 Sudorese Total (mL)

| Grupo | Momento | Media  | DP    | n   |
|-------|---------|--------|-------|-----|
| PLA   | Pre     | 1212,0 | 226,1 | 10  |
| PLA   | Pos     | 1409,2 | 363,7 | 10  |
| SUPL  | Pre     | 1276,9 | 387,3 | 9   |
| SUPL  | Pos     | 1582,2 | 483,7 | 9   |

| Efeito        | p     | Sig. |
|---------------|-------|------|
| Grupo         | 0,411 | ns   |
| Momento       | 0,019 | \*   |
| Grupo:Momento | 0,584 | ns   |

A sudorese total aumentou significativamente do período pré para o pós-intervenção (Pré: 1242,7+/-305,5; Pós: 1491,2+/-421,9; p=0,019). O efeito de Grupo não foi significativo (PLA: 1310,6+/-311,6; SUPL: 1429,6+/-453,2; p=0,411), nem a interação Grupo:Momento (p=0,584). Sem comparacoes post-hoc a reportar.

------------------------------------------------------------------------

#### 3.4.5 Taxa de Sudorese (mL/min)

| Grupo | Momento | Media | DP   | n   |
|-------|---------|-------|------|-----|
| PLA   | Pre     | 22,53 | 4,87 | 10  |
| PLA   | Pos     | 25,40 | 5,52 | 10  |
| SUPL  | Pre     | 22,40 | 7,27 | 9   |
| SUPL  | Pos     | 27,84 | 8,82 | 9   |

| Efeito        | p     | Sig. |
|---------------|-------|------|
| Grupo         | 0,676 | ns   |
| Momento       | 0,010 | \*   |
| Grupo:Momento | 0,385 | ns   |

A taxa de sudorese aumentou significativamente do período pré para o pós-intervenção (Pré: 22,47+/-5,95; Pós: 26,56+/-7,17; p=0,010). O efeito de Grupo não foi significativo (PLA: 24,0+/-5,3; SUPL: 25,1+/-8,3; p=0,676), nem a interação Grupo:Momento (p=0,385). Sem comparacoes post-hoc a reportar.

------------------------------------------------------------------------

#### 3.4.6 Tempo Total para Completar os 10 km

| Grupo | Momento | Media | DP   | n   |
|-------|---------|-------|------|-----|
| PLA   | Pre     | 54,46 | 5,33 | 10  |
| PLA   | Pos     | 55,47 | 5,91 | 10  |
| SUPL  | Pre     | 57,93 | 7,03 | 9   |
| SUPL  | Pos     | 57,61 | 7,57 | 9   |

| Efeito        | p     | Sig. |
|---------------|-------|------|
| Grupo         | 0,333 | ns   |
| Momento       | 0,718 | ns   |
| Grupo:Momento | 0,496 | ns   |

Nenhum efeito significativo (todas p\>=0,333). O tempo total de prova situou-se entre 54,5 e 57,9 minutos nas quatro situações, sem diferençaa atribuível ao grupo ou ao período de intervenção. Sem comparacoes post-hoc a reportar.

------------------------------------------------------------------------

### 3.5 Desempenho Cognitivo — Teste Flanker (Momento = pre/pos 10 km; Tempo = pre/pos intervencao)

#### 3.5.1 Acurácia (%)

| Grupo | Momento (10 km) | Media | DP   | n   |
|-------|------------------|-------|------|-----|
| PLA   | Pre              | 98,04 | 1,31 | 19  |
| PLA   | Pos              | 97,36 | 1,43 | 19  |
| SUPL  | Pre              | 98,22 | 1,53 | 18  |
| SUPL  | Pos              | 97,81 | 2,14 | 18  |

| Efeito              | p     | Sig. |
|---------------------|-------|------|
| Grupo               | 0,555 | ns   |
| Momento (10 km)     | 0,087 | .    |
| Tempo (interv.)     | 0,455 | ns   |
| Grupo:Momento       | 0,671 | ns   |
| Grupo:Tempo         | 0,231 | ns   |
| Momento:Tempo       | 0,323 | ns   |
| Grupo:Momento:Tempo | 0,885 | ns   |

A acurácia no Flanker não diferiu significativamente entre grupos (PLA: 97,70+/-1,39; SUPL: 98,02+/-1,85; p=0,555), nem entre os períodos de intervenção (p=0,455). O efeito de Momento apareceu em nível de tendência (Pre: 98,13+/-1,40; Pos: 97,58+/-1,80; p=0,087), sugerindo uma leve queda de acurácia após a corrida de 10 km, mas sem atingir significância estatística. Nenhuma interação envolvendo Grupo atingiu significância (todas p\>=0,231); portanto, comparações post-hoc entre grupos não serão reportadas.

------------------------------------------------------------------------

#### 3.5.2 TR — Tempo de Reação (ms)

| Grupo | Momento (10 km) | Media  | DP     | n   |
|-------|------------------|--------|--------|-----|
| PLA   | Pre              | 748,64 | 156,45 | 19  |
| PLA   | Pos              | 647,60 | 120,72 | 19  |
| SUPL  | Pre              | 816,51 | 135,46 | 18  |
| SUPL  | Pos              | 728,81 | 89,32  | 18  |

| Efeito              | p       | Sig.   |
|---------------------|---------|--------|
| Grupo               | 0,333   | ns     |
| Momento (10 km)     | \<0,001 | \*\*\* |
| Tempo (interv.)     | \<0,001 | \*\*\* |
| Grupo:Momento       | 0,572   | ns     |
| Grupo:Tempo         | 0,746   | ns     |
| Momento:Tempo       | 0,080   | .      |
| Grupo:Momento:Tempo | 0,622   | ns     |

O tempo de reação caiu significativamente do período pré para o pós-corrida (Pre: 781,7+/-148,6 ms; Pos: 687,1+/-112,9 ms; p\<0,001) e também do período pré para o pós-intervenção (Pre: 763,4+/-141,4 ms; Pos: 706,9+/-133,6 ms; p\<0,001) — padrão compatível com efeito de prática/familiarização com a tarefa cognitiva, repetida quatro vezes ao longo do estudo. Momento:Tempo apareceu em nível de tendência (p=0,080). O efeito de Grupo não foi significativo (PLA: 698,1+/-147,0 ms; SUPL: 772,7+/-121,5 ms; p=0,333), nem nenhuma interação envolvendo Grupo (todas p\>=0,572); portanto, comparações post-hoc entre grupos não serão reportadas.

------------------------------------------------------------------------

#### 3.5.3 Acurácia Congruente (%)

| Grupo | Momento (10 km) | Media | DP   | n   |
|-------|------------------|-------|------|-----|
| PLA   | Pre              | 98,97 | 1,00 | 19  |
| PLA   | Pos              | 99,22 | 0,85 | 19  |
| SUPL  | Pre              | 99,67 | 0,68 | 18  |
| SUPL  | Pos              | 99,56 | 0,69 | 18  |

| Efeito              | p     | Sig. |
|---------------------|-------|------|
| Grupo               | 0,045 | \*   |
| Momento (10 km)     | 0,706 | ns   |
| Tempo (interv.)     | 0,414 | ns   |
| Grupo:Momento       | 0,289 | ns   |
| Grupo:Tempo         | 0,155 | ns   |
| Momento:Tempo       | 0,621 | ns   |
| Grupo:Momento:Tempo | 0,294 | ns   |

Houve efeito principal significativo de Grupo (PLA: 99,10+/-0,93; SUPL: 99,61+/-0,68; p=0,045) — SUPL com acurácia levemente maior nas tentativas congruentes. Nenhuma interação envolvendo Grupo atingiu significância (todas p\>=0,155); portanto, comparações post-hoc entre grupos não serão reportadas.

------------------------------------------------------------------------

#### 3.5.4 Acurácia Incongruente (%)

| Grupo | Momento (10 km) | Media | DP   | n   |
|-------|------------------|-------|------|-----|
| PLA   | Pre              | 95,48 | 3,58 | 19  |
| PLA   | Pos              | 92,15 | 5,13 | 19  |
| SUPL  | Pre              | 94,24 | 5,29 | 18  |
| SUPL  | Pos              | 92,98 | 7,23 | 18  |

| Efeito              | p     | Sig. |
|---------------------|-------|------|
| Grupo               | 0,918 | ns   |
| Momento (10 km)     | 0,032 | \*   |
| Tempo (interv.)     | 0,668 | ns   |
| Grupo:Momento       | 0,331 | ns   |
| Grupo:Tempo         | 0,478 | ns   |
| Momento:Tempo       | 0,348 | ns   |
| Grupo:Momento:Tempo | 0,742 | ns   |

A acurácia nas tentativas incongruentes caiu do período pré para o pós-corrida (Pre: 94,87+/-4,48; Pos: 92,56+/-6,17; p=0,032). O efeito de Grupo não foi significativo (p=0,918), nem nenhuma interação (todas p\>=0,331); portanto, comparações post-hoc entre grupos não serão reportadas.

------------------------------------------------------------------------

#### 3.5.5 Acurácia com Troca (%)

| Grupo | Momento (10 km) | Media | DP   | n   |
|-------|------------------|-------|------|-----|
| PLA   | Pre              | 97,84 | 2,17 | 19  |
| PLA   | Pos              | 96,61 | 2,32 | 19  |
| SUPL  | Pre              | 98,14 | 1,71 | 18  |
| SUPL  | Pos              | 97,90 | 2,44 | 18  |

| Efeito              | p     | Sig. |
|---------------------|-------|------|
| Grupo               | 0,199 | ns   |
| Momento (10 km)     | 0,113 | ns   |
| Tempo (interv.)     | 0,768 | ns   |
| Grupo:Momento       | 0,273 | ns   |
| Grupo:Tempo         | 0,180 | ns   |
| Momento:Tempo       | 0,268 | ns   |
| Grupo:Momento:Tempo | 0,234 | ns   |

Nenhum efeito atingiu significância estatística (todas p\>=0,113). Sem comparações post-hoc a reportar.

------------------------------------------------------------------------

#### 3.5.6 Acurácia sem Troca (%)

| Grupo | Momento (10 km) | Media | DP   | n   |
|-------|------------------|-------|------|-----|
| PLA   | Pre              | 98,29 | 2,38 | 19  |
| PLA   | Pos              | 98,13 | 1,98 | 19  |
| SUPL  | Pre              | 98,25 | 1,92 | 18  |
| SUPL  | Pos              | 97,68 | 2,44 | 18  |

| Efeito              | p     | Sig. |
|---------------------|-------|------|
| Grupo               | 0,686 | ns   |
| Momento (10 km)     | 0,480 | ns   |
| Tempo (interv.)     | 0,432 | ns   |
| Grupo:Momento       | 0,581 | ns   |
| Grupo:Tempo         | 0,829 | ns   |
| Momento:Tempo       | 0,011 | \*   |
| Grupo:Momento:Tempo | 0,364 | ns   |

Não houve efeito de Grupo (p=0,686) nem interação envolvendo Grupo (todas p\>=0,155); a única interação significativa foi Momento:Tempo (p=0,011, não envolve Grupo). Decompondo Momento dentro de cada Tempo (`emmeans(~ Momento | Tempo)`, ajuste Holm): no período pré-intervenção a diferença pré/pós-corrida não foi significativa (97,5 -\> 98,3; p=0,185), mas no período pós-intervenção a acurácia sem troca caiu significativamente do pré para o pós-corrida (99,0 -\> 97,5; p=0,020). Como a interação não envolve Grupo, essa decomposição não altera a conclusão de ausência de efeito de suplementação nesta variável.

------------------------------------------------------------------------

#### 3.5.7 TR Congruente (ms)

| Grupo | Momento (10 km) | Media  | DP     | n   |
|-------|------------------|--------|--------|-----|
| PLA   | Pre              | 723,92 | 155,63 | 19  |
| PLA   | Pos              | 624,83 | 113,87 | 19  |
| SUPL  | Pre              | 796,14 | 135,97 | 18  |
| SUPL  | Pos              | 704,50 | 86,04  | 18  |

| Efeito              | p       | Sig.   |
|---------------------|---------|--------|
| Grupo               | 0,277   | ns     |
| Momento (10 km)     | \<0,001 | \*\*\* |
| Tempo (interv.)     | \<0,001 | \*\*\* |
| Grupo:Momento       | 0,755   | ns     |
| Grupo:Tempo         | 0,467   | ns     |
| Momento:Tempo       | 0,079   | .      |
| Grupo:Momento:Tempo | 0,644   | ns     |

Mesmo padrão de prática observado no TR geral (3.5.2): queda significativa do pré para o pós-corrida (Pre: 759,1+/-148,9 ms; Pos: 663,6+/-107,7 ms; p\<0,001) e do pré para o pós-intervenção (Pre: 741,7+/-143,1 ms; Pos: 682,5+/-127,7 ms; p\<0,001). Sem efeito de Grupo (p=0,277) nem interação envolvendo Grupo (todas p\>=0,467); portanto, comparações post-hoc entre grupos não serão reportadas.

------------------------------------------------------------------------

#### 3.5.8 TR Incongruente (ms)

| Grupo | Momento (10 km) | Media  | DP     | n   |
|-------|------------------|--------|--------|-----|
| PLA   | Pre              | 824,65 | 167,72 | 19  |
| PLA   | Pos              | 723,80 | 158,92 | 19  |
| SUPL  | Pre              | 880,19 | 141,09 | 18  |
| SUPL  | Pos              | 805,68 | 118,64 | 18  |

| Efeito              | p       | Sig.   |
|---------------------|---------|--------|
| Grupo               | 0,553   | ns     |
| Momento (10 km)     | \<0,001 | \*\*\* |
| Tempo (interv.)     | \<0,001 | \*\*\* |
| Grupo:Momento       | 0,286   | ns     |
| Grupo:Tempo         | 0,217   | ns     |
| Momento:Tempo       | 0,114   | ns     |
| Grupo:Momento:Tempo | 0,819   | ns     |

Mesmo padrão de prática: queda significativa do pré para o pós-corrida (Pre: 851,7+/-155,8 ms; Pos: 763,6+/-144,9 ms; p\<0,001) e do pré para o pós-intervenção (Pre: 830,3+/-145,0 ms; Pos: 786,2+/-164,5 ms; p\<0,001). Sem efeito de Grupo (p=0,553) nem interação envolvendo Grupo (todas p\>=0,217); portanto, comparações post-hoc entre grupos não serão reportadas.

------------------------------------------------------------------------

#### 3.5.9 TR com Troca (ms)

| Grupo | Momento (10 km) | Media  | DP     | n   |
|-------|------------------|--------|--------|-----|
| PLA   | Pre              | 813,66 | 167,55 | 19  |
| PLA   | Pos              | 702,03 | 131,40 | 19  |
| SUPL  | Pre              | 862,57 | 142,87 | 18  |
| SUPL  | Pos              | 769,39 | 102,03 | 18  |

| Efeito              | p       | Sig.   |
|---------------------|---------|--------|
| Grupo               | 0,517   | ns     |
| Momento (10 km)     | \<0,001 | \*\*\* |
| Tempo (interv.)     | \<0,001 | \*\*\* |
| Grupo:Momento       | 0,516   | ns     |
| Grupo:Tempo         | 0,613   | ns     |
| Momento:Tempo       | 0,149   | ns     |
| Grupo:Momento:Tempo | 0,962   | ns     |

Mesmo padrão de prática: queda significativa do pré para o pós-corrida (Pre: 837,5+/-155,8 ms; Pos: 734,8+/-121,3 ms; p\<0,001) e do pré para o pós-intervenção (Pre: 816,2+/-147,3 ms; Pos: 757,6+/-144,8 ms; p\<0,001). Sem efeito de Grupo (p=0,517) nem interação envolvendo Grupo (todas p\>=0,516); portanto, comparações post-hoc entre grupos não serão reportadas.

------------------------------------------------------------------------

#### 3.5.10 TR sem Troca (ms)

| Grupo | Momento (10 km) | Media  | DP     | n   |
|-------|------------------|--------|--------|-----|
| PLA   | Pre              | 684,12 | 147,16 | 19  |
| PLA   | Pos              | 592,26 | 111,63 | 19  |
| SUPL  | Pre              | 776,55 | 140,84 | 18  |
| SUPL  | Pos              | 689,59 | 89,45  | 18  |

| Efeito              | p       | Sig.   |
|---------------------|---------|--------|
| Grupo               | 0,169   | ns     |
| Momento (10 km)     | \<0,001 | \*\*\* |
| Tempo (interv.)     | \<0,001 | \*\*\* |
| Grupo:Momento       | 0,815   | ns     |
| Grupo:Tempo         | 0,510   | ns     |
| Momento:Tempo       | 0,082   | .      |
| Grupo:Momento:Tempo | 0,323   | ns     |

Mesmo padrão de prática: queda significativa do pré para o pós-corrida (Pre: 729,1+/-149,6 ms; Pos: 639,6+/-111,5 ms; p\<0,001) e do pré para o pós-intervenção (Pre: 713,3+/-145,5 ms; Pos: 656,9+/-127,6 ms; p\<0,001). Sem efeito de Grupo (p=0,169) nem interação envolvendo Grupo (todas p\>=0,323); portanto, comparações post-hoc entre grupos não serão reportadas.

------------------------------------------------------------------------

### 3.6 Caracterização Dietética (Grupo x Momento, sem fator Tempo)

#### 3.6.1 Proteínas (g)

| Grupo | Momento | Media | DP   | n  |
|-------|---------|-------|------|----|
| PLA   | Pre     | 105,7 | 32,3 | 10 |
| PLA   | Pos     | 101,2 | 38,3 | 10 |
| SUPL  | Pre     | 88,9  | 33,4 | 9  |
| SUPL  | Pos     | 80,7  | 28,1 | 7  |

| Efeito        | p     | Sig. |
|---------------|-------|------|
| Grupo         | 0,197 | ns   |
| Momento       | 0,517 | ns   |
| Grupo:Momento | 0,893 | ns   |

Nenhum efeito atingiu significância estatística (todas p\>=0,197). Sem comparações post-hoc a reportar.

------------------------------------------------------------------------

#### 3.6.2 Proteínas (%)

| Grupo | Momento | Media | DP  | n  |
|-------|---------|-------|-----|----|
| PLA   | Pre     | 22,4  | 5,7 | 10 |
| PLA   | Pos     | 23,8  | 8,2 | 10 |
| SUPL  | Pre     | 20,4  | 8,1 | 9  |
| SUPL  | Pos     | 19,9  | 5,6 | 7  |

| Efeito        | p     | Sig. |
|---------------|-------|------|
| Grupo         | 0,491 | ns   |
| Momento       | 0,450 | ns   |
| Grupo:Momento | 0,885 | ns   |

Nenhum efeito atingiu significância estatística (todas p\>=0,450). Sem comparações post-hoc a reportar.

------------------------------------------------------------------------

#### 3.6.3 Carboidratos (g)

| Grupo | Momento | Media | DP   | n  |
|-------|---------|-------|------|----|
| PLA   | Pre     | 250,5 | 91,8 | 10 |
| PLA   | Pos     | 194,6 | 72,5 | 10 |
| SUPL  | Pre     | 253,1 | 102,3| 9  |
| SUPL  | Pos     | 199,6 | 65,3 | 7  |

| Efeito        | p     | Sig. |
|---------------|-------|------|
| Grupo         | 0,896 | ns   |
| Momento       | 0,066 | .    |
| Grupo:Momento | 0,966 | ns   |

Tendência de queda geral do consumo de carboidratos em gramas do período pré para o pós-intervenção (Pre: ~252 g; Pos: ~196 g; p=0,066), sem atingir significância a 5%. Sem efeito de Grupo (p=0,896) nem interação (p=0,966). Este modelo apresentou ajuste singular (variância entre participantes estimada em zero); a estimativa do efeito de Momento deve ser lida com cautela adicional. Sem comparações post-hoc a reportar.

------------------------------------------------------------------------

#### 3.6.4 Carboidratos (%)

| Grupo | Momento | Media | DP  | n  |
|-------|---------|-------|-----|----|
| PLA   | Pre     | 50,7  | 5,4 | 10 |
| PLA   | Pos     | 47,0  | 11,2| 10 |
| SUPL  | Pre     | 53,5  | 8,9 | 9  |
| SUPL  | Pos     | 48,0  | 6,3 | 7  |

| Efeito        | p     | Sig. |
|---------------|-------|------|
| Grupo         | 0,572 | ns   |
| Momento       | 0,096 | .    |
| Grupo:Momento | 0,688 | ns   |

Tendência de queda do percentual de carboidratos do período pré para o pós-intervenção (p=0,096), sem atingir significância a 5%. Sem efeito de Grupo (p=0,572) nem interação (p=0,688). Sem comparações post-hoc a reportar.

------------------------------------------------------------------------

#### 3.6.5 Lipídeos (g)

| Grupo | Momento | Media | DP   | n  |
|-------|---------|-------|------|----|
| PLA   | Pre     | 61,3  | 26,0 | 10 |
| PLA   | Pos     | 52,6  | 20,2 | 10 |
| SUPL  | Pre     | 55,2  | 23,1 | 9  |
| SUPL  | Pos     | 59,6  | 18,7 | 7  |

| Efeito        | p     | Sig. |
|---------------|-------|------|
| Grupo         | 0,948 | ns   |
| Momento       | 0,516 | ns   |
| Grupo:Momento | 0,279 | ns   |

Nenhum efeito atingiu significância estatística (todas p\>=0,279). Sem comparações post-hoc a reportar.

------------------------------------------------------------------------

#### 3.6.6 Lipídeos (%)

| Grupo | Momento | Media | DP  | n  |
|-------|---------|-------|-----|----|
| PLA   | Pre     | 27,5  | 4,5 | 10 |
| PLA   | Pos     | 25,9  | 6,7 | 10 |
| SUPL  | Pre     | 26,1  | 4,0 | 9  |
| SUPL  | Pos     | 32,0  | 7,0 | 7  |

| Efeito        | p     | Sig. |
|---------------|-------|------|
| Grupo         | 0,324 | ns   |
| Momento       | 0,136 | ns   |
| Grupo:Momento | 0,015 | \*   |

[**Comparações post-hoc:**]{.underline}

**Momento dentro de cada Grupo:**

\- PLA: Pre (27,5+/-4,5) vs. Pos (25,9+/-6,7): variação não significativa (p=0,392).

\- SUPL: Pre (26,1+/-4,0) vs. Pos (32,0+/-7,0): aumento estatisticamente significativo (p=0,0125).

**Grupo dentro de cada Momento:**

\- Pre: PLA (27,5+/-4,5) vs. SUPL (26,1+/-4,0): diferença não significativa (p=0,597).

\- Pos: PLA (25,9+/-6,7) vs. SUPL (32,0+/-7,0): diferença estatisticamente significativa (p=0,0366).

Único efeito de Grupo:Momento significativo do bloco dietético (p=0,015): o percentual de lipídeos na dieta aumentou no grupo SUPL do pré para o pós-intervenção, sem mudança correspondente no PLA, resultando em SUPL significativamente maior que PLA no período pós-intervenção.

------------------------------------------------------------------------

#### 3.6.7 Consumo Energético (kcal)

| Grupo | Momento | Media  | DP    | n  |
|-------|---------|--------|-------|----|
| PLA   | Pre     | 1952,1 | 623,3 | 10 |
| PLA   | Pos     | 1795,9 | 489,3 | 10 |
| SUPL  | Pre     | 1858,8 | 613,4 | 9  |
| SUPL  | Pos     | 1657,4 | 450,4 | 7  |

| Efeito        | p     | Sig. |
|---------------|-------|------|
| Grupo         | 0,532 | ns   |
| Momento       | 0,096 | .    |
| Grupo:Momento | 0,647 | ns   |

Tendência de queda do consumo energético total do período pré para o pós-intervenção (p=0,096), sem atingir significância a 5%, acompanhando a mesma tendência observada em carboidratos (3.6.3, 3.6.4). Sem efeito de Grupo (p=0,532) nem interação (p=0,647). Sem comparações post-hoc a reportar.

------------------------------------------------------------------------

## 4. Sintese

Das trinta e seis variáveis analisadas, a maioria mostrou apenas os efeitos principais esperados de esforco fisico como a elevação ao longo do percurso (Distância) e/ou diferença geral entre os periodos pre e pos-corrida ou pre e pos-intervenção (Momento), sem qualquer diferençaa atribuivel ao grupo de suplementação. Isso inclui pacing, sensação termica, temperatura de pele (skin-core e media), massa corporal, coloracao da urina, HGB, HCT, as seis variáveis de balanço hídrico e desempenho de medida unica (variacao de massa corporal em kg e em %, líquido ingerído, sudorese total, tempo total de prova e taxa de sudorese), oito das dez variáveis do Flanker, e seis das sete variáveis de caracterizacao dietetica. Nas oito variáveis de TR e acurácia por condição, o padrão dominante foi queda do tempo de reação tanto do pre para o pos-corrida quanto do pre para o pos-intervenção (todos p\<0,001, exceto TR — reportado em 3.5.2), compativel com efeito de pratica na tarefa cognitiva repetida, sem qualquer diferença atribuivel ao grupo. Nas variáveis dietéticas, o padrão foi de tendências não significativas de queda no consumo (carboidratos, consumo energetico) do periodo pre para o pos-intervenção, sem diferença atribuivel ao grupo.

A caracterização dietética (3.6) trouxe uma exceção: o percentual de lipídeos na dieta (3.6.6) apresentou interação Grupo:Momento significativa (p=0,015) — aumento no grupo SUPL do pré para o pós-intervenção (26,1% -\> 32,0%; p=0,0125), sem mudança no PLA (p=0,392), e diferença significativa entre grupos no período pós-intervenção (p=0,0366).

Duas variáveis do Flanker fugiram desse padrão. A acurácia congruente (3.5.3) apresentou efeito principal de Grupo estatisticamente significativo (PLA: 99,10+/-0,93; SUPL: 99,61+/-0,68; p=0,045), sem interação envolvendo Grupo que justificasse post-hoc. A acurácia sem troca (3.5.6) apresentou interação Momento:Tempo significativa (p=0,011), não relacionada a Grupo: a queda de acurácia do pre para o pos-corrida só foi significativa no período pos-intervenção (99,0 -\> 97,5; p=0,020), não no pre-intervenção (p=0,185).

Trâs variáveis apresentaram interação estatísticamente significativas envolvendo o fator Grupo. A percepcao subjetiva de esforço (PSE) apresentando destaque dentre as analises: a interação Grupo:Momento (p\<0,001) mostrou respostas opostas entre os grupos (redução da PSE no grupo placebo (12,75 para 12,08; p=0,0003) e aumento no grupo suplementado (14,91 para 15,74; p\<0,0001)) apresentando a diferençaa significativa entre grupos no periodo pos-intervencao (p=0,0063). A frequencia cardiaca apresentou padrão relacionado: interacao Grupo:Momento significativa (p=0,001), com redução da FC restrita ao grupo placebo (164,74 para 159,20 bpm; p\<0,0001) e ausência de mudança no grupo suplementado (p=0,391). A temperatura interna, mostrou o mesmo padrão: interacao Grupo:Momento significativa (p=0,005), redução ao grupo placebo (38,56 para 38,29 graus Celsius; p=0,0002) e diferença significativa entre grupos no periodo pos-intervencao (p=0,031).

A gravidade específica da urina (GEU) também apresentou interação estatísticamente significativa, neste caso com o fator Tempo de intervenção (p=0,007), aumento no PLA, p=0,0495; tendência de redução no SUPL, p=0,0546). O líquido ingerido, a sudorese total e a taxa de sudorese apresentaram efeito principal de Momento (pré/pós-intervenção) estatisticamente significativo (p=0,015; p=0,019; e p=0,010, respectivamente), sem efeito de Grupo ou interação Grupo:Momento em nenhuma das três.

------------------------------------------------------------------------

## 5. Anexos

### 5.1 Verificacao de pressupostos dos modelos

Os pressupostos de cada modelo (linearidade, homogeneidade de variancia, normalidade dos residuos, normalidade dos efeitos aleatorios, observacoes influentes e colinearidade) foram verificados visualmente por meio da funcao `check_model()` do pacote `performance`, aplicada ao modelo final de cada uma das trinta e seis variaveis. Os graficos completos estao disponiveis em `graficos-relatorio/pressupostos-<variavel>.png` e linkados na tabela abaixo; as dez variaveis do Flanker e as sete variaveis de caracterizacao dietetica sao excecao — seus graficos (`pressupostos-modelo-flanker-<variavel>.png` e `pressupostos-modelo-dieta-<variavel>.png`) ficam na raiz da pasta do projeto, nao em `graficos-relatorio/`. A verificacao visual detalhada (inclusive checagem formal de outliers via `check_outliers()`) foi feita apenas para Acuracia_percentual e TR do Flanker ate o momento (ver nota sobre o Sujeito 14 no item 2 abaixo); as oito variaveis do Flanker por condicao e as sete variaveis dieteticas ainda nao tiveram os paineis inspecionados individualmente — para a dieta, ja se sabe de um ajuste singular em Carboidratos (g) (3.6.3), citado no proprio texto daquela secao.

Nenhum dos trinta e seis modelos apresentou violacao grave e generalizada de pressupostos, com a ressalva acima de que quinze deles (oito do Flanker por condicao, sete da dieta) ainda nao foram inspecionados em detalhe. As ressalvas identificadas nos demais sao pontuais e sao consistentes com o tamanho amostral reduzido do estudo (N=19).

Dois padroes sistemicos, comuns a varios modelos, sao registrados aqui uma unica vez para nao repetir a mesma ressalva varias vezes:

1.  **Colinearidade (VIF) elevada nos termos de interacao dos modelos com fator Tempo de 9-10 niveis** (bloco 3.1: CT, FC, Pacing, PSE, ST, temperatura interna, temperatura de pele, media da temperatura de pele). O padrao e identico nos oito modelos porque decorre exclusivamente da estrutura da matriz de delineamento (fatores categoricos cruzados com muitos niveis), nao dos dados de resposta. VIF elevado em termos de interacao de um desenho fatorial e um resultado estrutural esperado e nao invalida, por si so, a inferencia sobre esses termos; por isso nao foi contabilizado como violacao de pressuposto na coluna de veredito abaixo, mas fica registrado para conhecimento do leitor.

2.  **Painel "Influential Observations" com valores numericamente extremos** em varios modelos do bloco 3.2/3.3/3.4/3.5 (massa corporal, coloracao da urina, HCT, tempo total de prova, TR do Flanker). Esses modelos tem poucas observacoes por participante (2 a 4) e, nos casos de ajuste singular, variancia entre participantes proxima de zero — condicoes que podem tornar o calculo de distancia de Cook numericamente instavel sem que isso indique, necessariamente, um dado incorreto. No caso do TR (3.5.2), `check_outliers()` (Cook, limiar 0,5) sinalizou um unico caso (Sujeito 14, Momento=Pre/Tempo=Pre, TR=1096,58 ms); trata-se do maior TR do conjunto de dados, mas consistente com a propria trajetoria decrescente das quatro medidas desse participante (1096,58 -> 853,75 -> 760,67 -> 692,17 ms) e com TR_congruente/TR_incongruente proximos entre si na mesma linha — nao ha indicio de erro de digitacao, entao o dado foi mantido.
