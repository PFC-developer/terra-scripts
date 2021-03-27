#!/usr/bin/env bash
source settings.default
source settings.private
echo "Using Project ID ${PROJECT_ID} to create VMs in zone ${DEFAULT_ZONE}"
echo "waiting for confirmation. <enter> to continue, ^C to abort"
read

machine_image=$(gcloud compute images list --project cos-cloud --no-standard-images|grep cos-stable|cut -d " " -f1)

gcloud compute instances create validator-01 \
 --image=ubuntu-minimal-2004-focal-v20210325 --image-project=ubuntu-os-cloud \
    --zone ${DEFAULT_ZONE} \
    --machine-type ${MACHINE_TYPE} \
    --tags=validator \
    --boot-disk-size=200G &

gcloud compute instances create feeder-01 \
    --image  ${machine_image} \
    --image-project cos-cloud \
    --zone ${DEFAULT_ZONE} \
    --tags=feeder \
    --machine-type ${MACHINE_TYPE} &

gcloud compute instances create oracle-01 \
    --image  ${machine_image} \
    --image-project cos-cloud \
    --zone ${DEFAULT_ZONE} \
    --tags=oracle \
    --machine-type ${MACHINE_TYPE} &

gcloud compute disks create validator-01-disk \
  --size ${VALIDATOR_DISK_SIZE} \
  --type ${VALIDATOR_DISK_TYPE} &
wait

gcloud compute instances attach-disk validator-01 \
  --disk validator-01-disk