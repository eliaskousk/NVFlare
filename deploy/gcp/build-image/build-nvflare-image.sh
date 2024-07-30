#!/bin/bash

cd ../../../
gcloud builds submit --config deploy/gcp/build-image/cloudbuild-nvflare.yaml
