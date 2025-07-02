# This helper repeats a command given, good uses are
# - when kubernetes does not refresh the times of resources
# - when polling something for status
# - when testing and regularly curling 

repeat() {
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<EOF
Usage:
  repeat <your-command> repeat <seconds>

Description:
  Repeats a given command (excluding the trailing 'repeat <seconds>')
  every <seconds>.

Example:
  repeat kubectl get jobs -n dsp-geoserver repeat 30

This will rerun:
  'kubectl get jobs -n dsp-geoserver'
  every 30 seconds.

Options:
  -h, --help    Show this help message.
EOF
    return 0
  fi

  local args=("$@")
  local count=${#args[@]}

  if [ "$count" -lt 3 ]; then
    echo "Usage: repeat <your-command> repeat <seconds>"
    return 1
  fi

  local maybe_repeat="${args[$((count - 2))]}"
  local interval="${args[$((count - 1))]}"

  if [[ "$maybe_repeat" != "repeat" || ! "$interval" =~ ^[0-9]+$ ]]; then
    echo "Error: the command must end with 'repeat <seconds>'"
    return 1
  fi

  unset 'args[$((count - 1))]'
  unset 'args[$((count - 2))]'
  local command="${args[*]}"

  echo "Repeating: $command every $interval seconds..."
  while true; do
    clear
    echo "\$ $command"
    eval "$command"
    sleep "$interval"
  done
}