Vagrant.configure("2") do |config|
	config.vm.box = "ubuntu/focal64"
	
	config.vm.provision "kubeadm installation", type:"shell", path: "scripts/kubeadm_install.sh"
	
	config.vm.provider "virtualbox" do |v|
		v.customize ["modifyvm", :id, "--groups", "/K8S_CLUSTER"]
		v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
		v.customize ["modifyvm", :id, "--memory", 2048]
		v.customize ["modifyvm", :id, "--cpus", "2"]
	end
	
	config.vm.define "master" do |master|
		master_ip = "192.168.56.101"
		
		master.vm.hostname = "kubemaster"

		master.vm.network "private_network", ip: master_ip, hostname: true

		master.vm.provider "virtualbox" do |v|
			v.customize ["modifyvm", :id, "--name", "kubemaster"]
		end

		master.vm.provision "K8S master node", type:"shell", path: "scripts/k8s_master.sh", args: [master_ip]
	end
	
	config.vm.define "node" do |node|
		node.vm.hostname = "kubenode"

		node.vm.network "private_network", ip: "192.168.56.102", hostname: true

		node.vm.provider "virtualbox" do |v|
			v.customize ["modifyvm", :id, "--name", "kubenode"]
		end
	end
end
