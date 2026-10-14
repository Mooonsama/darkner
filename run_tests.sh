#!/bin/bash
# Roda todos os testes: os de testes/validos devem ser aceitos (saida 0)
# e os de testes/erros devem ser rejeitados (saida 1).

cd "$(dirname "$0")"
[ -x ./darkner ] || make -s || exit 1

ok=0; falhou=0

rodar() {
    local arq=$1 esperado=$2
    echo "================================================================"
    echo ">> $arq"
    echo "----------------------------------------------------------------"
    ./darkner "$arq" 2>&1
    local r=$?
    if [ "$r" -eq "$esperado" ]; then
        echo "   -> OK (resultado esperado)"; ok=$((ok + 1))
    else
        echo "   -> FALHOU (saida $r, esperado $esperado)"; falhou=$((falhou + 1))
    fi
}

for f in testes/validos/*.dr; do rodar "$f" 0; done
for f in testes/erros/*.dr;   do rodar "$f" 1; done

echo "================================================================"
echo "Resumo: $ok teste(s) OK, $falhou teste(s) falharam."
[ "$falhou" -eq 0 ]
