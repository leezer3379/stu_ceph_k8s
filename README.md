# vagrant 部署 虚拟机初始化 测试环境
#### 参考文档 : http://note.youdao.com/noteshare?id=a7ecfa92e92c46db3d1babb86dcc66a3

### 介绍

本项目通过 vagrant 自动化脚本完成，测试环境部署，降低安装成本，提高生产效率

### 配置介绍

** Ansible 实验环境 **
|     IP          |   username  |
| -------------   |-------------|
| 192.168.100.104 | node-4      |
| 192.168.100.105 | node-5      |

### 快速体验

**软件版本**

| 软件名称     | 版本          |
| -------------|-------------  |
| ansible      | pip3 安装 升级|
| python3      | python3.6.3   |

## 安装 vagrant 安装virtualbox
```
1. 安装virtualbox

2. 安装vagrant

(直接去官网下载安装即可)
```
下载Centos 可以在这里参考
- www.vagrantbox.es 


#### 安装方法请看官网 https://github.com/hashicorp/vagrant


```
初始化一个工作目录
mkdir -p /Users/lize/stu_playbook
cd /Users/lize/stu_playbook
vagrant init # 生成Vagrantfile文件
根据需求编写脚本文件此文件符合ruby语法


```
## 样例：
## 功能介绍：
- 选择镜像设置虚拟机的名称
- 网络
- IP
- 内存大小
- cpus
- username
- user
- password
- 挂在本地的目录到虚拟机
- 设置163 yum 源
- 修改该时区
- 关闭防火墙
- 禁用selinux
- 禁用IPv6内核参数
- 安装基础组件
- 添加用户ifneolse
- 设置用户ssh key登陆
- 添加本地hosts解析



```
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
```
### 启动
```
vagrant up
```


