output "YC_region" {
  value = "${yandex_compute_instance.test-7-3[*].zone}"
}

output "Privave_IP" {
  value = "${yandex_compute_instance.test-7-3[*].network_interface[0].ip_address}"
}

output "Subnet_ID" {
  value = "${yandex_compute_instance.test-7-3[*].network_interface[0].subnet_id}"
}
