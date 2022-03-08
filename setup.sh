#!/usr/bin/env bash

 

CRUSH_FTP_BASE_DIR="/var/app/CrushFTP9"

 

if [[ -f /tmp/CrushFTP9.zip ]] ; then

    echo "{timestamp: \"`date --iso-8601=seconds`\", message: \"Unzipping CrushFTP...\"}" >> crushstartup.log

    unzip -o -q /tmp/CrushFTP9.zip -d /var/app/

    rm -f /tmp/CrushFTP9.zip

fi

 

[ -z ${CRUSH_ADMIN_USER} ] && CRUSH_ADMIN_USER=crushadmin

if [ -z ${CRUSH_ADMIN_PASSWORD} ] && [ -f ${CRUSH_FTP_BASE_DIR}/admin_user_set ]; then

    CRUSH_ADMIN_PASSWORD="NOT DISPLAYED!"

elif [ -z ${CRUSH_ADMIN_PASSWORD} ] && [ ! -f ${CRUSH_FTP_BASE_DIR}/admin_user_set ]; then

    CRUSH_ADMIN_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)

fi

[ -z ${CRUSH_ADMIN_PROTOCOL} ] && CRUSH_ADMIN_PROTOCOL=http

[ -z ${CRUSH_ADMIN_PORT} ] && CRUSH_ADMIN_PORT=8080

 

if [[ ! -d ${CRUSH_FTP_BASE_DIR}/users/MainUsers/${CRUSH_ADMIN_USER} ]] || [[ -f ${CRUSH_FTP_BASE_DIR}/admin_user_set ]] ; then

    echo "{timestamp: \"`date --iso-8601=seconds`\", message: \"Creating default admin...\"}" >> crushstartup.log

    cd ${CRUSH_FTP_BASE_DIR} && java -jar ${CRUSH_FTP_BASE_DIR}/CrushFTP.jar -a "${CRUSH_ADMIN_USER}" "${CRUSH_ADMIN_PASSWORD}"

    touch ${CRUSH_FTP_BASE_DIR}/admin_user_set

fi

sleep 1

echo "{timestamp: \"`date --iso-8601=seconds`\", message: \"User: ${CRUSH_ADMIN_USER} / Password: ${CRUSH_ADMIN_PASSWORD}\"}" >> crushstartup.log

#for debugging
ls -lR /var/app
sleep 30 # give test server time to create the newest log
echo "Count 1"


# TODO configure the logs of crush startup to be in JSON format
chmod -R 777 ${CRUSH_FTP_BASE_DIR}
chmod 777 ${CRUSH_FTP_BASE_DIR}/crushftp_init.sh

#for debugging
ls -lR /var/app
sleep 30 # give test server time to create the newest log
echo "Count 2"

${CRUSH_FTP_BASE_DIR}/crushftp_init.sh start &

sleep 30 # give test server time to create the newest log

# Ensure log directory is there if it doesn't exist
mkdir -p ${CRUSH_FTP_BASE_DIR}/logs

# create bogus json log
echo "{timestamp: \"`date --iso-8601=seconds`\", message: \"CrushFTP server started\"}" >> crushstartup.log

exec tail -f crushstartup.log

