/* ==========================================================================
 *  parser.y  -  Analisador SINTATICO da linguagem DARKNER
 *
 *  Gerado com:  bison -d parser.y
 * ========================================================================== */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int   yylex(void);
extern FILE *yyin;
extern char *yytext;
extern int   tok_linha, tok_coluna;
extern int   erros_lexicos;
extern int   mostrar_tokens;

int erros_sintaticos = 0;

void yyerror(const char *msg);
%}

/* Mensagens de erro detalhadas: "unexpected X, expecting Y or Z" */
%define parse.error verbose

/* ------------------------------ Tokens ------------------------------ */
/* O texto entre aspas e o nome mostrado nas mensagens de erro         */
%token VERY        "very"
%token INTERESTING "interesting (fim de bloco)"
%token IF          "darker"
%token YET       "yet"
%token IFTALE    "iftale"
%token BIGSHOT   "bigshot"
%token SPAMTON   "spamton"

%token KING      "king"
%token TENNA     "tenna"
%token QUEEN     "queen"
%token FLOWERY   "flowery"
%token KNIGHT    "knight"

%token ID_GLOBAL "identificador global"
%token ID_LOCAL  "identificador local"
%token ID_FUNCAO "nome de funcao"

%token NUM_INT   "numero inteiro"
%token NUM_REAL  "numero real"
%token CARACTERE "caractere"
%token STRING    "string"

%token IGUAL     "=="
%token DIFERENTE "!="
%token MENOR_IG  "<="
%token MAIOR_IG  ">="
%token E_LOGICO  "&&"
%token OU_LOGICO "||"

/* --------------------- Precedencia (menor -> maior) ------------------ */
%left  OU_LOGICO
%left  E_LOGICO
%left  IGUAL DIFERENTE
%left  '<' '>' MENOR_IG MAIOR_IG
%left  '+' '-'
%left  '*' '/' '%'
%precedence '!' UMENOS

%start programa

%%

/* ===================== Estrutura geral do programa ===================== */
/* Declaracoes globais e funcoes, terminando com o bloco principal (main) */
programa
    : itens_topo bloco_principal
    ;

itens_topo
    : %empty
    | itens_topo item_topo
    ;

item_topo
    : declaracao_global
    | definicao_funcao
    | error ';'                     { yyerrok; }
    ;

/* main:  very  <instrucoes>  interesting */
bloco_principal
    : VERY instrucoes INTERESTING
    ;

/* ============================ Declaracoes ============================== */
tipo_var
    : KING
    | TENNA
    | QUEEN
    | FLOWERY
    ;

tipo_retorno
    : tipo_var
    | KNIGHT
    ;

/* Globais so podem usar nomes MAIUSCULOS:   king SOMA, TOTAL = 0; */
declaracao_global
    : tipo_var lista_globais ';'
    ;

lista_globais
    : item_global
    | lista_globais ',' item_global
    ;

item_global
    : ID_GLOBAL
    | ID_GLOBAL '=' expressao
    ;

/* Locais so podem usar nomes minusculos:    king x, y = 2; */
declaracao_local
    : tipo_var lista_locais ';'
    ;

lista_locais
    : item_local
    | lista_locais ',' item_local
    ;

item_local
    : ID_LOCAL
    | ID_LOCAL '=' expressao
    ;

/* ============================== Funcoes ================================ */
/*  king calcularSoma(king a, king b)
 *  very
 *      ...
 *  interesting                                                         */
definicao_funcao
    : tipo_retorno ID_FUNCAO '(' parametros ')' VERY instrucoes INTERESTING
    ;

parametros
    : %empty
    | KNIGHT
    | lista_parametros
    ;

lista_parametros
    : parametro
    | lista_parametros ',' parametro
    ;

parametro
    : tipo_var ID_LOCAL
    ;

/* ============================= Instrucoes ============================== */
instrucoes
    : %empty
    | instrucoes instrucao
    ;

instrucao
    : declaracao_local
    | atribuicao ';'
    | chamada_funcao ';'
    | condicional
    | repeticao
    | retorno ';'
    | impressao ';'
    | error ';'                     { yyerrok; }
    ;

atribuicao
    : variavel '=' expressao
    ;

variavel
    : ID_LOCAL
    | ID_GLOBAL
    ;

/* if:      darker(cond) ... interesting
 * if-else: darker(cond) ... yet ... interesting                          */
condicional
    : IF '(' expressao ')' instrucoes INTERESTING
    | IF '(' expressao ')' instrucoes YET instrucoes INTERESTING
    | IF '(' error ')' instrucoes INTERESTING                  { yyerrok; }
    | IF '(' error ')' instrucoes YET instrucoes INTERESTING   { yyerrok; }
    ;

