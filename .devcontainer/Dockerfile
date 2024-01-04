FROM golang:1.21.5-bookworm
RUN go install cuelang.org/go/cmd/cue@latest
RUN cue version

RUN curl -sLS https://get.arkade.dev | sh

ark get flux
ark get jq
ark get yq
ark get sops
ark get kustomize
ark get kyverno
ark get terraform