vagrant up 启动虚拟机等待完毕后就可以看到两台虚拟机了
![image](https://note.youdao.com/yws/public/resource/f4adbece08d04ad79f5f68e97177f7ce/xmlnote/9CE0FFA9117E493EB37182EF78A3CD8E/5984)


### 查看结果验证
![image](https://note.youdao.com/yws/public/resource/f4adbece08d04ad79f5f68e97177f7ce/xmlnote/FAEF09FB83AE4234BB43DF4E891A7739/5118)
## 进入主机

```
vagrant ssh ceph-node-1
cd /vagrant/ansible
ansible-playbook -i hosts.yaml install.yaml

[root@ceph-node-1 ansible]# ansible-playbook -i hosts.yaml install.yaml -C
 [WARNING]: Found both group and host with same name: ceph-client


PLAY [安装ceph-deploy] *******************************************************************************************************************************************************************************************************************************************

TASK [ceph-deploy : 安装ceph-deploy] *****************************************************************************************************************************************************************************************************************************
ok: [ceph-node-1]

TASK [ceph-deploy : 替换配置文件] ************************************************************************************************************************************************************************************************************************************
ok: [ceph-node-1]

TASK [ceph-deploy : 创建目录] **************************************************************************************************************************************************************************************************************************************
changed: [ceph-node-1] => (item=/ect/ceph)

TASK [ceph-deploy : change the user root password] *************************************************************************************************************************************************************************************************************
skipping: [ceph-node-1]

PLAY [安装ceph] **************************************************************************************************************************************************************************************************************************************************

TASK [install-ceph : 安装ceph前的工作] *******************************************************************************************************************************************************************************************************************************
skipping: [ceph-node-1] => (item=yum clean all) 
skipping: [ceph-node-1] => (item=yum -y install epel-release) 
skipping: [ceph-node-1] => (item=yum -y install yum-plugin-priorities) 
skipping: [ceph-node-1] => (item=rpm --import https://download.ceph.com/keys/release.asc) 
skipping: [ceph-node-1] => (item=yum remove -y ceph-release) 
skipping: [ceph-node-1] => (item=yum install -y https://download.ceph.com/rpm-jewel/el7/noarch/ceph-release-1-0.el7.noarch.rpm) 
skipping: [ceph-node-1] => (item=yum -y install ceph ceph-radosgw) 

TASK [install-ceph : 安装ceph] ***********************************************************************************************************************************************************************************************************************************
skipping: [ceph-node-1]

PLAY [创建监控] ****************************************************************************************************************************************************************************************************************************************************

TASK [install_mon : 创建第一个监控 monitor] ***************************************************************************************************************************************************************************************************************************
skipping: [ceph-node-1]

TASK [install_mon : 创建mon slave] *******************************************************************************************************************************************************************************************************************************
skipping: [ceph-node-1] => (item=ceph-node-2) 
skipping: [ceph-node-1] => (item=ceph-node-3) 

PLAY [创建osd] ***************************************************************************************************************************************************************************************************************************************************

TASK [create_osd : 创建osd] **************************************************************************************************************************************************************************************************************************************
skipping: [ceph-node-1] => (item=ssh ceph-node-1 mkdir /sd{b,c,d}) 
skipping: [ceph-node-1] => (item=ssh ceph-node-1 chown ceph:ceph /sd{b,c,d}) 
skipping: [ceph-node-1] => (item=ssh ceph-node-2 mkdir /sd{b,c,d}) 
skipping: [ceph-node-1] => (item=ssh ceph-node-2 chown ceph:ceph /sd{b,c,d}) 
skipping: [ceph-node-1] => (item=ssh ceph-node-3 mkdir /sd{b,c,d}) 
skipping: [ceph-node-1] => (item=ssh ceph-node-3 chown ceph:ceph /sd{b,c,d}) 
skipping: [ceph-node-1] => (item=ceph-deploy osd create ceph-node-1:/sd{b,c,d}) 
skipping: [ceph-node-1] => (item=ceph-deploy osd activate ceph-node-1:/sd{b,c,d}) 
skipping: [ceph-node-1] => (item=ceph-deploy osd create ceph-node-2:/sd{b,c,d}) 
skipping: [ceph-node-1] => (item=ceph-deploy osd activate ceph-node-2:/sd{b,c,d}) 
skipping: [ceph-node-1] => (item=ceph-deploy osd create ceph-node-3:/sd{b,c,d}) 
skipping: [ceph-node-1] => (item=ceph-deploy osd activate ceph-node-3:/sd{b,c,d}) 

TASK [create_osd : 调整rbd] **************************************************************************************************************************************************************************************************************************************
skipping: [ceph-node-1] => (item=ceph osd pool set rbd pg_num 256) 
skipping: [ceph-node-1] => (item=ceph osd pool set rbd pgp_num 256) 

PLAY [创建mds（cephfs 需要）] ****************************************************************************************************************************************************************************************************************************************

TASK [ceph_mds : 创建MDS] ****************************************************************************************************************************************************************************************************************************************
skipping: [ceph-node-1] => (item=ceph-deploy --overwrite-conf mds create ceph-node-2) 

PLAY RECAP *****************************************************************************************************************************************************************************************************************************************************
ceph-node-1                : ok=3    changed=1    unreachable=0    failed=0   

[root@ceph-node-1 ansible]# ceph -s 
    cluster 2db65bac-9084-4872-98e3-494036408403
     health HEALTH_OK
     monmap e3: 3 mons at {ceph-node-1=192.168.100.105:6789/0,ceph-node-2=192.168.100.106:6789/0,ceph-node-3=192.168.100.107:6789/0}
            election epoch 62, quorum 0,1,2 ceph-node-1,ceph-node-2,ceph-node-3
      fsmap e22: 1/1/1 up {0=ceph-node-2=up:active}
     osdmap e158: 9 osds: 9 up, 9 in
            flags sortbitwise,require_jewel_osds
      pgmap v103054: 896 pgs, 5 pools, 1893 MB data, 575 objects
            165 GB used, 203 GB / 368 GB avail
                 896 active+clean
[root@ceph-node-1 ansible]# 

安装完成ceph 集群就建立起来了， 就可以按照装文档操作了

git init

git remote add .
git commit -m "second commit"
git remote add origin https://github.com/leezer3379/stu_ceph_k8s.git

git remote push -u origin master

```

### 其他文档
1. ceph 安装文档
2. Ceph RBD 集成k8s
3. CephFS 集成k8s
4. Ceph 基本命令
5. http://note.youdao.com/noteshare?id=e9f2de404cf12d2cb0f7a38f99159e57