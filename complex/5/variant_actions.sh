#!/usr/bin/sh
. ./tools.sh

actions=(searchTheSame createFolders clearDirs)
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
log _ 'Теперь проверим, содержит ли она файлы для проверки'
    [ -z "$( find "$directory" -maxdepth 1 -mindepth 1 -type f )" ] && {
log _ 'Нет, не содержит — нечего проверять'
        echo -e "Папка \"$directory\" не содержит файлов для проверки.\nПопробуйте ещё раз.\n"
        return -1
    }
    result="$directory"
}


function searchTheSame {
log 'Считываем первую папку для проверки'
    readTillCorrectResult _readDirectory 'первую папку для поиска идентичных файлов'
    local dir1="$result"
log 'Считываем вторую папку для проверки'
    readTillCorrectResult _readDirectory 'вторую папку'
    local dir2="$result"
log _ "Получим списки файлов в папках \"$dir1\" и \"$dir2\""
    local files1=`find "$dir1" -maxdepth 1 -type f -printf '%P\n'`
    local files2=`find "$dir2" -maxdepth 1 -type f -printf '%P\n'`
    local file1
    local file2
    local lineCount
log _ 'Запустим цикл сравнения каждой пары файлов'
    echo -e 'ФАЙЛ 1\t\tФАЙЛ 2\t\tЧИСЛО СТРОК'
    while read file1
    do
        while read file2
        do
            diff -q "$dir1/$file1" "$dir2/$file2" > /dev/null
            if [ $? -eq 0 ]
            then
                lineCount=`cat "$dir1/$file1" | wc -l`
                echo -e "$file1\t$file2\t$lineCount"
            fi
        done <<< "$files2"
    done <<< "$files1"
}


dateDirs=()
letters=( {a..z} )


function _copyFilesByLetterToDir {
    local letter=$1
    local dirName="$2"
log "Скопируем в папку $dirName файлы, оканчивающиеся на букву $letter"
    local filesByLetter=`find -maxdepth 1 -type f -regex ".*$letter$" -printf '%P\n'`
    local file
    if [ -z "$filesByLetter" ]
    then
log _ "Нет таких файлов, нечего копировать"
        return 1
    fi
    while read file
    do
        cp "$file" "$dirName"
    done <<< "$filesByLetter"
}


function createFolders {
    local dirName
    local letter
    local i=0
log "Запускаем цикл по созданию папок и копированию файлов с интервалом в $time секунд"
    while [ -z "$( find -maxdepth 1 -type f -name stop )" ]
    do
        letter="${letters[i]}"
        dirName=`date '+%d.%m.%Y %T'`
        mkdir "$dirName"
        _copyFilesByLetterToDir $letter "$dirName"
        if [ $letter == 'z' ]
        then
            i=0
log "Латинский алфавит закончился, начинаем по-новой"
        else
            let i+=1
        fi
        dateDirs+=("$dirName")
        sleep $time
    done
log 'Найден файл stop, прерываем цикл'
}


function clearDirs {
log "Удаляем созданные папки и их содержимое"
    for dir in "${dateDirs[@]}"
    do
        rm -rf "$dir"
    done
    rm 'stop'
log _ "Записываем их количество (${#dateDirs[@]}) в result.txt"
    echo ${#dateDirs[@]} > 'result.txt'
    echo "Удалено ${#dateDirs[@]} папок, результат записан в result.txt."
    exitFlag=1
}
