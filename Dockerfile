FROM ubuntu:26.04

ARG LOCALE=en_GB

RUN apt-get update && apt-get upgrade -y && apt-get install -y locales \
    && localedef -i ${LOCALE} -c -f UTF-8 ${LOCALE}.UTF-8 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
ENV LANG=${LOCALE}.utf8

COPY installdeps.sh .
RUN bash installdeps.sh && rm installdeps.sh

RUN git clone --depth 1 https://github.com/cyrus-and/gdb-dashboard.git /tmp/gdb-dashboard \
    && cp /tmp/gdb-dashboard/.gdbinit /root/.gdbinit \
    && rm -rf /tmp/gdb-dashboard
