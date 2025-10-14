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