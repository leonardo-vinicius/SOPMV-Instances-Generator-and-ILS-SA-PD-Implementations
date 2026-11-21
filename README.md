# Repositório de instâncias e algoritmos para o SOPMV

Este repositório reúne os artefatos computacionais associados aos experimentos
do **SOPMV** (*Set Orienteering Problem with Mandatory Visits*): instâncias
SOP e SOPMV, um gerador de variantes com conjuntos obrigatórios, uma
implementação de *Iterated Local Search* (ILS) e uma reimplementação
independente de SA-PD. Há também uma heurística gulosa e o código do modelo
exato baseado em CPLEX.

O objetivo é permitir a reprodução, a auditoria e a extensão dos experimentos.

## Referência acadêmica e atribuição

As instâncias SOPMV produzidas neste repositório, a reimplementação independente
do SA-PD e partes da formulação MILP em `algorithms/cplex/` foram inspiradas em
Lin, Guo e Wu (2024). Esta é uma implementação independente: ela não reutiliza
código dos autores. O PDF consultado no projeto de pesquisa encontra-se em
`/home/leo/tcc_sopmv/docs/referencias/lin_guo_wu_2024.pdf`.

> Lin, S.-W.; Guo, S.; Wu, W.-J. *Applying the Simulated Annealing Algorithm
> to the Set Orienteering Problem with Mandatory Visits*. **Mathematics**,
> 2024, 12(19), 3089. https://doi.org/10.3390/math12193089

Ao utilizar ou estender estes artefatos, cite o artigo acima e a versão/commit
deste repositório empregada no experimento.

## Conteúdo

- `small_instances/`: instâncias de menor porte. `sop/` contém as instâncias
  SOP de origem e `sopmv_10/`, `sopmv_20/` e `sopmv_30/` as variantes com,
  respectivamente, 10%, 20% e 30% dos conjuntos lucrativos obrigatórios.
- `large_instances/`: instâncias de maior porte, organizadas de forma análoga.
  Nesta coleção, os diretórios das variantes são chamados `sopmv10/`,
  `sopmv20/` e `sopmv30/`.
- `scripts/generate_instances_sopmv.py`: gerador em Python das variantes
  SOPMV em formato `.sop`.
- `algorithms/ils/`: implementação do ILS.
- `algorithms/sa_pd/`: reimplementação independente do SA-PD.
- `algorithms/greedy/`: heurística de inserção gulosa, útil também para
  inspeção e testes.
- `algorithms/core/`: leitura de instâncias, cálculo de distâncias e
  validação de soluções.
- `algorithms/cplex/`: modelo exato que depende de uma instalação local do
  IBM ILOG CPLEX.

## Requisitos

- Python 3.9 ou superior para o gerador (somente biblioteca padrão);
- compilador C++ compatível com C++17, como `g++` 9+ ou `clang++` 10+;
- `make` para usar os comandos de compilação abaixo.

CPLEX é opcional e não é necessário para gerar instâncias nem para compilar
ILS, SA-PD e a heurística gulosa.

## Compilação

Na raiz do repositório, execute:

```bash
make
```

Os executáveis são produzidos em `bin/`:

```text
bin/sopmv-generator
bin/sopmv-greedy
bin/sopmv-ils
bin/sopmv-sa-pd
```

Para remover os executáveis, use `make clean`.

## Geração de instâncias SOPMV

O gerador **não contém caminhos fixos do computador do autor**. Informe sempre
a pasta das instâncias SOP de origem e a pasta em que deseja gravar as
variantes. Caminhos relativos são interpretados a partir do diretório de onde
o comando é executado; caminhos absolutos também são aceitos.

Exemplo para gerar as três variantes a partir das instâncias pequenas e gravá-
las em uma pasta nova:

```bash
python3 scripts/generate_instances_sopmv.py \
  --origem small_instances/sop \
  --raiz-saida resultados-gerados \
  --somente-viaveis \
  --semente 202601
```

O comando cria `resultados-gerados/sopmv_10`,
`resultados-gerados/sopmv_20` e `resultados-gerados/sopmv_30`. Para alterar
os nomes dessas pastas, use `--pastas-saida NOME_10 NOME_20 NOME_30`.
Arquivos existentes não são substituídos; use `--sobrescrever` apenas quando
isso for intencional.

O gerador cria 10%, 20% e 30% de conjuntos obrigatórios entre os conjuntos
lucrativos. A escolha é determinística para uma mesma semente e os mesmos
arquivos de entrada.

