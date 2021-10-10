# MIT License
#
# Copyright (c) 2021 AHMED ZBYR
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#


resource "google_cloud_scheduler_job" "cloud_scheduler_job" {
  name        = var.name        # (Required) Name of the job
  description = var.description # (Optional) 
  project     = var.project     # (Required) Current project
  region      = var.region      # (Optional) Region where the scheduler job resides. 
  schedule    = var.schedule    # (Required) Schedule

  # The value of this field must be a time zone name from the tz database.
  time_zone = var.time_zone # (Optional) Specifies the time zone to be used in interpreting schedule.

  #
  # By default, if a job does not complete successfully, meaning that an acknowledgement is not received from the handler,
  # then it will be retried with exponential backoff according to the settings
  #
  dynamic "retry_config" {
    for_each = var.retry_config == null ? [] : [var.retry_config]
    content {
      retry_count          = lookup(retry_config.value, "retry_count", null)          # The number of attempts that the system will make to run a job
      max_retry_duration   = lookup(retry_config.value, "max_retry_duration", null)   # The time limit for retrying a failed job
      min_backoff_duration = lookup(retry_config.value, "min_backoff_duration", null) # The minimum amount of time to wait before retrying
      max_backoff_duration = lookup(retry_config.value, "max_backoff_duration", null) # The maximum amount of time to wait before retrying a job after it fails
      max_doublings        = lookup(retry_config.value, "max_doublings", null)        # The time between retries will double maxDoublings times.
    }
  }

  # Pub/Sub target If the job providers a Pub/Sub target the cron will publish a message to the provided topic
  dynamic "pubsub_target" {
    for_each = var.pubsub_target == null ? [] : [var.pubsub_target]
    content {
      topic_name = pubsub_target.value["topic_name"]               # (Required) The full resource name for the Cloud Pub/Sub topic to which messages will be published when a job is delivered. 
      attributes = lookup(pubsub_target.value, "attributes", null) # (Optional) Attributes for PubsubMessage. 

      # (Optional) The message payload for PubsubMessage.
      data = lookup(pubsub_target.value, "data", null) != null ? base64encode(pubsub_target.value["data"]) : null
    }
  }

  # HTTP target. If the job providers a http_target the cron will send a request to the targeted url 
  dynamic "http_target" {
    for_each = var.http_target == null ? [] : [var.http_target]
    content {
      uri         = http_target.value.uri                          # (Required) The full URI path that the request will be sent to.
      http_method = lookup(http_target.value, "http_method", null) #  (Optional) Which HTTP method to use for the request.
      headers     = lookup(http_target.value, "headers", null)     # (Optional) This map contains the header field names and values. Repeated headers are not supported, but a header value can contain commas.

      # HTTP request body. A request body is allowed only if the HTTP method is POST, PUT, or PATCH. 
      # It is an error to set body on a job with an incompatible HttpMethod. 
      # A base64-encoded string.
      body = lookup(http_target.value, "body", null) != null ? base64encode(http_target.value["body"]) : null

      # (Optional) Contains information needed for generating an OAuth token.
      dynamic "oauth_token" {
        for_each = lookup(http_target.value, "oauth_token", null) == null ? [] : [http_target.value["oauth_token"]]
        content {
          service_account_email = oauth_token.value["service_account_email"] # (Required) Service account email to be used for generating OAuth token. 
          scope                 = lookup(oauth_token.value, "scope", null)   # (Optional) OAuth scope to be used for generating OAuth access token. If not specified, "https://www.googleapis.com/auth/cloud-platform" will be used.
        }
      }

      # (Optional) Contains information needed for generating an OpenID Connect token. 
      dynamic "oidc_token" {
        for_each = lookup(http_target.value, "oidc_token", null) == null ? [] : [http_target.value["oidc_token"]]
        content {
          service_account_email = oidc_token.value["service_account_email"]  # (Required) Service account email to be used for generating OAuth token. 
          audience              = lookup(oidc_token.value, "audience", null) # (Optional) Audience to be used when generating OIDC token. If not specified, the URI specified in target will be used.
        }
      }
    }
  }
}
