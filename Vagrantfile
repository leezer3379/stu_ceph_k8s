# -*- mode: ruby -*-
# vi: set ft=ruby :

vms = {
       "192.168.100.105" => "ceph-node-1",
       "192.168.100.106" => "ceph-node-2",
       "192.168.100.107" => "ceph-node-3",

       "192.168.100.108" => "ceph-client",
       }


Vagrant.configure("2") do |config|
    vms.each do |vm_ip, vm_name|
        config.vm.define vm_name do |node|
            node.vm.box_check_update = false
            # 使用的镜像
            node.vm.box = "bento/centos-7.4"
            # 设置主机名
            node.vm.hostname = vm_name
            # 主机浏览器访问的端口
            # node.vm.network "forwarded_port", guest: 80, host: 8080
            #config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
            # 设置虚拟机的IP 和网络 ——— private_network : host-only ， public_network ： 桥接
            node.vm.network "private_network", ip: vm_ip
            # config.vm.network "public_network"
            # 挂在目录 默认当前执行 vagrant 的目录
            # config.vm.synced_folder "../data", "/vagrant_data"
            # 设置虚拟机的 名称， 内存 ，cpu，是否有GUI界面
            node.vm.provider "virtualbox" do |vb|
                vb.customize ["modifyvm", :id, "--name", vm_name, "--memory", "512", "--cpus", "1"]

            #   # Display the VirtualBox GUI when booting the machine
            #   vb.gui = true
            #   # Customize the amount of memory on the VM:
            #   vb.memory = "1024"
            end
            #
            # View the documentation for the provider you are using for more
            # information on available options.
            # 执行的shell 脚本
            node.vm.provision "shell", inline: <<-SHELL
                chmod 755 /vagrant/.setting/*.sh
                # 设置基本配置
                /vagrant/.setting/config.sh

                # 安装基本组件
                /vagrant/.setting/install.sh

                # 添加用户ifneolse
                /vagrant/.setting/add_user.sh ifnoelse ifnoelse

                # 设置用户ssh key登陆
                /vagrant/.setting/ssh_auth.sh ifnoelse

                # 修改hostname       echo "#{vm_name}">/etc/hostname

                # 添加本地hosts解析
                for i in "#{vms.map{|k,v|"#{k}    #{v}"}.join('" "')}";do echo $i>>/etc/hosts;done

                sed -i '1d' /etc/hosts
                # admin-node 执行
                if [ "ceph-node1" == "#{vm_name}" ];then sudo echo "Host node1\n   Hostname node1\n   User ifnoelse\nHost node2\n   Hostname node2\n   User ifnoelse\nHost node3\n   Hostname node3\n   User ifnoelse\nHost ceph-client\n   Hostname ceph-client\n   User ifnoelse">/home/ifnoelse/.ssh/config;sudo chown -R ifnoelse:ifnoelse /home/ifnoelse;fi
                # 判断node-4 安装特殊的东西

                #if [ "node-4" == "#{vm_name}" ];then yum install -y ansible;pip3 install --upgrade pip -i https://pypi.douban.com/simple/;sudo pip3 install ansible  -i https://pypi.douban.com/simple/;ln -s /usr/local/python3/bin/ansible  /usr/bin/ansible;fi

            #   apt-get update
            #   apt-get install -y apache2
            SHELL
        end
    end
end
