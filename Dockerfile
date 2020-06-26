FROM mikefarah/yq:3 AS yq

FROM alpine:3.8

RUN apk add --no-cache bash git openssh

# This looks strange, but the reason is that I want
# to control the image we're running, but build it from source
COPY --from=yq /usr/bin/yq /usr/bin/yq
RUN chmod +x /usr/bin/yq

RUN mkdir /src

COPY generate-manifest.sh /src/generate-manifest.sh
RUN chmod +x /src/generate-manifest.sh

WORKDIR /src

ENTRYPOINT ["/src/generate-manifest.sh"]
