#!/usr/bin/env bash

 

CRUSH_FTP_BASE_DIR="/home/jboss/CrushFTP9"

 

[ -z ${CRUSH_ADMIN_USER} ] && CRUSH_ADMIN_USER=crushadmin

if [ -z ${CRUSH_ADMIN_PASSWORD} ] && [ -f ${CRUSH_FTP_BASE_DIR}/admin_user_set ]; then

    CRUSH_ADMIN_PASSWORD="NOT DISPLAYED!"

elif [ -z ${CRUSH_ADMIN_PASSWORD} ] && [ ! -f ${CRUSH_FTP_BASE_DIR}/admin_user_set ]; then

    # CRUSH_ADMIN_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
    CRUSH_ADMIN_PASSWORD=thePassword123

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

# TODO configure the logs of crush startup to be in JSON format
cd ${CRUSH_FTP_BASE_DIR}
nohup java -Ddir=${CRUSH_FTP_BASE_DIR} -Xmx512M -jar plugins/lib/CrushFTPJarProxy.jar -d & >/dev/null 2>&1

sleep 60 # give test server time to create the newest log

# Ensure log directory is there if it doesn't exist
mkdir -p ${CRUSH_FTP_BASE_DIR}/logs

# create bogus json log
echo "{timestamp: \"`date --iso-8601=seconds`\", message: \"CrushFTP server started\"}" >> crushstartup.log

curl --verbose -d command=registerCrushFTP -d registration_name=ESDC-INTEROPERABILITY_SITE -d registration_email=NC-ESRP-PRSH-ITEAM-PROD-ESB-BSE%2540HRSDC-RHDCC.GC.CA -d registration_code=xCnoF7wWtS2bAEwmqtmJH0aEdTKbmd7x -u ${CRUSH_ADMIN_USER}:${CRUSH_ADMIN_PASSWORD} http://localhost:8080/

exec tail -f crushstartup.log

