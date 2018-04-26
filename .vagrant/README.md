## 安装Ceph 
**把 Ceph 仓库添加到 ceph-deploy 管理节点，然后安装 ceph-deploy 。**

### 在 Red Hat （rhel6、rhel7）、CentOS （el6、el7）和 Fedora 19-20 （f19 - f20） 上执行下列步骤：
- 在 RHEL7 上，用 subscription-manager 注册你的目标机器，确认你的订阅， 并启用安装依赖包的“Extras”软件仓库。例如 ：
    ```
    sudo subscription-manager repos --enable=rhel-7-server-extras-rpms
    ```
- 在 RHEL6 上，安装并启用 Extra Packages for Enterprise Linux (EPEL) 软件仓库。 请查阅 EPEL wiki 获取更多信息。
- 在 CentOS 上，可以执行下列命令：
    ```angular2html
    sudo yum install -y yum-utils && sudo yum-config-manager --add-repo https://dl.fedoraproject.org/pub/epel/7/x86_64/ && sudo yum install --nogpgcheck -y epel-release && sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 && sudo rm /etc/yum.repos.d/dl.fedoraproject.org*
    ```
- 把软件包源加入软件仓库。用文本编辑器创建一个 YUM (Yellowdog Updater, Modified) 库文件，其路径为 /etc/yum.repos.d/ceph.repo 。例如：
    ```angular2html
    sudo vim /etc/yum.repos.d/ceph.repo
  把如下内容粘帖进去，用 Ceph 的最新主稳定版名字替换 {ceph-stable-release} （如 firefly ），用你的Linux发行版名字替换 {distro} （如 el6 为 CentOS 6 、 el7 为 CentOS 7 、 rhel6 为 Red Hat 6.5 、 rhel7 为 Red Hat 7 、 fc19 是 Fedora 19 、 fc20 是 Fedora 20 ）。最后保存到 /etc/yum.repos.d/ceph.repo 文件中。
    
  [ceph-noarch]
    name=Ceph noarch packages
    baseurl=http://download.ceph.com/rpm-jewel/el7/noarch
    enabled=1
    gpgcheck=1
    type=rpm-md
    gpgkey=https://download.ceph.com/keys/release.asc
        ```

### 配置 
- 推荐做法）修改 ceph-deploy 管理节点上的 ~/.ssh/config 文件，这样 ceph-deploy 就能用你所建的用户名登录 Ceph 节点了，而无需每次执行 ceph-deploy 都要指定 --username {username} 。这样做同时也简化了 ssh 和 scp 的用法。把 {username} 替换成你创建的用户名。
```angular2html

Host node1
   Hostname node1
   User ifnoelse
Host node2
   Hostname node2
   User ifnoelse
Host node3
   Hostname node3
   User ifnoelse
```

### 我们创建一个 Ceph 存储集群
```
mkdir my-cluster
cd my-cluster
```

