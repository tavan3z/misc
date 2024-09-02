#!/bin/bash

# Function to display and select an option from a list
function select_option {
    local prompt="$1"
    shift
    local options=("$@")
    PS3="$prompt"
    select opt in "${options[@]}" "Quit"; do
        if [[ $REPLY -ge 1 && $REPLY -le ${#options[@]} ]]; then
            echo "$opt"
            return
        elif [[ $REPLY -eq $((${#options[@]} + 1)) ]]; then
            echo "Exiting."
            exit 0
        else
            echo "Invalid option. Try another one."
        fi
    done
}

# Check for correct number of arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <AWS_REGION> <AWS_PROFILE>"
    exit 1
fi

# Assign arguments to variables
AWS_REGION=$1
AWS_PROFILE=$2

echo -e "Select options using numbers and press Enter."
# List ECS clusters
echo "Fetching ECS clusters..."
CLUSTERS=$(aws ecs list-clusters --region $AWS_REGION --profile $AWS_PROFILE --output text --query 'clusterArns[*]')

# Convert the clusters into an array
CLUSTERS_ARRAY=($CLUSTERS)

if [ ${#CLUSTERS_ARRAY[@]} -eq 0 ]; then
    echo "No clusters found."
    exit 1
fi

# Select a cluster
SELECTED_CLUSTER=$(select_option "Select a cluster: " "${CLUSTERS_ARRAY[@]}")

# List ECS services in the selected cluster
echo "Fetching services in cluster: $SELECTED_CLUSTER..."
SERVICES=$(aws ecs list-services --cluster $SELECTED_CLUSTER --region $AWS_REGION --profile $AWS_PROFILE --output text --query 'serviceArns[*]')

# Convert the services into an array
SERVICES_ARRAY=($SERVICES)

if [ ${#SERVICES_ARRAY[@]} -eq 0 ]; then
    echo "No services found."
    exit 1
fi

# Select a service
SELECTED_SERVICE=$(select_option "Select a service: " "${SERVICES_ARRAY[@]}")

# List ECS tasks in the selected service
echo "Fetching tasks in service: $SELECTED_SERVICE..."
TASKS=$(aws ecs list-tasks --cluster $SELECTED_CLUSTER --service-name $SELECTED_SERVICE --region $AWS_REGION --profile $AWS_PROFILE --output text --query 'taskArns[*]')

# Convert the tasks into an array
TASKS_ARRAY=($TASKS)

if [ ${#TASKS_ARRAY[@]} -eq 0 ]; then
    echo "No tasks found."
    exit 1
fi

# Select a task
SELECTED_TASK=$(select_option "Select a task: " "${TASKS_ARRAY[@]}")

# List containers in the selected task
echo "Fetching containers in task: $SELECTED_TASK..."
CONTAINERS=$(aws ecs describe-tasks --cluster $SELECTED_CLUSTER --tasks $SELECTED_TASK --region $AWS_REGION --profile $AWS_PROFILE --query 'tasks[0].containers[*].name' --output text)

# Convert the containers into an array
CONTAINERS_ARRAY=($CONTAINERS)

if [ ${#CONTAINERS_ARRAY[@]} -eq 0 ]; then
    echo "No containers found."
    exit 1
fi

# Select a container if more than one is available
SELECTED_CONTAINER=$(select_option "Select a container: " "${CONTAINERS_ARRAY[@]}")

# Prompt for a command to run or just start bash
read -p "Enter command to run on the container (default: /bin/bash): " COMMAND
COMMAND=${COMMAND:-/bin/bash}

# Execute the command on the selected task and container
echo "Connecting to task $SELECTED_TASK, container $SELECTED_CONTAINER..."
aws ecs execute-command \
    --cluster $SELECTED_CLUSTER \
    --task $SELECTED_TASK \
    --region $AWS_REGION \
    --profile $AWS_PROFILE \
    --container $SELECTED_CONTAINER \
    --interactive \
    --command "$COMMAND"
