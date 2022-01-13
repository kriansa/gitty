ARG ALPINE_VERSION

##
# This is a stage container used to build CGIT only
##
FROM alpine:${ALPINE_VERSION} AS build-cgit

WORKDIR /root
ADD cgit-pkg/APKBUILD .
RUN apk add alpine-sdk
RUN abuild-keygen --append --quiet -n
RUN abuild -Fr
RUN mv ~/packages/"$(abuild -FA)"/"$(abuild -F listpkg)" /root/cgit.apk

##
# This is the a stage container that install all needed files
##

FROM alpine:${ALPINE_VERSION} AS build-image

ARG S6_VERSION

# Upgrade everything!
RUN apk upgrade --update --no-cache

# Install s6-overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && rm /tmp/s6-overlay-amd64.tar.gz

# Install needed packages
COPY --from=build-cgit /root/cgit.apk /tmp
RUN apk add --allow-untrusted /tmp/cgit.apk && rm /tmp/cgit.apk
RUN apk add git openssh-server nginx fcgiwrap \
	gettext python3 py3-pygments py3-markdown bash \
	jq busybox-suid curl
RUN apk del vim

# Create the git user
RUN adduser -h /srv/git -s /usr/bin/gitty-shell -D git && passwd -u git

# Copy all files to the container
COPY rootfs /

# Fix the permissions of the crontab file
RUN chown root:git /etc/crontabs/git && chmod 0600 /etc/crontabs/git

# Add a crontab entry for root user 
# It has to run as root so the output SSH key file has correct permissions
RUN echo "*/5     *       *       *       *       /usr/bin/ssh-key-fetch" >> /etc/crontabs/root

# Finally we cleanup the image
RUN rm -rf /var/cache/apk/*

##
# Final image build - it copies all files from the build-image stage image in a single statement,
# making the final image as thin as possible
##

FROM scratch

ARG IMAGE_VERSION

LABEL org.opencontainers.image.authors="Daniel Pereira <daniel@garajau.com.br>"
LABEL org.opencontainers.image.source="https://github.com/kriansa/gitty"
LABEL org.opencontainers.image.version=${IMAGE_VERSION}

COPY --from=build-image / /

# Exposed ports and paths
EXPOSE 22 80
VOLUME ["/srv/git", "/config"]

# Default ENV variables
ENV SERVER_URL="git-server-of-mine.com" 
ENV AUTO_PULL_SSH_KEYS=""
ENV CGIT_TITLE="My private git server"
ENV CGIT_DESC="A web interface for my git private server"

ENTRYPOINT ["/init"]
