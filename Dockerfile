FROM golang:1.23-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
ARG VERSION=docker
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w -X main.version=${VERSION}" -o /out/ah-mcp .

FROM alpine:3.20
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
RUN adduser -D -u 10001 ahmcp && mkdir -p /data && chown ahmcp /data
USER ahmcp
COPY --from=build /out/ah-mcp /usr/local/bin/ah-mcp
ENV AH_REMOTE=true AH_TOKENS_PATH=/data/tokens.json
EXPOSE 3000 9876
ENTRYPOINT ["ah-mcp"]
CMD ["--transport", "streamable-http", "--remote"]
