#!/usr/bin/bash
. ./tools.sh

actions=(sizeDifference analyzeProcessCountChanging listNewProcesses)
log "Найдено ${#actions[@]} запрограммированных действий по варианту: $( echo "${actions[@]}" )"


function _readDirectory {
    local directory
    read directory
log "Считано значение \"$directory\". Проверим, папка ли это"
    [ -d "$directory" ] || {
log _ 'Нет, такой папки не существует'
        echo -e "Папки \"$directory\" не существует.\nПопробуйте ещё раз.\n"
        return -1
    }
log _ 'Теперь проверим, содержит ли она подкаталоги для проверки'
    [ -z "$( find "$directory" -maxdepth 1 -mindepth 1 -type d )" ] && {
log _ 'Нет, не содержит — нечего проверять'
        echo -e "Папка \"$directory\" не содержит подкаталогов для проверки.\nПопробуйте ещё раз.\n"
        return -1
    }
    result="$directory"
}


function sizeDifference {
log 'Считаем папку для проверки'
    readTillCorrectResult _readDirectory 'папку для поиска файлов по подкаталогам'
    local directory="$result"
log 'Найдём подкаталоги 1-го уровня данной папки'
    local subdirs="$( find "$directory" -maxdepth 1 -mindepth 1 -type d -printf "%P\n" )"
    local subdir
log _ 'Начинаем просмотр каждого из них'
    echo -e 'ПОДКАТАЛОГ\tРАЗНОСТЬ'
    while read subdir
    do
        local files="$( find "$directory/$subdir" -type f -printf '%s\n' | sort -nk1 )"
        local difference
        if [ $( echo "$files" | wc -l ) -lt 2 ]
        then
            log _ "\"$subdir\" — содержит менее двух файлов, невозможно получить разность"
            difference='невозможно получить разность: найдено менее двух файлов'
        else
            local max=`echo "$files" | tail -n 1`
            local min=`echo "$files" | head -n 1`
            let 'difference = max - min'
            log _ "\"$subdir\": $max - $min = $difference"
        fi
        echo -e "$subdir\t\t$difference"
    done <<< "$subdirs"
}


function _readUser {
    local user
    read user
log "Считано значение \"$user\". Проверим, пользователь ли это"
    [ -z "$( getent passwd | grep "^$user:" )" ] && {
log _ 'Нет, такого пользователя не существует'
        echo -e "Пользователь \"$user\" не существует.\nПопробуйте ещё раз.\n"
        return -1
    }
    result="$user"
}


function _readProcessLimit {
    local processLimit
    read processLimit
log "Считано значение \"$processLimit\". Проверим, положительное ли это число"
    isIntBetween "$processLimit" 'предел процессов' 1 || {
        echo -e 'Попробуйте ещё раз.\n'
        return -1
    }
    result=$processLimit
}


function analyzeProcessCountChanging {
log 'Считаем пользователя и предел процессов'
    readTillCorrectResult _readUser 'имя пользователя, процессы которого нужно сканировать'
    local user="$result"
    readTillCorrectResult _readProcessLimit 'предел процессов, при достижении которого необходимо прервать сканирование'
    local processLimit="$result"
    local processCount=0
log "Начинаем проверку числа процессов пользователя $user с интервалом $time секунд"
    echo -e "ВРЕМЯ ПРОВЕРКИ\tБЛИЗОСТЬ К ПРЕДЕЛУ\tЧИСЛО ПРОЦЕССОВ"
    while [ $processCount -lt $processLimit ]
    do
        processCount=`ps -u $user | wc -l`
log "Найдено $processCount процессов. Выведем требуемую информацию о них"
        echo -e "$( date +%T )\t$( getProgressBar $processCount $processLimit )\t\t$processCount"
        sleep $time
    done
log "Предел числа процессов ($processLimit) достигнут"
}


function listNewProcesses {
log "Получаем общий список процессов"
    local processes=`ps -eo pid,user,cmd,time,lstart -D "%d.%m.%y %T"`
    echo "$processes" | head -n 1
    echo "${processes#*$$}" | sed '1d'
log "Выводим только те процессы из списка, которые появились после запуска скрипта (PID которого $$)"
    exitFlag=1
}
