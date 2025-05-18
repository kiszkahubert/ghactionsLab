FROM busybox:uclibc
LABEL org.opencontainers.image.authors="Hubert Kiszka"
COPY app.sh /app.sh
ARG TARGETARCH
COPY bash-linux-x86_64 bash-linux-aarch64 /tmp/
RUN if [ "$TARGETARCH" = "amd64" ] || [ "$TARGETARCH" = "" ]; then \
        cp /tmp/bash-linux-x86_64 /bin/bash; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        cp /tmp/bash-linux-aarch64 /bin/bash; \
    else \
        echo "Unsupported architecture: $TARGETARCH"; \
        exit 1; \
    fi && \
    chmod +x /bin/bash && \
    chmod +x /app.sh && \
    rm -f /tmp/bash-linux-*
EXPOSE 8080
CMD ["/bin/bash", "/app.sh"]