### Verificação construtiva de viabilidade

Use `--somente-viaveis` — ou o sinônimo `--validate` — para reamostrar os
conjuntos obrigatórios até obter uma rota testemunha gulosa com comprimento
menor ou igual a `TMAX`:

```bash
python3 scripts/generate_instances_sopmv.py \
  --origem small_instances/sop \
  --raiz-saida resultados-validados \
  --validate --semente 202601 --tentativas-maximas 1000
```

Esta opção fornece uma **evidência construtiva de viabilidade** para cada
instância produzida: a rota gulosa visita o depósito, um representante de cada
conjunto obrigatório e retorna ao depósito sem exceder `TMAX`. Não é uma prova
de que todas as escolhas aleatórias seriam viáveis nem de otimalidade. Sem a
opção, o sorteio aleatório é mantido, o que permite reproduzir o procedimento
sem filtragem.

Execute `python3 scripts/generate_instances_sopmv.py --help` para a referência
completa de argumentos.

## Execução e validação de soluções

As instâncias SOPMV já contêm a coluna `mandatory` em `GTSP_SET_SECTION`; por
isso, passe o arquivo `.sop` diretamente aos executáveis. Exemplos:

```bash
bin/sopmv-greedy --instance small_instances/sopmv_10/11eil51_T40_p1.sop \
  --csv resultados_guloso.csv

bin/sopmv-ils --instance small_instances/sopmv_10/11eil51_T40_p1.sop \
  --ils-time-limit 10 --seed 202601 --csv resultados_ils.csv

bin/sopmv-sa-pd --instance small_instances/sopmv_10/11eil51_T40_p1.sop \
  --sa-time-limit 10 --seed 202601 --csv resultados_sa_pd.csv
```

Cada executável valida a solução retornada: confere depósito, rota,
representantes, conjuntos obrigatórios e limite `TMAX`. O resultado e o
diagnóstico do validador são impressos no terminal e registrados no CSV.
Use `--help` em cada executável para consultar parâmetros específicos.

## Reprodutibilidade

Para reproduzir uma geração, registre pelo menos: versão/commit do repositório,
comando completo, semente, instâncias de origem e se `--somente-viaveis`
(`--validate`) foi usado. Para reproduzir uma execução heurística, registre
também o limite de tempo e todos os parâmetros do método.

## Observações sobre CPLEX

O diretório `algorithms/cplex/` é mantido para transparência, mas sua
compilação requer CPLEX instalado e configurado de acordo com o sistema local;
por isso ele não integra o `Makefile` padrão. A distribuição e o uso do CPLEX
estão sujeitos à licença da IBM.

## Antes de publicar

O código deste repositório é disponibilizado sob a [licença MIT](LICENSE).
Confirme separadamente a licença e a atribuição permitidas para cada coleção
de instâncias de origem, pois elas podem não estar cobertas pela licença do
código. Recomenda-se também adicionar uma citação do trabalho associado
(arquivo `CITATION.cff`) após definir título, autores, ano, DOI ou URL.

---

# SOPMV instance and algorithm repository

This repository contains the computational artifacts associated with the
**SOPMV** (*Set Orienteering Problem with Mandatory Visits*) experiments:
SOP and SOPMV instances, a generator for variants with mandatory sets, an
*Iterated Local Search* (ILS) implementation, and an independent SA-PD
reimplementation. It also includes a greedy heuristic and the source code of
an exact CPLEX-based model.

Its purpose is to support reproduction, auditing, and extension of the
experiments.

## Academic reference and attribution

The SOPMV instances generated in this repository, the independent SA-PD
reimplementation, and parts of the MILP formulation in `algorithms/cplex/`
were inspired by Lin, Guo, and Wu (2024). This is an independent
implementation; it does not reuse the authors' code. The PDF consulted in the
research project is available locally at
`/home/leo/tcc_sopmv/docs/referencias/lin_guo_wu_2024.pdf`.

> Lin, S.-W.; Guo, S.; Wu, W.-J. *Applying the Simulated Annealing Algorithm
> to the Set Orienteering Problem with Mandatory Visits*. **Mathematics**,
> 2024, 12(19), 3089. https://doi.org/10.3390/math12193089

When using or extending these artifacts, please cite the paper above and the
repository version/commit used in the experiment.

## Contents

- `small_instances/`: small instances. `sop/` holds the original SOP files;
  `sopmv_10/`, `sopmv_20/`, and `sopmv_30/` hold variants with 10%, 20%, and
  30% mandatory profitable sets, respectively.