/* while:   iftale(cond) ... interesting                                   */
repeticao
    : IFTALE '(' expressao ')' instrucoes INTERESTING
    | IFTALE '(' error ')' instrucoes INTERESTING              { yyerrok; }
    ;

/* return:  bigshot expr;   ou   bigshot;                                  */
retorno
    : BIGSHOT expressao
    | BIGSHOT
    ;

/* print:   spamton("texto", expr, ...);                                   */
impressao
    : SPAMTON '(' lista_impressao ')'
    ;

lista_impressao
    : item_impressao
    | lista_impressao ',' item_impressao
    ;

item_impressao
    : expressao
    | STRING
    ;

chamada_funcao
    : ID_FUNCAO '(' argumentos ')'
    ;

argumentos
    : %empty
    | lista_argumentos
    ;

lista_argumentos
    : expressao
    | lista_argumentos ',' expressao
    ;

/* ============================= Expressoes ============================== */
expressao
    : expressao OU_LOGICO expressao
    | expressao E_LOGICO  expressao
    | expressao IGUAL     expressao
    | expressao DIFERENTE expressao
    | expressao '<'       expressao
    | expressao '>'       expressao
    | expressao MENOR_IG  expressao
    | expressao MAIOR_IG  expressao
    | expressao '+'       expressao
    | expressao '-'       expressao
    | expressao '*'       expressao
    | expressao '/'       expressao
    | expressao '%'       expressao
    | '!' expressao
    | '-' expressao %prec UMENOS
    | '(' expressao ')'
    | variavel
    | chamada_funcao
    | NUM_INT
    | NUM_REAL
    | CARACTERE
    ;

%%

/* ---------------------------------------------------------------------- */
/* Substitui todas as ocorrencias de 'de' por 'para' em 'buf'             */
static void trocar(char *buf, size_t cap, const char *de, const char *para)
{
    char saida[1024] = "";
    char *p = buf, *q;
    size_t ld = strlen(de);
    while ((q = strstr(p, de)) != NULL) {
        strncat(saida, p, (size_t)(q - p));
        strcat(saida, para);
        p = q + ld;
    }
    strcat(saida, p);
    strncpy(buf, saida, cap - 1);
    buf[cap - 1] = '\0';
}

/* Traduz a mensagem do Bison para portugues e mostra linha/coluna */
void yyerror(const char *msg)
{
    char buf[1024];
    erros_sintaticos++;

    strncpy(buf, msg, sizeof buf - 1);
    buf[sizeof buf - 1] = '\0';
    trocar(buf, sizeof buf, "syntax error", "erro de sintaxe");
    trocar(buf, sizeof buf, "unexpected", "encontrado");
    trocar(buf, sizeof buf, "expecting", "esperado");
    trocar(buf, sizeof buf, " or ", " ou ");
    trocar(buf, sizeof buf, "end of file", "fim do arquivo");

    if (yytext && yytext[0] != '\0')
        fprintf(stderr, "[ERRO SINTATICO] linha %d, coluna %d (proximo a '%s'): %s\n",
                tok_linha, tok_coluna, yytext, buf);
    else
        fprintf(stderr, "[ERRO SINTATICO] fim do arquivo: %s "
                        "(algum bloco very/darker/iftale ficou sem o 'interesting' "
                        "de fechamento, ou falta o bloco principal?)\n", buf);
}

int main(int argc, char **argv)
{
    const char *arquivo = NULL;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-t") == 0) mostrar_tokens = 1;
        else arquivo = argv[i];
    }

    if (arquivo == NULL) {
        fprintf(stderr, "Uso: %s [-t] <arquivo.dr>\n", argv[0]);
        fprintf(stderr, "  -t  mostra a lista de tokens reconhecidos\n");
        return 2;
    }

    yyin = fopen(arquivo, "r");
    if (!yyin) {
        perror(arquivo);
        return 2;
    }

    if (mostrar_tokens) printf("Tokens reconhecidos:\n");

    int r = yyparse();
    fclose(yyin);

    if (r == 0 && erros_lexicos == 0 && erros_sintaticos == 0) {
        printf("Analise lexica concluida.\n");
        printf("Analise sintatica concluida.\n");
        printf("Programa reconhecido com sucesso.\n");
        return 0;
    }

    printf("Programa NAO reconhecido: %d erro(s) lexico(s), %d erro(s) sintatico(s).\n",
           erros_lexicos, erros_sintaticos);
    return 1;
}
