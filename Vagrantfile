
Vagrant.configure(2) do |config|
  #Ubuntu 14.04 box.
  #More/different boxes are available on https://atlas.hashicorp.com/boxes/
  config.vm.box = "ubuntu/trusty64"
  config.vm.box_url = 'https://vagrantcloud.com/ubuntu/boxes/trusty64/versions/14.04/providers/virtualbox.box'
  config.vm.network :forwarded_port, guest:4444, host:4444

  config.vm.provider "virtualbox" do |vb|
      # These numbers are based on a host with:
      # 16 GB memory
      # i7 CPU
      vb.memory = "4096"
      vb.cpus = "4"

      # Some misc settings
      vb.gui = true
      vb.name = "vagrant_dev_box"
    end

  # script for provisioning dependencies
  config.vm.provision :shell, path: "bootstrap.sh"

end
