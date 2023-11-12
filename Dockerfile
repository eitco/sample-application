FROM golang:latest AS builder
WORKDIR /sample-application
COPY go.mod .
RUN go mod download
RUN go mod tidy
COPY . . 
RUN CGO_ENABLED=0 GOOD=linux go build -o /sample-application/sample-application

FROM scratch
COPY --from=builder $WORKDIR/sample-application .
EXPOSE 8080
ENTRYPOINT ["./sample-application"]