FROM registry.access.redhat.com/ubi8/openjdk-11

USER root
RUN mkdir -p /var/app
RUN chmod 777 /var/app
COPY CrushFTP9.zip  /tmp/
ADD setup.sh /var/app/setup.sh
RUN microdnf update && microdnf install procps
ENTRYPOINT [ "/bin/bash", "/var/app/setup.sh" ]

EXPOSE 21 443 2222 8080 8888 9022 9090
