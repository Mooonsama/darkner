# Darkner — front-end de compilador (Flex + Bison)

Analisadores **léxico** e **sintático** para *Darkner*, uma linguagem baseada em C
com palavras reservadas inspiradas em *Deltarune* (Toby Fox). Trabalho prático da
disciplina de Compiladores da Engenharia de Computação da UFOP, feito em grupo.

**Tecnologias:** C (gnu99) · Flex · Bison (3.0+) · GNU Make · Bash

## Destaques

- **Gramática LALR(1) sem nenhum conflito** shift/reduce ou reduce/reduce.
- **Erros com linha e coluna**, mensagens do Bison traduzidas para o português e
  com dicas de contexto (ex.: bloco sem `interesting` de fechamento).
- **Recuperação de erros**: o parser continua após um erro (`error ';'`,
  `darker/iftale '(' error ')'`) e informa todos os problemas de uma vez, com a
  contagem final de erros léxicos e sintáticos.
- **Convenções de nome verificadas no léxico** (globais, locais e funções têm
  formatos diferentes). Um nome fora do padrão gera erro léxico, mas o token ainda
  é entregue ao parser para não disparar uma cascata de erros sintáticos.
- **Suíte de testes automatizada**: 14 programas (5 válidos, 9 com erros léxicos
  e sintáticos), conferidos pelo código de saída.

## Como compilar e executar

Requisitos: `flex`, `bison` (3.0 ou superior), `gcc` e `make`. No Windows, funciona
com MSYS2 ou WSL.

```bash
make                         # gera ./darkner
./darkner programa.dr        # analisa um programa
./darkner -t programa.dr     # idem, listando cada token reconhecido
make test                    # roda todos os testes (testes/validos e testes/erros)
make clean                   # remove o binário e os arquivos gerados
```

Saída para um programa válido:

```
Analise lexica concluida.
Analise sintatica concluida.
Programa reconhecido com sucesso.
```

Saída para um programa inválido (`testes/erros/02_lexico_nomes_invalidos.dr`),
com código de saída 1:

```
[ERRO LEXICO] linha 2, coluna 6: identificador fora das convencoes de nome 'Soma_Total'
[ERRO LEXICO] linha 4, coluna 6: identificador fora das convencoes de nome 'calcular_Dobro'
[ERRO LEXICO] linha 10, coluna 10: identificador fora das convencoes de nome 'Valor'
[ERRO SINTATICO] linha 10, coluna 10 (proximo a 'Valor'): erro de sintaxe, encontrado identificador global, esperado identificador local
[ERRO LEXICO] linha 11, coluna 10: identificador fora das convencoes de nome '_temp'
Programa NAO reconhecido: 4 erro(s) lexico(s), 1 erro(s) sintatico(s).
```

## A linguagem

| C                         | Darkner                                       |
|---------------------------|-----------------------------------------------|
| `int main() { ... }`      | `very ... interesting`                        |
| `if (c) { ... }`          | `darker (c) ... interesting`                  |
| `if (c) {...} else {...}` | `darker (c) ... yet ... interesting`          |
| `while (c) { ... }`       | `iftale (c) ... interesting`                  |
| `int`                     | `king`                                        |
| `char`                    | `tenna`                                       |
| `float`                   | `queen`                                       |
| `double`                  | `flowery`                                     |
| `void`                    | `knight`                                      |
| `return x;`               | `bigshot x;`                                  |
| `printf(...)`             | `spamton("texto", expr, ...);`                |
| `int f(int a) { ... }`    | `king fazerAlgo(king a) very ... interesting` |

Instruções terminam em `;`, como em C. Chaves `{ }` não existem na linguagem
(são erro léxico). Comentários `//` e `/* */`; literais inteiros, reais, caractere
e string.

Convenções de nome (verificadas pelo léxico e pela gramática):

* **globais**: só maiúsculas, dígitos e `_`, como `SOMA_TOTAL` (declaradas apenas no topo do programa)
* **locais e parâmetros**: só minúsculas, dígitos e `_`, como `soma_parcial`
* **funções**: verbo minúsculo + termo com inicial maiúscula, como `calcularSoma`

Exemplo:

```
king SOMA;

king calcularSoma(king a, king b)
very
    bigshot a + b;
interesting

very
    king x = 10, y = 20;
    SOMA = calcularSoma(x, y);
    darker (SOMA > 20)
        spamton("maior que 20: ", SOMA);
    yet
        spamton("pequeno");
    interesting
    iftale (x < SOMA)
        x = x + 1;
    interesting
interesting
```

## Estrutura

```
lexer.l          analisador léxico (Flex): tokens, convenções de nome, posição linha/coluna
parser.y         gramática, tratamento e recuperação de erros, main (Bison)
Makefile
run_tests.sh     roda todos os testes e confere o resultado esperado
testes/validos/  programas que devem ser aceitos
testes/erros/    programas com erros léxicos e sintáticos
```

Escopo desta etapa: análise léxica e sintática. Análise semântica e geração de
código não fazem parte do projeto.
