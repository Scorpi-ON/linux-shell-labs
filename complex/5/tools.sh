#!/usr/bin/bash

logFile='log.txt'


function _correctFuncName {
    local funcName="${FUNCNAME[2]}"
    case "$funcName" in
        'main')
            echo "$0"
            ;;
        'source')
            echo '<одна из библиотек>'
            ;;
        *)
            echo "$funcName"
            ;;
    esac
}


function log() {
    local datetimeBlock="[$( date '+%d.%m.%Y %T' )]"
    if [ "$1" == _ ]
    then
        echo -en "\n$datetimeBlock\n$2" >> "$logFile"
        return 0
    fi
    echo -en "\n\n$datetimeBlock $( _correctFuncName )" >> "$logFile"
    local args=("$@")
    local messageIndex=$(( $# - 1 ))
    for arg in "${args[@]:0:$messageIndex}"
    do
        echo -en " \"$arg\"" >> "$logFile"
    done
    echo -en "\n${args[$messageIndex]}" >> "$logFile"
}

echo -e '[<ДАТА И ВРЕМЯ>] <ВЫЗОВ ФУНКЦИИ ИЛИ ФАЙЛА С АРГУМЕНТАМИ>\n<СООБЩЕНИЕ>' > $logFile
log "Создаём файл лога"


function isIntBetween() {
    local value=$1
    local caption=$2
    local min=$3
    local max=$4
log "$@" "Проверим, является ли \"$value\" числовым значением"
    [[ $value =~ [[:digit:]] ]] || {
log _ 'Нет, не является'
        echo -e "Ожидалось, что $caption будет целочисленным значением."
        return -1
    }
log _ "Проверим, лежит ли $value между min=$min и max=$max"
    if [[ !( -z "$min" || -z "$max" )
        && ( $value -lt $min || $value -gt $max ) ]]
    then
log _ 'Нет, не лежит'
        if [ $min -eq $max ]
        then
            echo -e "Ожидалось, что $caption будет равно $min."
        else
            echo -e "Ожидалось, что $caption будет между $min и $max."
        fi
        return -1
    elif [[ ! -z "$min" && $value -lt $min ]]
    then
log _ 'Нет, не лежит'
        echo -e "Ожидалось, что $caption будет не меньше $min."
        return -1
    fi
}


function readTillCorrectResult() {
    local readFunc=$1
    local caption=$2
log "$@" "Будем запускать функцию считывания, пока она не завершится без ошибок"
    echo -n "Введите $caption: "
    $readFunc
    while [ $? -ne 0 ]
    do
log "$@" 'Функция считывания завершилась с ошибкой, запускаем ещё раз'
        echo -n "Введите $caption: "
        $readFunc
    done
log "$@" 'Считывание прошло успешно'
}


function border {
log "Выводим строчку с текущей датой и временем"
    printf '—%.0s' {1..40}
    datetime=`date '+%d.%m.%Y %T'`
    echo -n $datetime
    printf '—%.0s' {1..40}
    echo
}
