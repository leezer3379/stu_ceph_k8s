# vagrant 部署 虚拟机初始化 测试环境
## 参考文档 ++http://note.youdao.com/noteshare?id=a7ecfa92e92c46db3d1babb86dcc66a3++
# github

## 介绍

本项目通过 vagrant 自动化脚本完成，测试环境部署，降低安装成本，提高生产效率

## 配置介绍

**Ansible 实验环境**
|     IP        |   username    |
| ------------- |:-------------:|
| 192.168.100.104 | node-4 |
| 192.168.100.105 | node-5 |

## 快速体验

**软件版本**

| 软件名称        | 版本        |
| ------------- |:-------------:|
| ansible      | pip3 安装 升级|
| python3      |   python3.6.3|

## 安装 vagrant 安装virtualbox
```
1. 安装virtualbox

2. 安装vagrant

(直接去官网下载安装即可)
```
下载Centos ++www.vagrantbox.es++ 可以在这里参考


## 安装方法请看官网 ++https://github.com/hashicorp/vagrant++


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

vms = {"192.168.100.104" => "node-4",
       "192.168.100.105" => "node-5",}
### Vagrantfile 内容

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
            # config.vm.synced_folder "../data", "/vagrant_data"=
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
                # 判断node-4 安装特殊的东西
                if [ "node-4" == "#{vm_name}" ];then yum install -y ansible;pip3 install --upgrade pip -i https://pypi.douban.com/simple/;sudo pip3 install ansible  -i https://pypi.douban.com/simple/;ln -s /usr/local/python3/bin/ansible  /usr/bin/ansible;fi

            #   apt-get update
            #   apt-get install -y apache2
            SHELL
        end
    end
end






```

## 执行

vagrant up 启动虚拟机等待完毕后就可以看到两台虚拟机了
![image](https://note.youdao.com/yws/public/resource/f4adbece08d04ad79f5f68e97177f7ce/xmlnote/3497AB23EC4A4A2EA3182615CB5AE758/5108)

## 进入主机

```
vagrant ssh node-4
```
### 查看结果验证
![image](https://note.youdao.com/yws/public/resource/f4adbece08d04ad79f5f68e97177f7ce/xmlnote/FAEF09FB83AE4234BB43DF4E891A7739/5118)

# 安装CephFS 
### 其实就是安装 MDS

```
要为Ceph 文件系统配置元数据MDS

