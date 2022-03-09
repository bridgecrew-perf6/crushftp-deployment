FROM registry.access.redhat.com/ubi8/openjdk-11

COPY CrushFTP9.zip  /tmp/
RUN unzip -o -q /tmp/CrushFTP9.zip -d /home/jboss/
ADD setup.sh /home/jboss/setup.sh
USER root
RUN microdnf update && microdnf install procps
ENTRYPOINT [ "/bin/bash", "/home/jboss/setup.sh" ]

EXPOSE 21 443 2222 8080 8888 9022 9090
