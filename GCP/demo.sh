#!/bin/bash
export TESTS="${HOME}/testfiles"
RD="\033[1;31m"
GRN="\033[1;33m"
NC="\033[0;0m"
LB="\033[1;34m"

# Source the common functions
source ./.functions.sh

# Ensure script is ran in quickscan-pro directory
[[ -d demo ]] && [[ -d cloud-function ]] || die "Please run this script from the quickscan-pro root directory"

if [ -z "$1" ]
then
   echo "You must specify 'up' or 'down' to run this script"
   exit 1
fi
# Get the GCP project ID
PROJECT_ID=$(gcp_get_project_id)
MODE=$(echo "$1" | tr [:upper:] [:lower:])
if [[ "$MODE" == "up" ]]
then
    echo "--------------------------------------------------"
    echo "Using GCP project ID: $PROJECT_ID"
    echo "--------------------------------------------------"
	read -sp "CrowdStrike API Client ID: " FID
	echo
	read -sp "CrowdStrike API Client SECRET: " FSECRET
    echo

    # Make sure variables are not empty
    if [ -z "$FID" ] || [ -z "$FSECRET" ]
    then
        die "You must specify a valid CrowdStrike API Client ID and SECRET"
    fi

    # Verify the CrowdStrike API credentials
    echo "Verifying CrowdStrike API credentials..."
    cs_falcon_cloud="us-1"
    response_headers=$(mktemp)
    cs_verify_auth
    # Get the base URL for the CrowdStrike API
    cs_set_base_url
    echo "Falcon Cloud URL set to: $(cs_cloud)"
    # Cleanup tmp file
    rm "${response_headers}"

    # Initialize Terraform
    if ! [ -f demo/.terraform.lock.hcl ]; then
        terraform -chdir=demo init
    fi
    # Apply Terraform
	terraform -chdir=demo apply -compact-warnings --var falcon_client_id=$FID \
        --var falcon_client_secret=$FSECRET --var project_id=$PROJECT_ID \
        --var base_url=$(cs_cloud) --auto-approve
    echo -e "$GRN\nPausing for 30 seconds to allow configuration to settle.$NC"
    sleep 30
    configure_cloud_shell "demo"
	exit 0
fi
if [[ "$MODE" == "down" ]]
then
    # Destroy Terraform
    success=1
    while [ $success -ne 0 ]; do
        terraform -chdir=demo destroy -compact-warnings --var project_id=$PROJECT_ID --auto-approve
        success=$?
        if [ $success -ne 0 ]; then
            echo -e "$RD\nTerraform destroy failed. Retrying in 5 seconds.$NC"
            sleep 5
        fi
    done
    sudo rm /usr/local/bin/get-findings /usr/local/bin/upload /usr/local/bin/list-bucket 2>/dev/null
    rm -rf $TESTS /tmp/malicious 2>/dev/null
    env_destroyed
	exit 0
fi
die "Invalid command specified."
