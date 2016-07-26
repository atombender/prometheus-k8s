**Prometheus image for running under Kubernetes**

This repository builds a Docker image for [Prometheus](https://prometheus.io) for running on Kubernetes under [k8s-config-controller](http://github.com/atombender/k8s-config-controller).

## Example pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: prometheus
  labels:
    app: prometheus
spec:
  containers:
  - name: prometheus
    image: atombender/prometheus-k8s:v1.0-latest
    imagePullPolicy: Always
    ports:
    - containerPort: 9090
      protocol: TCP
    livenessProbe:
      httpGet:
        path: /metrics
        port: 9090
        scheme: HTTP
      initialDelaySeconds: 60
      timeoutSeconds: 5
      successThreshold: 1
      failureThreshold: 5
    volumeMounts:
    - name: configs
      mountPath: /mnt/prometheus-config
    - name: data
      mountPath: /mnt/prometheus-data
    env:
    - name: PROMETHEUS_K8S_CONFIGROOT
      value: /mnt/prometheus-config
    - name: PROMETHEUS_K8S_DATADIR
      value: /mnt/prometheus-data
    - name: PROMETHEUS_K8S_ARGS
      value: "-alertmanager.url=http://alertmanager/"
  volumes:
  - name: configs
    configMap:
      name: prometheus
  - name: data
    emptyDir:
```

## Configuration

* `PROMETHEUS_K8S_CONFIGROOT` — sets the folder in which configuration files are written. Defaults to `/config`. Must contain `prometheus.yml`.
* `PROMETHEUS_K8S_CONFIGMAP` — sets the name of the configmap to watch, using the format `[ns]/[name]`. Defaults to `default/prometheus`.
* `PROMETHEUS_K8S_DATADIR` — Prometheus data directory. Defaults to `/var/prometheus`.
* `PROMETHEUS_K8S_ARGS` — additional arguments to pass to Prometheus, e.g. `-alertmanager.url`.

## Release version numbers

Prometheus version number is prefixed: `v1.0-latest` is Prometheus 1.0.
