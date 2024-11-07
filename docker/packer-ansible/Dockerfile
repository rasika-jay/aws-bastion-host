ARG PACKER_VER
FROM hashicorp/packer:full-${PACKER_VER}

ARG ANSIBLE_VER
RUN env && apk add --update --no-cache ansible==$ANSIBLE_VER py-pip openssh openssl libcurl