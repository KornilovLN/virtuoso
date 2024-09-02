#!/bin/bash

#--- Запуск контейнера с virtuoso с привязкой к SERVER_PORT на хосте
#--- работает локальный сервер (в этом случае из докер-контейнера)
#--- Браузер будет определен и запущен функцией open_browser() на хосте
# docker run -d --name virtuoso-cont -p 8890:8890 -p 1111:1111 -v virtuoso-data:/usr/local/virtuoso-opensource/var/lib/virtuoso/db virtuoso-image

SERVER_PORT=8890
ISQL_PORT=1111
NAME_IMAGE="virtuoso-image"
NAME_CONTAINER="virtuoso-cont"
DATA="virtuoso-data"
PATH_TO_DB="/opt/virtuoso-opensource/database/db" 

SERVER_URL="http://localhost:$SERVER_PORT"

open_browser() {
    if command -v xdg-open &> /dev/null; then
        xdg-open "$SERVER_URL" 
    elif command -v gnome-open &> /dev/null; then
        gnome-open "$SERVER_URL" 
    elif command -v open &> /dev/null; then
        open "$SERVER_URL" 
    else
        echo "Не удалось автоматически открыть браузер. Пожалуйста, откройте $SERVER_URL вручную."
    fi
}


# Проверка наличия Docker
if ! command -v docker &> /dev/null; then
    echo "Docker не найден. Пожалуйста, установите Docker и попробуйте снова."
    exit 1
fi


# Остановка и удаление существующего контейнера, если он есть
if [ "$(docker ps -q -f name=$NAME_CONTAINER)" ]; then
    echo "Остановка и удаление существующего контейнера $NAME_CONTAINER..."
    docker stop $NAME_CONTAINER
    docker rm $NAME_CONTAINER
fi


# Запуск нового контейнера
echo "Запуск нового контейнера $NAME_CONTAINER.."
CONTAINER_ID=$(docker run  -d \
            --rm \
            --name $NAME_CONTAINER \
            -p $SERVER_PORT:$SERVER_PORT \
            -p $ISQL_PORT:$ISQL_PORT \
            -v $DATA:$PATH_TO_DB \
            $NAME_IMAGE 2>&1)



RUN_EXIT_CODE=$?

if [ $RUN_EXIT_CODE -ne 0 ]; then
    echo "Не удалось запустить контейнер. Код выхода: $RUN_EXIT_CODE"
    echo "Ошибка: $CONTAINER_ID"
    exit 1
fi



# Подождем немного, чтобы контейнер успел запуститься
echo "Ожидание запуска контейнера..."
sleep 5

# Проверка состояния контейнера
if [ "$(docker ps -q -f name=$NAME_CONTAINER)" ]; then
    echo "Контейнер $NAME_CONTAINER запущен успешно."
    echo "Открытие браузера..."
    open_browser
else
    echo "Контейнер $NAME_CONTAINER не запущен. Проверьте логи для отладки."
    docker logs $NAME_CONTAINER
    exit 1
fi

