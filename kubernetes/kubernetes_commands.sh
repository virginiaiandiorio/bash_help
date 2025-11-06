alias khelp='cat $HOME/repositories/bash_help/kubernetes/kubernetes_commands.sh'



alias k='kubectl'
alias kg='kubectl get'
alias kgp='kubectl get pod'
alias kd='kubectl describe'
alias kdp='kubectl describe pod'
alias kl='kubectl logs'


# geoserver specific commands 
alias gpods='kubectl get pods -n dsp-geoserver'
alias gjob='kubectl get job -n dsp-geoserver'
alias gjobd='kubectl describe job -n dsp-geoserver'
alias gjobdelete='kubectl delete job sync-geoserver-config -n dsp-geoserver'
alias jobapply='cd ~/repositories/geoserver && kubectl -n dsp-geoserver apply -f k8s_sync_pods/sync-dsp-geoserver-config.yaml'
alias kroll='kubectl rollout restart deployment geoserver-read -n dsp-geoserver'


ks() {
  if [[ "$1" == "--help" || "$1" == "-h" || $# -lt 2 ]]; then
    echo "Usage: ks <deployment> <replicas> [kubectl scale options]"
    echo "Example:"
    echo "  ks geoserver-ui 2 -n dsp-geoserver"
    echo "  # Runs: kubectl scale deployment geoserver-ui --replicas=2 -n dsp-geoserver"
    return 0
  fi

  local deployment=$1
  local replicas=$2
  shift 2

  echo "Running: kubectl scale deployment $deployment --replicas=$replicas $*"
  kubectl scale deployment "$deployment" --replicas="$replicas" "$@"
}

kclean() {
  if [[ "$1" == "--help" || "$1" == "-h" || $# -lt 2 ]]; then
    echo "Usage: kclean <namespace> <state>"
    echo "Example:"
    echo "  kclean dsp-geoserver Error"
    echo "  # Deletes all pods in dsp-geoserver with state 'Error'"
    return 0
  fi

  local namespace=$1
  local state=$2
  shift 2

  echo "Running: kubectl delete pod -n $namespace \$(kubectl get pods -n $namespace --no-headers | awk -v s=\"$state\" '\$3==s {print \$1}')"
  kubectl delete pod -n "$namespace" $(kubectl get pods -n "$namespace" --no-headers | awk -v s="$state" '$3==s {print $1}')
}

kdecrypt() {
  if [[ "$1" == "--help" || "$1" == "-h" || $# -lt 3 ]]; then
    echo "Usage: ksecret <namespace> <secret-name> <key>"
    echo "Example:"
    echo "  kdecrypt dsp-cde-graphdb-endpoint-blue endpoint dsp"
    echo "  # Prints the decoded value of 'endpoint' from the given secret"
    return 0
  fi

  local secret_name=$1
  local key=$2
  local namespace=$3

  echo "Fetching '$key' from secret '$secret_name' in namespace '$namespace'..."
  kubectl get secret "$secret_name" -n "$namespace" -o jsonpath="{.data.$key}" | base64 --decode
  echo
}
