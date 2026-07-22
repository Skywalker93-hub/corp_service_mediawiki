terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.215.0"
    }
  }

  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket = "terraform-state-urnwerwer"
    region = "ru-central1"
    key    = "project2/terraform-mediawiki.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true 
    skip_s3_checksum            = true 

  }
  required_version = "~> 1.12"
}

// Configure the Yandex Cloud Provider 
provider "yandex" {
  service_account_key_file = pathexpand("~/.config/yandex-cloud/terraform-aiz-sa-key.json")
  zone      = "ru-central1-a"
}







