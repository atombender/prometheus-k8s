FROM golang:alpine

MAINTAINER Alexander Staubo <docker@purefiction.net>
LABEL short-description="Prometheus packaged for running under Kubernetes"
LABEL full-description="This runs Prometheus using a special controller that \
  monitors a configmap and automatically reloads Prometheus whenever the configmap changes."

# These are used by start.sh and can be overridden
ENV \
  PROMETHEUS_K8S_CONFIGROOT=/config \
  PROMETHEUS_K8S_CONFIGMAP=prometheus \
  PROMETHEUS_K8S_DATADIR=/var/prometheus \
  PROMETHEUS_K8S_ARGS= \
  GO15VENDOREXPERIMENT=1

RUN mkdir -p \
  /etc/prometheus \
  /var/prometheus \
  ${GOPATH}/bin \
  ${GOPATH}/src/github.com/prometheus \
  ${GOPATH}/src/github.com/atombender

COPY k8s-config-controller/        ${GOPATH}/src/github.com/atombender/k8s-config-controller/
COPY prometheus/                   ${GOPATH}/src/github.com/prometheus/prometheus/
COPY start-prometheus              /bin
COPY prometheus/console_libraries/ /etc/prometheus/console_libraries/
COPY prometheus/consoles/          /etc/prometheus/consoles/

RUN \
     apk update \
  && apk add make git mercurial gcc g++ \
  \
  && go get \
    k8s.io/kubernetes/pkg/api \
    k8s.io/kubernetes/pkg/client/unversioned \
    github.com/spf13/pflag \
    github.com/golang/glog \
    github.com/pkg/errors \
  && rm -rf \
    ${GOPATH}/src/k8s.io/kubernetes/vendor/github.com/spf13/pflag \
    ${GOPATH}/src/k8s.io/kubernetes/vendor/github.com/golang/glog \
  \
  && cd ${GOPATH}/src/github.com/atombender/k8s-config-controller \
  && go build -o /bin/config-controller \
  \
  && cd ${GOPATH}/src/github.com/prometheus/prometheus \
  && make build \
  && cp prometheus promtool /bin/ \
  \
  && apk del make git mercurial gcc g++ \
  && rm -rf ${GOPATH}

EXPOSE 9090

ENTRYPOINT ["/bin/start-prometheus"]
