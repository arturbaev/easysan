FROM ubuntu:20.04

LABEL Created by Artur Baev

WORKDIR /scripts/SAN/zoning

COPY . .

RUN apt update && apt upgrade && apt install -y \
    cifs-utils \
    poppler-utils \
    xlsx2csv \
    ssh \
    sshpass \
    samba

RUN cp smb.conf /etc/samba/smb.conf && \
    useradd -s /bin/bash -d /scripts/SAN/zoning -p $(echo easysan | openssl passwd -1 -stdin) easysan && \
    chown -R easysan /scripts && \
    service smbd start && \
    printf "easysan\neasysan\n" | smbpasswd -a -s easysan

EXPOSE 139 445 22

CMD service ssh restart && service smbd restart && bash

