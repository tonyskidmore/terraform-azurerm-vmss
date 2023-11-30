#cloud-config

---

bootcmd:
  - mkdir -p /etc/systemd/system/walinuxagent.service.d
  - echo "[Unit]\nAfter=cloud-final.service" > /etc/systemd/system/walinuxagent.service.d/override.conf
  - sed "s/After=multi-user.target//g" /lib/systemd/system/cloud-final.service > /etc/systemd/system/cloud-final.service
  - systemctl daemon-reload

package_update: true

apt:
  # preserve_sources_list: true
  sources:
    packages.microsoft.com.azurecli.list:
      source: "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ focal main"
      keyid: BC528686B50D79E339D3721CEB3E94ADBE1229CF

packages:
  - apt-transport-https
  - azure-cli
  - ca-certificates
  - curl
  - jq
  - wget
