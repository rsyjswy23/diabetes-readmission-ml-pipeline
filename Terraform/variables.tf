variable "project" {
  description = "Project"
  default     = "animated-scope-447904-d6"
}

variable "region" {
  description = "Region"
  default     = "us-west1"
}

variable "location" {
  description = "GCS Bucket and BQ Location"
  default     = "us-west1"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  default     = "animated-scope-117904-d6-diabetes-bucket"
}

variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  default     = "diabetes_bq"
}