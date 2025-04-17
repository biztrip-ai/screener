#!/bin/bash

# Function to display usage information
usage() {
  echo "Usage: $0 [build|run|shell] [options]"
  echo ""
  echo "Commands:"
  echo "  build           Build the Docker image"
  echo "  run             Run the Docker container"
  echo "  shell           Start an interactive bash shell in the container"
  echo ""
  echo "Options for run/shell:"
  echo "  -e, --env FILE  Specify .env file (default: .env)"
  echo "  -v, --volume DIR Mount local directory to /app/runtime (default: $(pwd)/runtime)"
  echo "  -p, --port PORT Map container port 80 to specified host port (default: 8080)"
  echo "  -d, --detach    Run container in detached mode (not applicable for shell)"
  echo ""
  echo "Examples:"
  echo "  $0 build"
  echo "  $0 run --env .env.local --volume ./data --port 3000"
  echo "  $0 shell --volume ./data"
  exit 1
}

# Handle build command
build_image() {
  echo "Building Docker image: screener:latest"
  docker build --no-cache -t screener:latest .
}

# Handle run command
run_container() {
  local ENV_FILE=".env"
  local VOLUME="-v $(pwd)/runtime:/app/runtime"  # Default volume
  local VOLUME_SPECIFIED=false
  local PORT="8080:80"
  local DETACH=""
  local CMD_OVERRIDE=""
  local INTERACTIVE=""

  # Check if this is a shell command
  if [ "$1" = "shell" ]; then
    CMD_OVERRIDE="--entrypoint bash"
    INTERACTIVE="-it"
    shift
  fi
  INTERACTIVE="-it"
  
  # Parse run options
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -e|--env)
        ENV_FILE="$2"
        shift 2
        ;;
      -v|--volume)
        VOLUME="-v $2:/app/runtime"
        VOLUME_SPECIFIED=true
        shift 2
        ;;
      -p|--port)
        PORT="$2:80"
        shift 2
        ;;
      -d|--detach)
        if [ -z "$CMD_OVERRIDE" ]; then  # Don't allow detach for shell
          DETACH="-d"
        else
          echo "Warning: --detach is ignored for shell command"
        fi
        shift
        ;;
      *)
        echo "Unknown option: $1"
        usage
        ;;
    esac
  done

  # Ensure runtime directory exists if using default volume
  if [ "$VOLUME_SPECIFIED" = false ]; then
    mkdir -p "$(pwd)/runtime"
    echo "Using default volume: $(pwd)/runtime"
  fi

  # Construct and execute docker run command
  CMD="docker run $INTERACTIVE $DETACH -p 8086:8086 -p 3000:3000"
  
  # Add volume
  CMD="$CMD $VOLUME"
  
  # Add env file
  if [ -f "$ENV_FILE" ]; then
    CMD="$CMD --env-file $ENV_FILE"
  else
    echo "Warning: Environment file $ENV_FILE not found"
  fi
  
  # Add entrypoint override if shell
  if [ -n "$CMD_OVERRIDE" ]; then
    CMD="$CMD $CMD_OVERRIDE"
  fi
  
  # Add image name
  CMD="$CMD screener:latest"
  
  echo "Running container with command: $CMD"
  eval $CMD
}

# Main script logic
if [ $# -lt 1 ]; then
  usage
fi

case "$1" in
  build)
    build_image
    ;;
  run)
    shift  # Remove 'run' argument
    run_container "$@"
    ;;
  shell)
    shift  # Remove 'shell' argument
    run_container "shell" "$@"
    ;;
  *)
    echo "Unknown command: $1"
    usage
    ;;
esac
