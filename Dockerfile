FROM alpine:3 

ARG APK_FLAGS_COMMON="-q"
ARG APK_FLAGS_PERSISTANT="${APK_FLAGS_COMMON} --clean-protected --no-cache"
ARG APK_FLAGS_DEV="${APK_FLAGS_COMMON} --no-cache"

ENV LANG C.UTF-8
ENV TERM=xterm
ENV HELM_VERSION 3.5.0
ENV KUBECTL_VERSION 1.20.2

RUN apk update && \
    apk add ${APK_FLAGS_PERSISTANT} \
            ca-certificates \
            python3 \
            py3-pip \
            bash \
            curl \
            git \
            jq \
            libssh2 && \
    rm -rf /var/cache/apk/*

RUN pip3 install --upgrade pip && \
    pip3 install \
          awscli \
    && rm -rf /var/cache/apk/*

### Install helm
RUN wget "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" -O /tmp/helm.tar.gz && \
    tar zxfv /tmp/helm.tar.gz -C /tmp/ && \
    mv /tmp/linux-amd64/helm /usr/bin/

RUN wget -q https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -O /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl

COPY ["src", "/src/"]

ENTRYPOINT ["/src/main.sh"]
