Vagrant.configure("2") do |config|
	config.vm.define "kubemaster" do |kub|
		kub.vm.box = "ubuntu/focal64"
		kub.vm.hostname = "kubemaster"

		kub.vm.network "private_network", ip: "192.168.56.101"

		kub.vm.provider "virtualbox" do |v|
			v.customize ["modifyvm", :id, "--groups", "/K8S_CLUSTER"]
			v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
			v.customize ["modifyvm", :id, "--memory", 2048]
			v.customize ["modifyvm", :id, "--name", "kubemaster"]
			v.customize ["modifyvm", :id, "--cpus", "2"]
		end

		kub.vm.provision "kubeadm installation", type:"shell", path: "kubeadm_install.sh"
	end
end
