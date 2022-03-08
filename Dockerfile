FROM registry.access.redhat.com/ubi8/openjdk-11

COPY CrushFTP9.zip  /tmp/
ADD setup.sh /var/app/setup.sh
USER root
RUN microdnf update && microdnf install procps
ENTRYPOINT [ "/bin/bash", "/var/app/setup.sh" ]

EXPOSE 21 443 2222 8080 8888 9022 9090
