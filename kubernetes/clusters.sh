context() {
  local alias_name=$1

  case "$alias_name" in
    greentest)
      kubectl config use k8s-green-test && \
      export KUBE_CTX_ALIAS=greentest && \
      export KUBE_CTX_COLOR="32" ;;        # Green

    bluetest)
      kubectl config use k8s-blue-test && \
      export KUBE_CTX_ALIAS=bluetest && \
      export KUBE_CTX_COLOR="34" ;;        # Blue

    greenlive)
      kubectl config use k8s-green-live && \
      export KUBE_CTX_ALIAS=greenlive && \
      export KUBE_CTX_COLOR="92" ;;        # Light Green

    bluelive)
      kubectl config use k8s-blue-live && \
      export KUBE_CTX_ALIAS=bluelive && \
      export KUBE_CTX_COLOR="94" ;;        # Light Blue

    dspdev)
      kubectl config use aks-agrimetrics-dsp-dev-uks-001 && \
      export KUBE_CTX_ALIAS=dspdev && \
      export KUBE_CTX_COLOR="33" ;;        # Yellow

    dspprod)
      kubectl config use aks-agrimetrics-dsp-prod-uks-001 && \
      export KUBE_CTX_ALIAS=dspprod && \
      export KUBE_CTX_COLOR="31" ;;        # Red

    agmdev)
      kubectl config use aks-agrimetrics-dev-uksouth-001 && \
      export KUBE_CTX_ALIAS=agmdev && \
      export KUBE_CTX_COLOR="95" ;;        # Pink

    agmprod)
      kubectl config use aks-agrimetrics-prod-uksouth-001 && \
      export KUBE_CTX_ALIAS=agmprod && \
      export KUBE_CTX_COLOR="35" ;;        # Purple

    *)
      echo "Unknown alias: $alias_name"
      return 1 ;;
  esac
}