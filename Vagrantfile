# Path to the script that will be used to join K8S cluster by nodes
# This file will be dynamically created during the K8S master configuration
k8s_join_cluster_script = "tmp/join_k8s_cluster.sh"

# Path to the share mount point that will be used to store the K8S cluster join script
# MUST be located on a drive mounted on all VMs
# By default, we are using the auto-mounted `/vagrant` directory which is the current dir of our Vagrantfile
k8s_join_cluster_script_share_mount="/vagrant"

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
		master.vm.provision "Join command", type: "shell", path: "scripts/gen_node_join_cmd.sh", args: [k8s_join_cluster_script_share_mount, k8s_join_cluster_script]
	end
	
	config.vm.define "node" do |node|
		node.vm.hostname = "kubenode"

		node.vm.network "private_network", ip: "192.168.56.102", hostname: true

		node.vm.provider "virtualbox" do |v|
			v.customize ["modifyvm", :id, "--name", "kubenode"]
		end
		
		node.vm.provision "Join cluster", type: "shell", path: k8s_join_cluster_script
	end
end
