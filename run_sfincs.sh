#!/bin/bash
set -e 

# Function to display usage information
usage() {
    echo "Usage: $0 [-s|--serverless]"
    echo "  -s, --serverless    Enable serverless pre-processing and post-processing steps"
    exit 1
}

cwd=$(pwd)


# Parse command line options
ENABLE_SERVERLESS=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--serverless)
            ENABLE_SERVERLESS=true
            shift # past argument
            ;;
        *)
            usage
            ;;
    esac
done

# Pre-processing step (if serverless is enabled)
if [ "$ENABLE_SERVERLESS" = true ]; then
    echo "Pre-processing Data (Serverless)"
    curl -X 'GET' \
      'http://localhost:8000/api/v1/publish/start/' \
      -H 'accept: application/json'

    echo "Waiting 20 seconds for outputs to process"
    sleep 5
    echo "Waiting 15 seconds for outputs to process"
    sleep 5
    echo "Waiting 10 seconds for outputs to process"
    sleep 5
    echo "Waiting 5 seconds for outputs to process"
    sleep 5
fi

echo "Pulling image"
docker pull deltares/sfincs-cpu:sfincs-v2.0.3-Cauberg

echo "Copying data"
rm -rf /tmp/sfincs_temp/ && mkdir /tmp/sfincs_temp/
cp -r data/SFINCS/ngwpc_data /tmp/sfincs_temp/

echo "Running SFINCS"
sudo chmod -R 777 /tmp/sfincs_temp/

docker run -v /tmp/sfincs_temp/ngwpc_data/:/data:rw deltares/sfincs-cpu:sfincs-v2.0.3-Cauberg

sudo chmod -R 777 /tmp/sfincs_temp/

echo "Copying Data"
cp -r /tmp/sfincs_temp/ngwpc_data/sfincs_map.nc data/SFINCS/ngwpc_data/

echo "Done Running SFINCS"