安装mds
[root@ceph-node-1 ceph]# ceph-deploy --overwrite-conf mds create ceph-node-2
[ceph_deploy.conf][DEBUG ] found configuration file at: /root/.cephdeploy.conf
[ceph_deploy.cli][INFO  ] Invoked (1.5.39): /usr/bin/ceph-deploy --overwrite-conf mds create ceph-node-2
[ceph_deploy.cli][INFO  ] ceph-deploy options:
[ceph_deploy.cli][INFO  ]  username                      : None
[ceph_deploy.cli][INFO  ]  verbose                       : False
[ceph_deploy.cli][INFO  ]  overwrite_conf                : True
[ceph_deploy.cli][INFO  ]  subcommand                    : create
[ceph_deploy.cli][INFO  ]  quiet                         : False
[ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf instance at 0x17248c0>
[ceph_deploy.cli][INFO  ]  cluster                       : ceph
[ceph_deploy.cli][INFO  ]  func                          : <function mds at 0x16c35f0>
[ceph_deploy.cli][INFO  ]  ceph_conf                     : None
[ceph_deploy.cli][INFO  ]  mds                           : [('ceph-node-2', 'ceph-node-2')]
[ceph_deploy.cli][INFO  ]  default_release               : False
[ceph_deploy.mds][DEBUG ] Deploying mds, cluster ceph hosts ceph-node-2:ceph-node-2
[ceph-node-2][DEBUG ] connected to host: ceph-node-2 
[ceph-node-2][DEBUG ] detect platform information from remote host
[ceph-node-2][DEBUG ] detect machine type
[ceph_deploy.mds][INFO  ] Distro info: CentOS Linux 7.4.1708 Core
[ceph_deploy.mds][DEBUG ] remote host will use systemd
[ceph_deploy.mds][DEBUG ] deploying mds bootstrap to ceph-node-2
[ceph-node-2][DEBUG ] write cluster configuration to /etc/ceph/{cluster}.conf
[ceph-node-2][DEBUG ] create path if it doesn't exist
[ceph-node-2][INFO  ] Running command: ceph --cluster ceph --name client.bootstrap-mds --keyring /var/lib/ceph/bootstrap-mds/ceph.keyring auth get-or-create mds.ceph-node-2 osd allow rwx mds allow mon allow profile mds -o /var/lib/ceph/mds/ceph-ceph-node-2/keyring
[ceph-node-2][INFO  ] Running command: systemctl enable ceph-mds@ceph-node-2
[ceph-node-2][WARNIN] Created symlink from /etc/systemd/system/ceph-mds.target.wants/ceph-mds@ceph-node-2.service to /usr/lib/systemd/system/ceph-mds@.service.
[ceph-node-2][INFO  ] Running command: systemctl start ceph-mds@ceph-node-2
[ceph-node-2][INFO  ] Running command: systemctl enable ceph.target

# 查询状态
[root@ceph-node-1 ceph]# ssh ceph-node-2 systemctl  status ceph-mds@ceph-node-2
● ceph-mds@ceph-node-2.service - Ceph metadata server daemon
   Loaded: loaded (/usr/lib/systemd/system/ceph-mds@.service; enabled; vendor preset: disabled)
   Active: active (running) # 状态 # since Mon 2018-04-23 13:34:20 CST; 6min ago
 Main PID: 1945 (ceph-mds)
   CGroup: /system.slice/system-ceph\x2dmds.slice/ceph-mds@ceph-node-2.service
           └─1945 /usr/bin/ceph-mds -f --cluster ceph --id ceph-node-2 --setuser ceph --setgroup ceph

Apr 23 13:34:20 ceph-node-2 systemd[1]: Started Ceph metadata server daemon.
Apr 23 13:34:20 ceph-node-2 systemd[1]: Starting Ceph metadata server daemon...
Apr 23 13:34:20 ceph-node-2 ceph-mds[1945]: starting mds.ceph-node-2 at :/0
```

### 创建文件系统和元数据存储池

```
# ceph osd pool create cephfs_data 64 64
# ceph osd pool create cephfs_metadata 64 64 
```
### 设置MDS为活跃状态，CephFS 也将处于可用状态：

```
# ceph fs new cephfs cephfs_metadata cephfs_data
```
#### 验证一下


```
ceph mds stat
ceph fs ls

```

### 创建客户点CephFS 秘钥


```
ceph auth get-or-create client.cephfs mon 'allow r' osd 'allow rwx pool=cephfs_metadata, allow rwx pool=cephfs_data' -o /etc/ceph/client.cephfs.keyring

ceph-authtool -p -n client.cephfs /etc/ceph/client.cephfs.keyring >/etc/ceph/client.cephfs


[root@ceph-node-1 ceph]# cat /etc/ceph/client.cephfs
```


### 通过内核驱动访问CephFs

```
创建一个挂载点
mkdir /mnt/cephfs
ceph auth get-key client.cephfs
AQDBc91ammPZARAALkK1PwKet0iKtXgOY+eBQw==

# 但是发现以上这个key不好用权限太小不知道为什么
还是直接暴力的使用admin的key吧
mount -t ceph ceph-node-1:6789:/ /mnt/cephfs -o name=admin,secret=AQCiNthaDgQzIhAAwIUL8nbVaZsfeD1BolepBw== 
[root@ceph-client ~]# df -TH
Filesystem              Type      Size  Used Avail Use% Mounted on
/dev/mapper/centos-root xfs        44G  2.0G   43G   5% /
devtmpfs                devtmpfs  246M     0  246M   0% /dev
tmpfs                   tmpfs     257M     0  257M   0% /dev/shm
tmpfs                   tmpfs     257M   13M  244M   6% /run
tmpfs                   tmpfs     257M     0  257M   0% /sys/fs/cgroup
/dev/mapper/centos-home xfs        22G   34M   22G   1% /home
/dev/sda1               xfs       1.1G  160M  904M  16% /boot
vagrant                 vboxsf    251G  195G   57G  78% /vagrant
/dev/rbd0               xfs        11G  444M   11G   5% /mnt/ceph-disk1
tmpfs                   tmpfs      52M     0   52M   0% /run/user/0
192.168.100.105:6789:/  ceph      396G  170G  226G  43% /mnt/cephfs
```

## 其他文档
1. ceph 安装文档
2. Ceph RBD 集成k8s
3. CephFS 集成k8s
4. Ceph 基本命令
5. http://note.youdao.com/noteshare?id=e9f2de404cf12d2cb0f7a38f99159e57