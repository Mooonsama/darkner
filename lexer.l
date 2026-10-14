/* ==========================================================================
 *  lexer.l  -  Analisador LEXICO da linguagem DARKNER
 *  (linguagem baseada em C com palavras reservadas inspiradas em Deltarune)
 *
 *  Gerado com:  flex lexer.l
 * ========================================================================== */

%{
#include <stdio.h>
#include <string.h>
#include "parser.tab.h"

/* Controle de posicao (linha/coluna) para as mensagens de erro */
int coluna       = 1;   /* coluna do PROXIMO caractere a ser lido   */
int tok_linha    = 1;   /* linha do ultimo token reconhecido        */
int tok_coluna   = 1;   /* coluna do ultimo token reconhecido       */
int erros_lexicos = 0;
int mostrar_tokens = 0; /* ligado pela opcao -t no main             */
int com_linha, com_coluna; /* onde abriu o ultimo comentario de bloco */

/* Antes de cada acao: guarda a posicao do token e avanca a coluna */
#define YY_USER_ACTION                                   \
    tok_linha  = yylineno;                               \
    tok_coluna = coluna;                                 \
    for (int i_ = 0; i_ < yyleng; i_++) {                \
        if (yytext[i_] == '\n') coluna = 1;              \
        else coluna++;                                   \
    }

/* Retorna o token e, se pedido (-t), imprime-o */
#define RET(tok, categoria)                                              \
    do {                                                                 \
        if (mostrar_tokens)                                              \
            printf("  [%3d:%-3d] %-18s %s\n", tok_linha, tok_coluna,     \
                   categoria, yytext);                                   \
        return tok;                                                      \
    } while (0)

static void erro_lexico(const char *msg)
{
    erros_lexicos++;
    fprintf(stderr, "[ERRO LEXICO] linha %d, coluna %d: %s '%s'\n",
            tok_linha, tok_coluna, msg, yytext);
}

static int classificar_invalido(const char *t)
{
    if (t[0] >= 'A' && t[0] <= 'Z') return ID_GLOBAL;
    if (t[0] >= 'a' && t[0] <= 'z')
        for (const char *p = t; *p; p++)
            if (*p >= 'A' && *p <= 'Z') return ID_FUNCAO;
    return ID_LOCAL;
}
%}

%option noyywrap
%option yylineno
%option nounput
%option noinput

%x COMENTARIO

/* ---------------------- Definicoes regulares ---------------------- */
DIGITO      [0-9]
MAIUSC      [A-Z]
MINUSC      [a-z]
LETRA       [a-zA-Z]
NAO_ASCII   [\x80-\xFF]

/* Convencoes de nomes exigidas pelo trabalho                         */
/*  - variavel GLOBAL : so maiusculas, digitos e '_'  (ex.: SOMA_TOTAL) */
/*  - variavel LOCAL  : so minusculas, digitos e '_'  (ex.: soma_parcial)*/
/*  - FUNCAO          : verbo minusculo + termo iniciado por maiuscula  */
/*                      (ex.: calcularSoma, exibirResultado)            */
ID_GLOBAL   {MAIUSC}({MAIUSC}|{DIGITO}|_)*
ID_LOCAL    {MINUSC}({MINUSC}|{DIGITO}|_)*
ID_FUNCAO   {MINUSC}+{MAIUSC}({LETRA}|{DIGITO})*

/* Qualquer "palavra" que nao se encaixe nas regras acima e invalida  */
/* (inclui letras acentuadas no meio do nome, ex.: media com acento)   */
ID_QUALQUER ({LETRA}|_)({LETRA}|{DIGITO}|_|{NAO_ASCII})*

NUM_INT     {DIGITO}+
NUM_REAL    {DIGITO}+"."{DIGITO}+
NUM_RUIM    {DIGITO}+({LETRA}|_)({LETRA}|{DIGITO}|_)*

CARACTERE   \'([^'\\\n]|\\.)\'
STRING      \"([^"\\\n]|\\.)*\"

%%

 /* ------------------------- Espacos e comentarios ------------------ */
[ \t\r]+                ;
\n                      ;
"//".*                  ;
"/*"                    { com_linha = tok_linha; com_coluna = tok_coluna;
                          BEGIN(COMENTARIO); }
