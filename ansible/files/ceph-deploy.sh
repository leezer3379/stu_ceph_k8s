#!/usr/bin/env bash

mkdir /etc/ceph
cd /etc/ceph

yum install ceph-deploy -y
ceph-deploy new ceph-node-1
status=True
while status
do
    ceph-deploy install ceph-node-1 ceph-node-2 ceph-node-3 ceph-client
    if [ $? == 0 ];then
        status=Flase
    fi
done

ssh ceph-node-1 ceph -v
ssh ceph-node-2 ceph -v
ssh ceph-node-3 ceph -v
ssh ceph-client ceph -v
# 创建监控mon
ceph-deploy mon create-initial

# 增加磁盘分区
ssh ceph-node-1 mkdir /sd{b,c,d}
ssh ceph-node-1 chown ceph:ceph /sd{b,c,d}
ssh ceph-node-2 mkdir /sd{b,c,d}
ssh ceph-node-2 chown ceph:ceph /sd{b,c,d}
ssh ceph-node-3 mkdir /sd{b,c,d}
ssh ceph-node-3 chown ceph:ceph /sd{b,c,d}


# 格式化磁盘 激活
ceph-deploy osd create ceph-node-1:/sd{b,c,d}
ceph-deploy osd activate ceph-node-1:/sd{b,c,d}
ceph-deploy osd create ceph-node-2:/sd{b,c,d}
ceph-deploy osd activate ceph-node-2:/sd{b,c,d}
ceph-deploy osd create ceph-node-3:/sd{b,c,d}
ceph-deploy osd activate ceph-node-3:/sd{b,c,d}

# 扩展集群穿件monitor 奇数
ceph-deploy mon create ceph-node-3
ceph-deploy mon create ceph-node-2

ceph -s

# 调整存储池的pg_num pgp_num 值
ceph osd pool set rbd pg_num 256
ceph osd pool set rbd pgp_num 256

# 查看仲裁
ceph quorum_status --format json-pretty




# 创建客户端
ceph-deploy config push ceph-client
# 创建秘钥
ceph auth get-or-create client.rbd mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=rbd'
ceph auth get-or-create client.rbd | ssh ceph-client tee /etc/ceph/ceph.client.rbd.keyring


### 登录到客户端主机上进行操作
ssh ceph-client cat /etc/ceph/ceph.client.rbd.keyring >> /etc/ceph/keyring
ssh ceph-client -s --name client.rbd
if [ $? == 0 ];then
    echo "安装完毕"
fi

###   time dd if=/dev/zero of=testw.dbf bs=4k count=100000