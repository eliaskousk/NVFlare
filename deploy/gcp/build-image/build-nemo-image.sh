#!/bin/bash

cd ../../../
gcloud builds submit --config deploy/gcp/build-image/cloudbuild-nemo.yaml
