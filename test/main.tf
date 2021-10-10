module "cloud_scheduler" {
  source      = "../"
  name        = "setting_up_cs_test"
  description = "Setting up CS, A human-readable description for the job"
  project     = "driven-lore-328513"
  schedule    = "*/8 * * * *"
  # pubsub_target = {
  #   topic_name = "projects/my-project/topics/my-topic"
  #   data       = "{\"hello\": \"world\"}"
  # }

  http_target = {
    uri         = "https://dataflow.googleapis.com/v1b3/projects/PROJECT_ID/templates:launch?gcsPath=gs://bt-backup-bucket/dataflow-templates/20211009/Cloud_Bigtable_to_GCS_Avro"
    http_method = "POST"
    oauth_token = {
      service_account_email = "bq-backups@driven-lore-328513.iam.gserviceaccount.com"
    }
    body = <<-EOT
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
  }
  retry_config = {
    retry_count = 1
  }
}