<COMENTARIO>"*/"        { BEGIN(INITIAL); }
<COMENTARIO>\n          ;
<COMENTARIO>.           ;
<COMENTARIO><<EOF>>     { tok_linha = com_linha; tok_coluna = com_coluna;
                          yytext = "/*";
                          erro_lexico("comentario de bloco nao fechado");
                          BEGIN(INITIAL); return 0; }

 /* ------------------------- Palavras reservadas -------------------- */
 /* Blocos: very ... interesting  (equivalem a { ... } em C)        */
"very"                  RET(VERY, "VERY");
"interesting"           RET(INTERESTING, "INTERESTING (fim)");

 /* Comandos: darker(c) ... yet ... interesting = if/else              */
"darker"                RET(IF, "IF (darker)");
"yet"                   RET(YET, "YET (else)");
"iftale"                RET(IFTALE, "IFTALE (while)");
"bigshot"               RET(BIGSHOT, "BIGSHOT (return)");
"spamton"               RET(SPAMTON, "SPAMTON (print)");

 /* Tipos */
"king"                  RET(KING,    "TIPO int");
"tenna"                 RET(TENNA,   "TIPO char");
"queen"                 RET(QUEEN,   "TIPO float");
"flowery"               RET(FLOWERY, "TIPO double");
"knight"                RET(KNIGHT,  "TIPO void");

 /* ------------------------- Identificadores ------------------------ */
{ID_GLOBAL}             RET(ID_GLOBAL, "ID_GLOBAL");
{ID_LOCAL}              RET(ID_LOCAL,  "ID_LOCAL");
{ID_FUNCAO}             RET(ID_FUNCAO, "ID_FUNCAO");
 /* Nome fora das convencoes: e um ERRO LEXICO. Para nao gerar uma
  * cascata de erros sintaticos, o token ainda e entregue ao parser com
  * a categoria mais provavel pelo formato do nome:
  *   comeca com maiuscula                -> global   (ex.: Soma_Total)
  *   comeca minuscula e tem maiuscula    -> funcao   (ex.: calcular_Soma)
  *   resto                               -> local    (ex.: _temp)        */
{ID_QUALQUER}           { erro_lexico("identificador fora das convencoes de nome");
                          return classificar_invalido(yytext); }

 /* ------------------------- Literais ------------------------------- */
 /* (literais mal formados geram erro lexico, mas ainda sao entregues
  *  ao parser para evitar erros sintaticos em cascata)                 */
{NUM_REAL}              RET(NUM_REAL, "NUM_REAL");
{NUM_INT}               RET(NUM_INT,  "NUM_INT");
{NUM_RUIM}              { erro_lexico("numero mal formado"); return NUM_INT; }
{CARACTERE}             RET(CARACTERE, "CARACTERE");
{STRING}                RET(STRING,    "STRING");
\'([^'\\\n]|\\.)*\'?    { erro_lexico("literal de caractere invalido"); return CARACTERE; }
\"([^"\\\n]|\\.)*       { erro_lexico("string nao fechada"); return STRING; }

 /* ------------------------- Operadores ----------------------------- */
"=="                    RET(IGUAL,     "OP_REL");
"!="                    RET(DIFERENTE, "OP_REL");
"<="                    RET(MENOR_IG,  "OP_REL");
">="                    RET(MAIOR_IG,  "OP_REL");
"<"                     RET('<',       "OP_REL");
">"                     RET('>',       "OP_REL");
"&&"                    RET(E_LOGICO,  "OP_LOGICO");
"||"                    RET(OU_LOGICO, "OP_LOGICO");
"!"                     RET('!',       "OP_LOGICO");
"+"                     RET('+',       "OP_ARIT");
"-"                     RET('-',       "OP_ARIT");
"*"                     RET('*',       "OP_ARIT");
"/"                     RET('/',       "OP_ARIT");
"%"                     RET('%',       "OP_ARIT");
"="                     RET('=',       "ATRIBUICAO");

 /* ------------------------- Delimitadores -------------------------- */
"("                     RET('(', "DELIMITADOR");
")"                     RET(')', "DELIMITADOR");
","                     RET(',', "DELIMITADOR");
";"                     RET(';', "DELIMITADOR");

 /* ------------------------- Qualquer outra coisa ------------------- */
 /* Acentos fora de um nome: um erro so (em UTF-8 cada acento tem 2+ bytes) */
{NAO_ASCII}+            { erro_lexico("caractere nao-ASCII (acento?)"); }
.                       { erro_lexico("caractere invalido"); }

%%
