---
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: OCIRepository
metadata:
  name: podinfo
  namespace: flux-system
spec:
  interval: 10m0s
  provider: generic
  ref:
    tag: 6.1.6
  url: oci://ghcr.io/stefanprodan/manifests/podinfo
