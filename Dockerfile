FROM alpine
WORKDIR /

# Add aws cli
RUN  apk add --no-cache aws-cli
# Add other bins
COPY --from=gcr.io/cloud-builders/kubectl /builder/google-cloud-sdk/bin//kubectl /usr/local/bin
COPY --from=vault /bin/vault /usr/local/bin

COPY bin/* ./

ENTRYPOINT ["/entrypoint"]
CMD ["app"]