/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

module "cloud-nat" {
  source                             = "terraform-google-modules/cloud-nat/google"
  name                               = "cloud-nat-${var.project_id}"
  create_router                      = true
  network                            = var.network
  project_id                         = var.project_id
  region                             = var.region
  router                             = "router-${var.project_id}"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetworks = [
    {
      name                     = var.subnetwork
      source_ip_ranges_to_nat  = ["ALL_IP_RANGES"]
      secondary_ip_range_names = []
    }
  ]
}

module "forseti-install-simple" {
  source = "../../"

  # General
  project_id = var.project_id
  org_id     = var.org_id
  domain     = var.domain
  network    = var.network
  subnetwork = var.subnetwork

  # Client VM
  client_instance_metadata = var.instance_metadata
  client_private           = var.private
  client_region            = module.cloud-nat.region
  client_tags              = var.instance_tags

  # CloudSQL
  cloudsql_private = var.private
  cloudsql_region  = var.region

  # Server VM
  server_instance_metadata = var.instance_metadata
  server_private           = var.private
  server_region            = module.cloud-nat.region
  server_tags              = var.instance_tags

  # GCS
  storage_bucket_location = var.region
  bucket_cai_location     = var.region

  # Config Validator
  config_validator_enabled        = var.config_validator_enabled
  policy_library_bundle           = var.policy_library_bundle
  policy_library_repository_url   = var.policy_library_repository_url
  policy_library_sync_gcs_enabled = var.policy_library_sync_gcs_enabled

  # Disable Forseti Scanners replaced by Forseti Policy Bundle
  bigquery_enabled            = var.bigquery_enabled
  cloudsql_acl_enabled        = var.cloudsql_acl_enabled
  firewall_rule_enabled       = var.firewall_rule_enabled
  kms_scanner_enabled         = var.kms_scanner_enabled
  service_account_key_enabled = var.service_account_key_enabled

  # Additional Forseti config
  gsuite_admin_email      = var.gsuite_admin_email
  sendgrid_api_key        = var.sendgrid_api_key
  forseti_email_sender    = var.forseti_email_sender
  forseti_email_recipient = var.forseti_email_recipient
  forseti_version         = var.forseti_version
}
