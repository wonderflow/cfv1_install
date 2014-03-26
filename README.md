# 基于nisebosh的自动化部署技术文档
***
项目地址为：http://10.10.103.47/gitlab/nise-bosh-auto-set.git

## 环境部署

### Linux本地源的架设

架设本地源可以方便内网下载，提高软件安装速度。

#### 架设方法：
* 选择一台服务器安装所有需要的linux安装包,安装包会出现在该机器的缓存文件夹中/var/cache/apt/archives
* 在该服务器上安装apache服务器以供内网访问

```$ sudo apt-get install apache2```

* 在/var/www/下新建ubuntu-local目录，注意目录的权限，很多时候访问不到就是权限问题
* 将 /var/cache/apt/archives/下的所有.deb文件拷到apache文件夹/var/www/ubuntu-local/下

`$ sudo cp /var/cache/apt/archives/*.deb /var/www/ubuntu-local/`

* 拷贝完成后到/var/www/ubunutu-local/目录下执行命令，生成Packages.gz让告诉ubuntu源的内容，如果没有dpkg-scanpackages的话就再装一下

```$ sudo apt-get install dpkg-dev```

```$ sudo dpkg-scanpackages . /dev/null | gzip >Packages.gz```

* 更改/etc/apt/sources.list文件,把 “deb http://127.0.0.1/ubuntu-local /” 加入到需要使用该源的机器里的sources.list即可。

### 本地环境ruby的安装
自动化部署软件本身是基于ruby的，所以要让ruby运行起来。我们采用源码安装的方式安装如下三个ruby的基本包。

* yaml源码包，使用的yaml-0.1.4.tar.gz,放至与下面脚本同一目录下。
 
```sh
sudo cp yaml-0.1.4.tar.gz /usr/src
# yaml install
cd /usr/src
sudo tar xzf yaml-0.1.4.tar.gz
cd yaml-0.1.4
sudo ./configure --prefix=/usr/local
sudo make 
sudo make install
```

* ruby源码安装，使用ruby-1.9.3-p448.tar.gz版本，与如下脚本同一目录

```sh
sudo cp ruby-1.9.3-p448.tar.gz /usr/src
#ruby install
cd /usr/src
if [ ! -d ruby-1.9.3-p448 ]; then
  sudo tar xzf ruby-1.9.3-p448.tar.gz
fi
cd ruby-1.9.3-p448
#if ! (which ruby); then
sudo ./configure --prefix=/usr/local --enable-shared --disable-install-doc --with-opt-dir=/usr/local/lib --with-openssl-dir=/usr --with-readline-dir=/usr --with-zlib-dir=/usr
sudo make
sudo make install
#fi
```

* rubygems源码安装，使用rubygems-1.8.17.tgz，与如下脚本同一目录

```sh
sudo cp rubygems-1.8.17.tgz /usr/src
#rubygems install
cd /usr/src 
if [ ! -d rubygems-1.8.17 ]; then
  sudo tar xzf rubygems-1.8.17.tgz
fi
cd rubygems-1.8.17
#if  ! (which gem); then
sudo ruby setup.rb
#fi
```

***
## 配置文件

配置文件主要有两个，一个用于IP和组件关系对应，一个用于IP与虚拟机硬件配置对应。还要一个使用本地源的文件。

* 配置文件在config文件夹下，一个名为iptable.yml，一个名为resource.yml

* 还要修改一下config文件夹下的sources.list文件，把地址改成部署的本地源地址，只有部署的时候才会使用到我们架设的本地源。

### iptable.yml
这个就是展示组件与IP对应关系的配置表了。最后一个是域名的配置。

```
---
debian_nfs_server: 
  - 10.255.134.134
syslog_aggregator: 
  - 10.255.134.135
collector: 
  - 10.255.134.136
ccdb:
  - 10.255.134.137
uaa:
  - 10.255.134.138
uaadb:
  - 10.255.134.139
vcap_redis:
  - 10.255.134.140
login:
  - 10.255.134.141
health_manager:
  - 10.255.134.142
health_monitor:
  - 10.255.134.143
dashboard:
  - 10.255.134.144
cloud_controller:
  - 10.255.134.145
  - 10.255.134.146
opentsdb:
  - 10.255.134.147
zkper:
  - 10.255.134.148
stager:
  - 10.255.134.148
nats:
  - 10.255.134.149
hbase_master:
  - 10.255.134.150
hbase_slave:
  - 10.255.134.151
router: 
  - 10.255.134.152
  - 10.255.134.153
  - 10.255.134.154
  - 10.255.134.155
  - 10.255.134.156
  - 10.255.134.157
LB:
  - 10.255.134.158
dea:
  - 10.255.134.159
  - 10.255.134.160
  - 10.255.134.161
  - 10.255.134.162
  - 10.255.134.163
  - 10.255.134.164
domain:
  - smartcity.com
```
### resource.yml
这个是展示硬件配置的，分为small，middle和large三类。三个数字分别对应CPU、内存和硬盘空间。此处的硬盘空间只检测根目录下的空间。

