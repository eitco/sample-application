# syntax=docker/dockerfile:1.6

FROM golang:latest AS builder

WORKDIR /sample-application
COPY . .
RUN go mod tidy
RUN CGO_ENABLED=0 GOOD=linux go build -o /sample-application/sample-application cmd/main.go

FROM scratch

COPY <<EOF /etc/group
root:x:0:
nonroot:x:55061:
EOF

COPY <<EOF /etc/passwd
root:x:0:0:root:/root:/sbin/nologin
nonroot:x:55061:55061:nonroot:/home/nonroot:/sbin/nologin
EOF

COPY --from=builder $WORKDIR/sample-application .

EXPOSE 8080

ENTRYPOINT ["./sample-application"]