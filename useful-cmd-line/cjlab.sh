# Start a Jupyter Lab server inside the NEDAS tutorials container.
# Defaults to localhost only (reach via an SSH tunnel to this node).
# On a compute node, pass --ip to bind to the node's hostname/IP so the
# login node can reach it, e.g.  cjlab-open --ip "$(hostname -s)"
#
# Usage: cjlab-open [--ip ADDR] [--port PORT | PORT]
#   default ip   = 127.0.0.1
#   default port = 8890
cjlab-open() {
    local ip="127.0.0.1" port="8890"
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --ip)     ip="$2";          shift 2 ;;
            --ip=*)   ip="${1#*=}";     shift   ;;
            --port)   port="$2";        shift 2 ;;
            --port=*) port="${1#*=}";   shift   ;;
            -h|--help)
                echo "Usage: cjlab-open [--ip ADDR] [--port PORT | PORT]"
                return 0 ;;
            *)        port="$1";        shift   ;;  # bare arg = port (back-compat)
        esac
    done
    apptainer exec /cluster/projects/nn2993k/timith/nedas-tutorials_latest.sif \
        jupyter lab --no-browser --ip="${ip}" --port="${port}"
}
