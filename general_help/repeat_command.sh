repeat() {
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<EOF
    Usage:
      repeat <seconds> <your-command>

    Description:
      Repeats a given command every <seconds>.

    Example:
      repeat 5 kubectl get pods

    This will rerun:
      'kubectl get pods'
      every 5 seconds.

    Options:
      -h, --help    Show this help message.
EOF
    return 0
  fi

  if [[ $# -lt 2 || ! "$1" =~ ^[0-9]+$ ]]; then
    echo "Usage: repeat <seconds> <your-command>"
    return 1
  fi

  local interval="$1"
  shift
  local command="$*"

  echo "Repeating: $command every $interval seconds..."
  while true; do
    clear
    echo "\$ $command"
    eval "$command"
    sleep "$interval"
  done
}