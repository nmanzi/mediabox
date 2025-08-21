#!/bin/bash

# Docker Compose Update and Cleanup Script
# Updates all images in a docker-compose file and removes unused images

set -e  # Exit on any error

# Configuration
COMPOSE_FILE="docker-compose.yaml"
SCRIPT_NAME=$(basename "$0")

# Colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Colour

# Function to print coloured output
print_status() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

print_success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

print_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

# Function to check if docker-compose file exists
check_compose_file() {
    if [ ! -f "$COMPOSE_FILE" ]; then
        print_error "Docker compose file '$COMPOSE_FILE' not found in current directory"
        exit 1
    fi
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running or not accessible"
        exit 1
    fi
}

# Function to display usage
usage() {
    echo "Usage: $SCRIPT_NAME [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -f, --file FILE     Specify docker-compose file (default: docker-compose.yml)"
    echo "  -y, --yes          Skip confirmation prompts"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "This script will:"
    echo "  1. Stop all services defined in the docker-compose file"
    echo "  2. Pull latest versions of all images"
    echo "  3. Start services with updated images"
    echo "  4. Remove unused Docker images"
}

# Parse command line arguments
SKIP_CONFIRMATION=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--file)
            COMPOSE_FILE="$2"
            shift 2
            ;;
        -y|--yes)
            SKIP_CONFIRMATION=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    print_status "Starting Docker Compose update process"
    
    # Pre-flight checks
    check_docker
    check_compose_file
    
    print_status "Using docker-compose file: $COMPOSE_FILE"
    
    # Confirmation prompt
    if [ "$SKIP_CONFIRMATION" = false ]; then
        echo ""
        print_warning "This will stop all services, update images, and remove unused images."
        read -p "Do you want to continue? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Operation cancelled"
            exit 0
        fi
    fi
    
    echo ""
    
    # Step 1: Stop all services
    print_status "Stopping Docker Compose services..."
    if docker-compose -f "$COMPOSE_FILE" down; then
        print_success "Services stopped successfully"
    else
        print_error "Failed to stop services"
        exit 1
    fi
    
    echo ""
    
    # Step 2: Pull latest images
    print_status "Pulling latest images..."
    if docker-compose -f "$COMPOSE_FILE" pull; then
        print_success "Images pulled successfully"
    else
        print_error "Failed to pull images"
        exit 1
    fi
    
    echo ""
    
    # Step 3: Start services with updated images
    print_status "Starting services with updated images..."
    if docker-compose -f "$COMPOSE_FILE" up -d; then
        print_success "Services started successfully"
    else
        print_error "Failed to start services"
        exit 1
    fi
    
    echo ""
    
    # Step 4: Remove unused images
    print_status "Removing unused Docker images..."
    if docker image prune -a -f; then
        print_success "Unused images removed successfully"
    else
        print_warning "Failed to remove unused images (non-critical)"
    fi
    
    echo ""
    
    # Step 5: Show running services
    print_status "Current service status:"
    docker-compose -f "$COMPOSE_FILE" ps
    
    echo ""
    print_success "Docker Compose update process completed successfully!"
    
    # Show disk space saved
    print_status "Docker system disk usage:"
    docker system df
}

# Trap to handle script interruption
trap 'print_error "Script interrupted"; exit 1' INT TERM

# Run main function
main