```
---
small:
  - 1
  - 2
  - 50
  - jobs:
    - debian_nfs_server
    - syslog_aggregator
    - collector
    - ccdb
    - uaa
    - uaadb
    - vcap_redis
    - login
    - health_manager
    - health_monitor
    - dashboard
    - cloud_controller
    - opentsdb
    - zkp
    - nats
    - hbase_master
    - hbase_slave
    - LB
middle:
  - 1
  - 2
  - 50
  - jobs:
    - router
large:
  - 1
  - 2
  - 50
  - jobs:
    - router
    - dea
    - ESBgateway
    - ESBnats
    - ESB
    - WSO2
```

## 虚拟机用户权限
虚拟机给我们的时候，一般都只有root用户，而我们需要添加vcap用户。所以我们需要给所有虚拟机添加vcap用户。密码统一使用“password”。

然后不要忘了把vcap用户添加到sudo组内。

```sh
$ adduser vcap
$ adduser vcap sudo
```

建议使用脚本统一执行，在主目录下已经有一个粗略的脚本adduser.rb，可以进行少许修改后使用。

## 部署 ##

等到以上这些都搞定以后，就可以开始部署了。一行命令即可。

`$ ruby nise_bosh_auto_install.rb`

然后等待吧，视内网带宽不同大概需要2～5各小时。需要传输4G*组件个数的流量。

## 运维 ##


* 依次查看所有组件运行的情况

`$ ruby monit_summary.rb`

* 重启所有组件

`$ ruby monit_restart_all.rb`

* 单独安装某一个组件（需要根据要安装的组件名称修改一下代码）

`$ ruby install_one_job.rb`


## 部署结束后的相关修改 ##


1、虚拟机open_tty，这个是VM模板的问题，修改sudoers文件即可。（在cc的template中发现一个sudoers文件）

2、cloud_controller /var/vcap/job/cloud_controller/config文件夹中nginx.conf文件修改后。

在 #pass alter后面加上

```
  # Bypass for GET requests
     if ($request_method = GET) {
     proxy_pass http://cloud_controller;
     }
```

3、cloud_controller 中uaa的http地址是https的，无法使用，要改为http。修改地址同上，修改文件为cloud_controller.yml

```
Grails: “*.war”;
Lift:”*.war”
Play:”lib/play.*.jar”
Rails:No “”
Spring:”*.war”
Java_web:”*.war”
Node:”*.js”:’.’
其他不变
```

4、cloud_controller中 config/staging文件中的yml文件需要修改（因为bosh使用1.9.2我们使用1.9.3，yml解析上可能存在一定的问题）

5、zookeeper没有自动化安装，安装步骤：
http://blog.csdn.net/ketonfly/article/details/13622133 同时zookeeper集群需要java运行环境

6、loadbalance即nginx没有自动化安装，安装步骤以及配置方法：
http://blog.csdn.net/ketonfly/article/details/13622195

7、架设域名解析服务器，在domain服务器上把domain与loadblance关联配置起来。

8、修改api.[domain.xx]默认的网址显示
```
$ sudo grep -rl "Welcome to VMware's Cloud Application Platform" /var/vcap/
$ sudo vi /var/vcap/packages/cloud_controller/cloud_controller/app/controllers/default_controller.rb
```

9、hbase_master，hbase_slave启动不成功
```
修复HBase，修改DNS.getIPS,索引变为0,用maven重新编译，打包，覆盖原来的数据，保存原有目录结构，编译之后目录是各子集。
```
10、cloudagent启动有问题，赖春彬解决

11、DEA中/var/vcap/jobs/dea/config/dea.yml中默认配置4096MB，要写脚本改。

12、health_monitor的yml配置文件有错。tsdb和nats都以数组形式呈现不对。

13、health_monitor中/var/vcap/package/health_monitor/lib/runner.rb中的director相关的都注释掉。 
```
具体：
/var/vcap/packages/health_monitor/bosh/health_monitor/lib/health_monitor/runner.rb
第13行   #@director = Bhm.director
第45行：#poll_director
第45行：#EM.add_periodic_timer(@intervals.poll_director) { poll_director }
第101～103行：poll_director函数
第141～157行：fetch_deployments函数 
```
14、所有长时间的命令，都使用screen命令，因为时间一长broken pipe。

Licence
----

本软件、文档以及所包含的内容均为浙江大学 SEL 实验室的劳动成果，未经允许，任何形式地使用全部或者部分内容，都将负法律责任。


    
 
