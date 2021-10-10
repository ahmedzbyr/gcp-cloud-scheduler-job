# google_cloud_scheduler_job

A scheduled job that can publish a pubsub message or a http request every X interval of time, using crontab format string.
To use Cloud Scheduler your project must contain an App Engine app that is located in one of the supported regions.
If your project does not have an App Engine app, you must create one.

API Documentation : [Cloud Scheduler API](https://cloud.google.com/scheduler/docs/reference/rest/)

[Work in progress]

## Compatibility

This module is meant for use with Terraform 0.14.

## Usage 

Basic usage. `tfvars` file.

```hcl
name        = "setting_up_cs_test"
description = "Setting up CS, A human-readable description for the job"
project     = "flash-proxy-307407"

# pubsub_target = {
#   topic_name = "projects/my-project/topics/my-topic"
#   data       = "{\"hello\": \"world\"}"
# }

http_target = {
  uri         = "https://some.com/"
  http_method = "POST"
  body        = <<-EOT
    {
      "jobName": "bt-backups-cloud-scheduler",
      "parameters": {
        "bigtableProjectId": "PROJECT_ID",
        "bigtableInstanceId": "bt-instance-a",
        "bigtableTableId": "table-to-backup",
        "outputDirectory": "gs://bt-backup-bucket/backups",
        "filenamePrefix" : "bt-backups-"
      },
      "environment": {
        "numWorkers": "3",
        "maxWorkers": "10",
        "tempLocation": "gs://bt-backup-bucket/temp",
        "serviceAccountEmail": "bt-backups@PROJECT_ID.iam.gserviceaccount.com",
        "additionalExperiments": ["use_network_tags=my-net-tag-name"], # Tag for any firewall rules on the shared VPC.
        "subnetwork": "https://www.googleapis.com/compute/v1/projects/HOST_PROJECT_ID/regions/REGION/subnetworks/SUBNETWORK",
        "ipConfiguration": "WORKER_IP_PRIVATE",
        "workerRegion": "us-central1"         
      }
    }
EOT
  headers = {
    key = "value"
  }
  oauth_token = {
    service_account_email = "bt-backups@PROJECT_ID.iam.gserviceaccount.com"
  }
}
```