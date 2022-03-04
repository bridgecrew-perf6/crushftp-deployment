#!/usr/bin/env bash

 

CRUSH_FTP_BASE_DIR="/home/jboss/CrushFTP9"

 

if [[ -f /tmp/CrushFTP9.zip ]] ; then

    echo '{timestamp: \"`date --iso-8601=seconds`\", message: "Unzipping CrushFTP..."}' >> crushstartup.log
    echo "Unzipping CrushFTP..."

    unzip -o -q /tmp/CrushFTP9.zip -d /home/jboss/

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

    echo "Creating default admin..."

    cd ${CRUSH_FTP_BASE_DIR} && java -jar ${CRUSH_FTP_BASE_DIR}/CrushFTP.jar -a "${CRUSH_ADMIN_USER}" "${CRUSH_ADMIN_PASSWORD}"

    touch ${CRUSH_FTP_BASE_DIR}/admin_user_set

fi

sleep 1

echo '{timestamp: \"`date --iso-8601=seconds`\", message: "User: ${CRUSH_ADMIN_USER} / Password: ${CRUSH_ADMIN_PASSWORD}"}' >> crushstartup.log

# TODO configure the logs of crush startup to be in JSON format
chmod 777 ${CRUSH_FTP_BASE_DIR}/crushftp_init.sh
${CRUSH_FTP_BASE_DIR}/crushftp_init.sh start &

sleep 30 # give test server time to create the newest log

# Ensure log directory is there if it doesn't exist
mkdir -p /home/jboss/CrushFTP9/logs

# linking CrushFTP log directory to a mount that can be monitored by FluentD side car
ln -s /home/jboss/CrushFTP9/logs/ /var/app/

# link the CrushFTP process log file to a mount that can be monitored by FluentD side car
ln -s /home/jboss/CrushFTP9/CrushFTP.log /var/app/

# create bogus json log
export isodate=\"`date --iso-8601=seconds`\"
echo '{timestamp: \"`date --iso-8601=seconds`\", message: "CrushFTP server started"}' >> crushstartup.log

exec tail -f crushstartup.log

