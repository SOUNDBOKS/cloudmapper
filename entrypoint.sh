#!/bin/sh

# load the environement variables with your values
source .env

# Configure the AWS CLI inside the container
aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
aws configure set region ${AWS_DEFAULT_REGION}
aws configure set output json

if grep -q "${ACCOUNT}" config.json
then
    echo "${ACCOUNT} already exists in config.json, skipping 'configure add-account'"
else
    # Generate config.json with our account settings
    python cloudmapper.py configure add-account --config-file config.json --name ${ACCOUNT} --id ${ACCOUNT} --default true
fi

# Collect info about our AWS infrastructure, store this in /account-data, which
# is volumed to the host.
python cloudmapper.py collect --account ${ACCOUNT}

python cloudmapper.py report --account ${ACCOUNT}

# Prepare the collected data for serving
python cloudmapper.py prepare --account ${ACCOUNT}

# Start serving on :8000 (by default), --public means bind to 0.0.0.0
python cloudmapper.py webserver --public
