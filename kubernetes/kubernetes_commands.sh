SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

alias k='kubectl'
alias kg='kubectl get'
alias kgp='kubectl get pod'
alias kd='kubectl describe'
alias kdp='kubectl describe pod'
alias kl='kubectl logs'
alias gpods='kubectl get pods -n dsp-geoserver'
alias gjob='kubectl get job -n dsp-geoserver'
alias gjobd='kubectl describe job -n dsp-geoserver'
alias gjobdelete='kubectl delete job sync-geoserver-config -n dsp-geoserver'
alias gjobapply='cd ~/repositories/geoserver && kubectl -n dsp-geoserver apply -f k8s_sync_pods/sync-dsp-geoserver-config.yaml'
alias kroll='kubectl rollout restart deployment'
alias kgroll='kubectl rollout restart deployment geoserver-read -n dsp-geoserver'

ks() {
  local usage="Usage: ks <deployment> <replicas> [kubectl scale options]"
  local example="Example: ks geoserver-ui 2 -n dsp-geoserver"

  if [[ "$1" == "--help" || "$1" == "-h" || $# -lt 2 ]]; then
    echo "$usage"
    echo "$example"
    return 0
  fi

  local deployment=$1
  local replicas=$2
  shift 2

  echo "Running: kubectl scale deployment $deployment --replicas=$replicas $*"
  kubectl scale deployment "$deployment" --replicas="$replicas" "$@"
}

kclean() {
  local usage="Usage: kclean <namespace> <state>"
  local example="Example: kclean dsp-geoserver Error"

  if [[ "$1" == "--help" || "$1" == "-h" || $# -lt 2 ]]; then
    echo "$usage"
    echo "$example"
    return 0
  fi

  local namespace=$1
  local state=$2
  shift 2

  echo "Running: kubectl delete pod -n $namespace \$(kubectl get pods -n $namespace --no-headers | awk -v s=\"$state\" '\$3==s {print \$1}')"
  kubectl delete pod -n "$namespace" $(kubectl get pods -n "$namespace" --no-headers | awk -v s="$state" '$3==s {print $1}')
}

kdecrypt() {
  local usage="Usage: kdecrypt <namespace> <secret-name> <key>"
  local example="Example: kdecrypt dsp dsp-cde-graphdb-endpoint-blue endpoint"

  if [[ "$1" == "--help" || "$1" == "-h" || $# -lt 3 ]]; then
    echo "$usage"
    echo "$example"
    return 0
  fi

  local namespace=$1
  local secret_name=$2
  local key=$3

  echo "Fetching '$key' from secret '$secret_name' in namespace '$namespace'..."
  kubectl get secret "$secret_name" -n "$namespace" -o jsonpath="{.data.$key}" | base64 --decode
  echo
}

kencrypt() {
  local usage="Usage: kencrypt <name> <namespace> <key> <value>"
  local example="Example: kencrypt dsp dsp-bathing-waters-swimfo azurestorageaccountkey mysecretvalue"

  if [[ $# -lt 4 ]]; then
    echo "$usage"
    echo "$example"
    return 1
  fi

  local namespace=$1
  local name=$2
  local key=$3
  local value=$4
  local file="$SCRIPT_DIR/tempsecret.yaml"
  local sealed_file="$SCRIPT_DIR/sealed-secret.yaml"

  # Base64 encode the value
  local encoded_value
  encoded_value=$(echo -n "$value" | base64 -w0)

  # Write the secret YAML directly to the file
  cat > "$file" <<EOF
      apiVersion: v1
      kind: Secret
      type: Opaque
      metadata:
        name: $name
        namespace: $namespace
      data:
        $key: $encoded_value
EOF

  echo "Secret YAML written to $file"

  # Seal the secret
  if command -v kubeseal >/dev/null 2>&1; then
    kubeseal \
      --controller-namespace kube-system \
      --controller-name sealed-secrets-controller \
      --format yaml \
      < "$file" | tee "$sealed_file"
    echo "Sealed secret written to $sealed_file"
  else
    echo "kubeseal not found. Install it to create sealed secrets."
  fi
}


kman() {
  echo "=== Kubernetes Aliases ==="
  # Only reads aliases from the script file, doesn't run anything
  grep -E '^alias k' "$SCRIPT_DIR/$(basename "${BASH_SOURCE[0]}")" | while read -r line; do
    name=$(echo "$line" | cut -d '=' -f1 | awk '{print $2}')
    cmd=$(echo "$line" | cut -d "'" -f2)
    printf "%-15s -> %s\n" "$name" "$cmd"
  done

  echo
  echo "=== Kubernetes Functions ==="
  for fn in ks kclean kdecrypt kencrypt; do
    printf "%-15s -> " "$fn"
    help_output=$("$fn" --help 2>/dev/null | head -n2)
    echo "$help_output" | paste -sd " | " -
  done
}

