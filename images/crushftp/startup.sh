#!/usr/bin/env bash
CRUSH_FTP_BASE_DIR="/var/opt/CrushFTP10"

if [[ ! -f ${CRUSH_FTP_BASE_DIR}/installed ]] ; then
    echo "Copying CrushFTP for first install..."
    cp -R /install/CrushFTP10 /var/opt
    touch ${CRUSH_FTP_BASE_DIR}/installed
fi

if [ -z ${CRUSH_ADMIN_USER} ]; then
    CRUSH_ADMIN_USER=crushadmin
fi

if [ -z ${CRUSH_ADMIN_PASSWORD} ] && [ -f ${CRUSH_FTP_BASE_DIR}/admin_user_set ]; then
    CRUSH_ADMIN_PASSWORD="NOT DISPLAYED!"
elif [ -z ${CRUSH_ADMIN_PASSWORD} ] && [ ! -f ${CRUSH_FTP_BASE_DIR}/admin_user_set ]; then
    CRUSH_ADMIN_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
fi

if [ -z ${CRUSH_ADMIN_PROTOCOL} ]; then
    CRUSH_ADMIN_PROTOCOL=http
fi

if [ -z ${CRUSH_ADMIN_PORT} ]; then
    CRUSH_ADMIN_PORT=8080
fi

if [[ ! -f ${CRUSH_FTP_BASE_DIR}/admin_user_set ]] ; then
    echo "Creating default admin..."
    cd ${CRUSH_FTP_BASE_DIR} && java -jar ${CRUSH_FTP_BASE_DIR}/CrushFTP.jar -a "${CRUSH_ADMIN_USER}" "${CRUSH_ADMIN_PASSWORD}"
    touch ${CRUSH_FTP_BASE_DIR}/admin_user_set
fi

${CRUSH_FTP_BASE_DIR}/crushftp_init.sh start

until [ -f prefs.XML ]
do
     sleep 1
done

echo "Setting default provider to System.out."
sed -i "s/<logging_provider><\/logging_provider>/<logging_provider>crushftp.handlers.log.LoggingProviderSystemOut<\/logging_provider>/g" ${CRUSH_FTP_BASE_DIR}/prefs.XML

echo "########################################"
echo "# URL:		${CRUSH_ADMIN_PROTOCOL}://127.0.0.1:${CRUSH_ADMIN_PORT}"
echo "# User:		${CRUSH_ADMIN_USER}"
echo "# Password:	${CRUSH_ADMIN_PASSWORD}"
echo "########################################"

while true; do sleep 86400; done