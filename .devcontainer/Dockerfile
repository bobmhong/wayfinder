FROM golang:1.21.5-bookworm
RUN go install cuelang.org/go/cmd/cue@latest
RUN cue version

RUN curl -sLS https://get.arkade.dev | sh

RUN arkade get --quiet cosign \
  dagger \
  flux \
  gh \
  gomplate \
  helm \
  hey \
  istioctl \
  jq \
  ktop \
  kube-linter \
  kubectl \
  kubeval \
  kustomize \
  kyverno \
  terraform \
  terragrunt \
  terrascan \
  tfsec \
  timoni \
  trivy \
  sops \
  vault \
  vcluster \
  yq