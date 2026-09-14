# Pasta learning

Esta pasta contém exemplos didáticos para quem quer aprender a fazer o mesmo tipo de análise usada no restante deste repositório, sem precisar entender o estudo inteiro primeiro nem depender de nenhum dado real do projeto.

Os dois scripts abaixo geram seus próprios dados fictícios internamente, então podem ser copiados para fora deste repositório e rodados sozinhos, em qualquer lugar, desde que os pacotes de R listados no início de cada um estejam instalados.

## Qual exemplo usar

- `exemplo-anova-2way.R`: use quando cada participante tem uma única medida por Momento, por exemplo, um valor antes de uma intervenção e um valor depois dela, sem nenhuma outra dimensão repetida dentro do mesmo Momento.
- `exemplo-anova-3way.R`: use quando, além do Grupo e do Momento, existe uma terceira dimensão medida repetidamente dentro do mesmo Momento, por exemplo, vários trechos de um percurso, várias tentativas de uma tarefa, ou um segundo período de intervenção dentro do mesmo estudo.

Os dois scripts têm praticamente todas as linhas comentadas, explicando o que cada trecho faz e, quando relevante, por que ele é feito daquele jeito. No fim de cada script há uma seção chamada "para adaptar este script para os seus próprios dados", com um passo a passo de como trocar os dados fictícios pelos seus dados reais.

## Por que modelo linear misto em vez de ANOVA

Os dois exemplos usam modelo linear misto (LMM), ajustado com a função `lmer()` do pacote `lme4`, como alternativa à ANOVA de medidas repetidas ou à ANOVA mista clássica. Essa é a mesma abordagem usada em todos os scripts da pasta `scripts/` deste repositório, pelos mesmos dois motivos: o LMM lida bem com grupos de tamanhos diferentes (não exige balanceamento) e com dados faltantes (não descarta um participante inteiro por causa de uma medida ausente), duas situações em que a ANOVA clássica perde validade ou exige exclusão de participantes. A tabela de significância dos efeitos que o LMM produz (a chamada ANOVA Tipo III, com aproximação de graus de liberdade de Satterthwaite) é a que substitui a tabela de ANOVA tradicional, e é para essa tabela que os títulos "anova 2 vias" e "anova 3 vias" desta pasta se referem.

Mais detalhes sobre essa escolha metodológica, incluindo a fórmula usada em cada caso e o critério para quando reportar comparações post hoc, estão na seção "Abordagem estatística" do README principal deste repositório, na raiz do projeto.

## Como rodar

A partir da raiz do repositório:

```
Rscript learning/exemplo-anova-2way.R
Rscript learning/exemplo-anova-3way.R
```

Cada script imprime no console o resumo do modelo, a tabela de significância dos efeitos, as médias ajustadas, as comparações post hoc, e abre um painel de gráficos de pressupostos do modelo mais um ou mais gráficos das médias ajustadas. Nenhum arquivo é salvo em disco por padrão: os comentários dentro de cada script mostram como usar `ggsave()` para salvar os gráficos, se você quiser.

## O que os dados fictícios representam

Em `exemplo-anova-2way.R`, os dados fictícios simulam um Grupo A e um Grupo B (de tamanhos diferentes de propósito), cada um medido em dois Momentos (Pre e Pos), com uma queda maior no Grupo B do Pre para o Pos, para que a interação Grupo:Momento apareça como estatisticamente significativa no resultado, dando um exemplo concreto de quando vale a pena decompor a interação com comparações post hoc.

Em `exemplo-anova-3way.R`, os dados fictícios seguem a mesma lógica, mas com um terceiro fator, Tempo, com dois níveis. Apenas a interação Grupo:Momento foi construída para ser significativa; as interações que envolvem Tempo foram deixadas sem nenhum efeito planejado, para servir de exemplo de como a tabela de ANOVA aparece quando uma interação não é significativa.
