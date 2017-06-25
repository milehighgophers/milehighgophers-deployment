
resource "digitalocean_ssh_key" "mhg" {
    name = "mhg-ssh-key"
    public_key = "${file(".secrets/id_rsa.pub")}"
}

data "template_file" "main_cloud_config" {
    template = "${file("cloud-config/main.yml")}"
    vars {
        authorized_key = "${digitalocean_ssh_key.mhg.public_key}"
    }
}

resource "digitalocean_droplet" "mhg_website" {
    image = "ubuntu-16-10-x64"
    name = "mhg-website"
    region = "nyc1"
    size = "512mb"
    ssh_keys = ["${digitalocean_ssh_key.mhg.id}"]
    user_data = "${data.template_file.main_cloud_config.rendered}"
}

resource "digitalocean_floating_ip" "mhg" {
    droplet_id = "${digitalocean_droplet.mhg_website.id}"
    region = "${digitalocean_droplet.mhg_website.region}"
}

resource "digitalocean_domain" "www_milehighgophers_com" {
    name       = "www.milehighgophers.com"
    ip_address = "${digitalocean_floating_ip.mhg.ip_address}"
}

resource "digitalocean_domain" "milehighgophers_com" {
    name       = "milehighgophers.com"
    ip_address = "${digitalocean_floating_ip.mhg.ip_address}"
}

output "ip" {
    value = "${digitalocean_floating_ip.mhg.ip_address}"
}