- `large_instances/`: larger instances, arranged in the same way. In this
  collection, variant directories are named `sopmv10/`, `sopmv20/`, and
  `sopmv30/`.
- `scripts/generate_instances_sopmv.py`: Python generator for SOPMV `.sop`
  variants.
- `algorithms/ils/`: ILS implementation.
- `algorithms/sa_pd/`: independent SA-PD reimplementation.
- `algorithms/greedy/`: greedy insertion heuristic, also useful for inspection
  and tests.
- `algorithms/core/`: instance parser, distance calculations, and solution
  validation.
- `algorithms/cplex/`: exact model requiring a local IBM ILOG CPLEX
  installation.

## Requirements

- Python 3.9+ for the generator (standard library only);
- a C++17 compiler, such as `g++` 9+ or `clang++` 10+;
- `make` for the build commands below.

CPLEX is optional; it is not needed to generate instances or build ILS, SA-PD,
and the greedy heuristic.

## Build

From the repository root, run:

```bash
make
```

Executables are written to `bin/`:

```text
bin/sopmv-generator
bin/sopmv-greedy
bin/sopmv-ils
bin/sopmv-sa-pd
```

Run `make clean` to remove the executables.

## Generating SOPMV instances

The generator has **no author-machine-specific paths**. Always provide the
input SOP directory and the directory where variants should be written.
Relative paths are interpreted from the directory in which the command is run;
absolute paths are also accepted.

Example: generate all three variants from small SOP instances into a new
directory:

```bash
python3 scripts/generate_instances_sopmv.py \
  --origem small_instances/sop \
  --raiz-saida generated-results \
  --somente-viaveis \
  --semente 202601
```

The command creates `generated-results/sopmv_10`,
`generated-results/sopmv_20`, and `generated-results/sopmv_30`. To change
these directory names, use `--pastas-saida NAME_10 NAME_20 NAME_30`. Existing
files are never replaced unless `--sobrescrever` is explicitly supplied.

The generator creates 10%, 20%, and 30% mandatory sets among profitable sets.
Selection is deterministic given the same seed and input files.

### Constructive feasibility check

Use `--somente-viaveis` — or its alias `--validate` — to resample mandatory
sets until a greedy witness route whose length is at most `TMAX` is found:

```bash
python3 scripts/generate_instances_sopmv.py \
  --origem small_instances/sop \
  --raiz-saida validated-results \
  --validate --semente 202601 --tentativas-maximas 1000
```

This option gives **constructive evidence of feasibility** for every generated
instance: the greedy route visits the depot, one representative of every
mandatory set, and returns to the depot without exceeding `TMAX`. It is not a
proof that every random selection is feasible or that the route is optimal.
Without this option, random selection remains unfiltered, enabling replication
of the procedure without feasibility filtering.

Run `python3 scripts/generate_instances_sopmv.py --help` for the full argument
reference.

## Running and validating solutions

SOPMV files already contain the `mandatory` column in `GTSP_SET_SECTION`; pass
the `.sop` file directly to the executable. Examples:

```bash
bin/sopmv-greedy --instance small_instances/sopmv_10/11eil51_T40_p1.sop \
  --csv greedy_results.csv

bin/sopmv-ils --instance small_instances/sopmv_10/11eil51_T40_p1.sop \
  --ils-time-limit 10 --seed 202601 --csv ils_results.csv

bin/sopmv-sa-pd --instance small_instances/sopmv_10/11eil51_T40_p1.sop \
  --sa-time-limit 10 --seed 202601 --csv sa_pd_results.csv
```

Every executable validates its returned solution, checking the depot, route,
representatives, mandatory sets, and `TMAX`. The result and validator message
are printed to the terminal and stored in the CSV. Use `--help` on each binary
for method-specific parameters.

## Reproducibility

To reproduce an instance-generation run, record at least the repository
version/commit, full command, seed, input instances, and whether
`--somente-viaveis` (`--validate`) was used. To reproduce a heuristic run,
also record the time limit and every method parameter.

## CPLEX note

`algorithms/cplex/` is provided for transparency, but compiling it requires a
locally installed and configured CPLEX, so it is intentionally excluded from
the default `Makefile`. CPLEX distribution and use are governed by IBM's
license.

## Before publishing

The code in this repository is released under the [MIT License](LICENSE).
Verify separately the permitted license and attribution for every source
instance collection, as they may not be covered by the software license. After
setting the title, authors, year, DOI, or project URL, also add a
`CITATION.cff` file for the associated work.
