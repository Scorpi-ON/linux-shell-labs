#!/usr/bin/sh
. ./tools.sh
. ./variant_actions.sh


declare -A varTitles=(
    [time]='длительность промежутка времени в секундах'
    [numItem]='максимальное количество пунктов меню'
    [itemFile]='текстовый файл с наименованием пунктов меню'
)

if [ $# -ne 3 ]
then
log "$@" "Было передано $# аргументов, а нужно 3: ${varTitles[time]}, ${varTitles[numItem]} и ${varTitles[itemFile]}. Выход"
    echo -e "Вы должны были передать 3 аргумента:\n" \
         "- ${varTitles[time]};\n" \
         "- ${varTitles[numItem]};\n" \
         "- ${varTitles[itemFile]}."
    exit -1
fi
time=$1
numItem=$2
itemFile=$3
maxNumItem=${#actions[@]}
log "$@" "Проверим аргументы скрипта на корректность"

isIntBetween $time "${varTitles[time]}" 1 || {
    log "$@" 'Выход'
    exit -1
}
isIntBetween $numItem "${varTitles[numItem]}" $maxNumItem || {
    log "$@" 'Выход'
    exit -1
}
log "$@" "Проверим, доступен ли файл \"$itemFile\" для чтения"
[ ! -z "$( sed -n 1p "$itemFile" 2> '/dev/null' )" ] || {
    log _ 'Нет, не доступен. Выход'
    echo "Ожидалось, что файл \"$itemFile\" доступен для чтения и содержит хотя бы одну строку"
    exit -1
}
maxNumItem=$numItem

trap 'echo
      log "Получен сигнал SIGINT, прерываем работу скрипта"
      border
      exit 130' SIGINT
exitFlag=0


function _readNum {
    read -n1 num
    echo
log _ "Считан символ '$num'. Проверим, является ли он номером одного из пунктов меню"
    isIntBetween "$num" 'пункт меню' 1 $numItem || {
        echo -e 'Попробуйте ещё раз.\n'
        return -1
    }
log 'Сделаем пункт меню индексом (уменьшим на 1), чтобы обращаться по нему к массиву действий'
    let 'num--'
    return 0
}


function _menuItems {
    numItem=0
log "Прочитаем и выведем $maxNumItem строк файла \"$itemFile\""
    while read line && [[ ! -z $line && $numItem -lt $maxNumItem ]]
    do
        let 'numItem++'
        echo "$numItem. $line"
    done < "$itemFile"
log _ "Выведено $numItem пунктов меню"
    echo
}


log "$@" "Первоначальная настройка завершена, переходим в основной цикл"
border
while [ $exitFlag -ne 1 ]
do
    _menuItems
    log 'Считаем символ для выбора пункта меню'
    readTillCorrectResult _readNum 'пункт меню'
    border
log "$@" "Начинаем выполнение действия \"${actions[$num]}\""
    ${actions[$num]}
log "$@" "Действие \"${actions[$num]}\" завершено"
    border
done
log 'Выходим из основного цикла'
