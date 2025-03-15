#!/bin/bash

# ollama-docker.sh - A wrapper script for managing Ollama in Docker
# Usage: ./ollama-docker.sh [command] [options]

# Set default container name
CONTAINER_NAME="ollama"

# Function to display help message
show_help() {
    echo "Ollama Docker Wrapper Script"
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  run              Run the Ollama container"
    echo "  start            Start an existing Ollama container"
    echo "  stop             Stop the Ollama container"
    echo "  pull MODEL       Pull a model (e.g., llama3, mistral, etc.)"
    echo "  list             List available models"
    echo "  rm MODEL_ID      Remove a model by ID"
    echo "  status           Check container status"
    echo "  logs             Show container logs"
    echo "  help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 run           Run the Ollama container"
    echo "  $0 pull llama3   Pull the llama3 model"
    echo "  $0 list          List available models"
    echo "  $0 rm model_id   Remove the specified model"
}

# Function to check if the container exists
container_exists() {
    docker ps -a -f name=${CONTAINER_NAME} --format '{{.Names}}' | grep -q ${CONTAINER_NAME}
}

# Function to check if the container is running
container_running() {
    docker ps -f name=${CONTAINER_NAME} --format '{{.Names}}' | grep -q ${CONTAINER_NAME}
}

# Main script logic
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

COMMAND=$1
shift

case "$COMMAND" in
    run)
        if container_exists; then
            echo "Container '$CONTAINER_NAME' already exists. Use 'start' to start it or remove it first."
            exit 1
        fi
        
        echo "Running Ollama container..."
        docker run -d --runtime=nvidia --gpus all -p 11434:11434 \
            -v ollama:/root/.ollama --name ${CONTAINER_NAME} \
            -e OLLAMA_FLASH_ATTENTION=1 -e OLLAMA_KV_CACHE_TYPE=q8_0 \
            ollama/ollama
        
        if [ $? -eq 0 ]; then
            echo "Ollama container started successfully."
        else
            echo "Failed to start Ollama container."
        fi
        ;;
        
    start)
        if ! container_exists; then
            echo "Container '$CONTAINER_NAME' does not exist. Use 'run' to create it first."
            exit 1
        fi
        
        if container_running; then
            echo "Container '$CONTAINER_NAME' is already running."
            exit 0
        fi
        
        echo "Starting Ollama container..."
        docker start ${CONTAINER_NAME}
        
        if [ $? -eq 0 ]; then
            echo "Ollama container started successfully."
        else
            echo "Failed to start Ollama container."
        fi
        ;;
        
    stop)
        if ! container_running; then
            echo "Container '$CONTAINER_NAME' is not running."
            exit 0
        fi
        
        echo "Stopping Ollama container..."
        docker stop ${CONTAINER_NAME}
        
        if [ $? -eq 0 ]; then
            echo "Ollama container stopped successfully."
        else
            echo "Failed to stop Ollama container."
        fi
        ;;
        
    pull)
        if [ $# -eq 0 ]; then
            echo "Error: No model specified."
            echo "Usage: $0 pull MODEL"
            exit 1
        fi
        
        MODEL=$1
        
        if ! container_running; then
            echo "Container '$CONTAINER_NAME' is not running. Starting it..."
            docker start ${CONTAINER_NAME}
        fi
        
        echo "Pulling model '$MODEL'..."
        docker exec -it ${CONTAINER_NAME} ollama pull $MODEL
        ;;
        
    list)
        if ! container_running; then
            echo "Container '$CONTAINER_NAME' is not running. Starting it..."
            docker start ${CONTAINER_NAME}
        fi
        
        echo "Listing available models..."
        docker exec -it ${CONTAINER_NAME} ollama list
        ;;
        
    rm)
        if [ $# -eq 0 ]; then
            echo "Error: No model ID specified."
            echo "Usage: $0 rm MODEL_ID"
            exit 1
        fi
        
        MODEL_ID=$1
        
        if ! container_running; then
            echo "Container '$CONTAINER_NAME' is not running. Starting it..."
            docker start ${CONTAINER_NAME}
        fi
        
        echo "Removing model '$MODEL_ID'..."
        docker exec -it ${CONTAINER_NAME} ollama rm $MODEL_ID
        ;;
        
    status)
        if ! container_exists; then
            echo "Container '$CONTAINER_NAME' does not exist."
        elif container_running; then
            echo "Container '$CONTAINER_NAME' is running."
        else
            echo "Container '$CONTAINER_NAME' is stopped."
        fi
        ;;
        
    logs)
        echo "Showing container logs..."
        docker logs ${CONTAINER_NAME}
        ;;
        
    help)
        show_help
        ;;
        
    *)
        echo "Unknown command: $COMMAND"
        show_help
        exit 1
        ;;
esac
