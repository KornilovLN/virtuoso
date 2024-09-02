#---------------------------------------------------------------------
# Dockerfile Образа Virtuoso
# Построение образа:
#   docker build -t virtuoso-image .
# Запуск контейнера с образом:
#   docker run -d --name virtuoso-cont -p 8890:8890 -p 1111:1111 virtuoso-image
# Запуск с сохранением томов
#   docker run -d --name virtuoso-cont -p 8890:8890 -p 1111:1111 -v virtuoso-data:/usr/local/virtuoso-opensource/var/lib/virtuoso/db virtuoso-image
#
# Работа с контейнером virtuoso через web- интерфейс:
#   http://localhost:8890
#   login:      dba
#   password:   dba
#---------------------------------------------------------------------


# Используем официальный образ Virtuoso Open Source как базовый образ
FROM openlink/virtuoso-opensource-7

# Устанавливаем переменные окружения для Virtuoso
ENV VIENNA_HOME=/opt/virtuoso-opensource
ENV PATH="$VIENNA_HOME/bin:$PATH"

# Создаем необходимые каталоги
RUN mkdir -p    /opt/virtuoso-opensource/database/db \
                /opt/virtuoso-opensource/log

# Копируем файлы конфигурации
#COPY virtuoso.ini /opt/virtuoso-opensource/database/db/
COPY virtuoso.ini /opt/virtuoso-opensource/database/

# Открываем порты для доступа
EXPOSE 8890 1111

# Запускаем Virtuoso
CMD ["/opt/virtuoso-opensource/bin/virtuoso-t", "-f", "-d", "/opt/virtuoso-opensource/database/db/"]




