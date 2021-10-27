ARG BUILD_ARCH
FROM mlupin/docker-lambda:provided.al2-build-${BUILD_ARCH}

ARG GIT_VERSION

RUN mkdir -p /root/openssl && cd /root/openssl && \
    curl -L --output openssl.tgz https://www.openssl.org/source/openssl-1.1.1l.tar.gz && \
    tar zxf openssl.tgz

ARG BUILD_ARCH
RUN cd /root/openssl/openssl-1.1.1l && \
    [[ "${BUILD_ARCH}" == "x86_64" ]] && CONF_ARCH="linux-x86_64" || CONF_ARCH="linux-aarch64" && \
    ./Configure --prefix=/opt $CONF_ARCH && \
    make NO_INSTALL_HARDLINKS=YesPlease -j8 && \
    make NO_INSTALL_HARDLINKS=YesPlease install

RUN mkdir -p /root/openssh && cd /root/openssh && \
    curl -L --output openssh.tgz https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-8.8p1.tar.gz && \
    tar zxf openssh.tgz

RUN cd /root/openssh/openssh-8.8p1/ && \
    LD_LIBRARY_PATH=/opt/lib && \
    ./configure CFLAGS="-I/opt/include" --prefix=/opt --with-ldflags="-L/opt/lib" && \
    make NO_INSTALL_HARDLINKS=YesPlease -j8 && \
    make NO_INSTALL_HARDLINKS=YesPlease install

RUN mkdir -p /root/git && cd /root/git && \
    curl -L --output git.tgz https://www.kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.gz && \
    tar zxf git.tgz

RUN cd /root/git/git-${GIT_VERSION} && \
    LD_LIBRARY_PATH=/opt/lib && \
    ./configure CFLAGS="-I/opt/include" --prefix=/opt --with-ldflags="-L/opt/lib" && \
    make NO_INSTALL_HARDLINKS=YesPlease -j8 && \
    make NO_INSTALL_HARDLINKS=YesPlease install

RUN rm -rf /opt/share/{doc,locale,man}/

ARG BUILD_ARCH
RUN echo "Git ${GIT_VERSION} ${BUILD_ARCH} layer for AWS Lambda: https://github.com/mLupine/lambda-git" > /opt/git_info

CMD [ "/bin/sh" ]
