ARG BUILD_ARCH
FROM mlupin/docker-lambda:provided.al2-build-${BUILD_ARCH}

ARG GIT_VERSION

RUN ulimit -n 1024 && yum -y update && yum -y install \
    perl-IPC-Cmd \
    && yum clean all

RUN mkdir -p /root/openssl && cd /root/openssl && \
    curl -L --output openssl.tgz https://www.openssl.org/source/openssl-3.2.0.tar.gz && \
    tar zxf openssl.tgz

ARG BUILD_ARCH
RUN cd /root/openssl/openssl-3.2.0 && \
    [[ "${BUILD_ARCH}" == "x86_64" ]] && CONF_ARCH="linux-x86_64" || CONF_ARCH="linux-aarch64" && \
    ./Configure --prefix=/opt $CONF_ARCH && \
    make NO_INSTALL_HARDLINKS=YesPlease -j8 && \
    make NO_INSTALL_HARDLINKS=YesPlease install

RUN mkdir -p /root/openssh && cd /root/openssh && \
    curl -L --output openssh.tgz https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-9.6p1.tar.gz && \
    tar zxf openssh.tgz

RUN cd /root/openssh/openssh-9.6p1/ && \
    LD_LIBRARY_PATH=/opt/lib && \
    ./configure CFLAGS="-I/opt/include" --prefix=/opt --with-ldflags="-L/opt/lib" && \
    make NO_INSTALL_HARDLINKS=YesPlease -j8 && \
    make NO_INSTALL_HARDLINKS=YesPlease install

RUN mkdir -p /root/curl && cd /root/curl && \
    curl -L --output curl.tgz https://curl.se/download/curl-8.5.0.tar.gz && \
    tar zxf curl.tgz

RUN cd /root/curl/curl-8.5.0 && \
    LD_LIBRARY_PATH=/opt/lib && \
    ./configure CFLAGS="-I/opt/include" --prefix=/opt --with-ldflags="-L/opt/lib" --with-openssl=/opt && \
    make NO_INSTALL_HARDLINKS=YesPlease -j8 && \
    make NO_INSTALL_HARDLINKS=YesPlease install

RUN mkdir -p /root/git && cd /root/git && \
    curl -L --output git.tgz https://www.kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.gz && \
    tar zxf git.tgz

RUN cd /root/git/git-${GIT_VERSION} && \
    LD_LIBRARY_PATH=/opt/lib && \
    ./configure CFLAGS="-I/opt/include" --prefix=/opt --with-ldflags="-L/opt/lib" --with-curl=/opt && \
    make NO_INSTALL_HARDLINKS=YesPlease -j8 && \
    make NO_INSTALL_HARDLINKS=YesPlease install

RUN rm -rf /opt/share/{doc,locale,man}/

ARG BUILD_ARCH
RUN echo "Git ${GIT_VERSION} ${BUILD_ARCH} layer for AWS Lambda: https://github.com/mLupine/lambda-git" > /opt/git_info

CMD [ "/bin/sh" ]
