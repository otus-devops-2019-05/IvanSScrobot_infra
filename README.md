# IvanSScrobot_infra
IvanSScrobot Infra repository

**1. Configuration:**

bastion_IP = 34.77.163.228  
someinternalhost_IP = 10.128.0.2


**2. It's possible to reach someinternalhost wih only one command:**

`ssh -A -t ivan@34.77.163.228 'ssh 10.128.0.2'`


**3. Direct connect through the command "SSH someinternalhost"**

Aliases are implemented by usage of '~/.ssh/config' file. The configuration of the file is:

```
Host *
ForwardAgent yes

Host bastion
HostName 34.77.163.228
User ivan

Host someinternalhost
HostName 10.128.0.2
User ivan
ProxyCommand ssh bastion nc %h %p
```

**Important!** Only the owner of the file has rights for writing. Use `chmod go-w ~/.ssh/config`
