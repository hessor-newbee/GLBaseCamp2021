# ansible-vault password: hessor
# Task #1
## 1. set-password-policy.yml
```yaml
---
- name: Set password policy with PAM
  hosts: all
  gather_facts: true
  become: true

  tasks:
    - include_role:
        name: 'set-password-policy-Debian'
    - include_role:
        name: 'set-password-policy-RedHat''
```
## 2. Check /etc/pam.d/system-auth before running playbook.
![alt text](./img/1.png)
## 3. Run set-password-policy.yml.
![alt text](./img/15.png)
## 4. Check /etc/pam.d/system-auth.
![alt text](./img/4.png)
## 5. Testing:
   - logged in to VM;
   - created a user "lexa";
   - tried to set invalid password;
   - the same for root.<br>

RedHat

![alt text](./img/5.png)

Debian

![alt text](./img/12.png)
# Task #2
## 1. allow-ssh-from-ansible-host-and-localhost.yml
```yaml
---
- name: Allow SSH access only from ansible host and localhost
  hosts: all
  become: true
  gather_facts: true

  tasks:
    - include_role: 
        name: 'allow-ssh-from-ansible-host-and-localhost'
```
## 2. Check /etc/hosts.allow and /etc/hosts.deny before running playbook.
![alt text](./img/2.png)
## 3. Try to log in via ssh from VM #2 to VM #1.
![alt text](./img/9.png)
## 4. Run allow-ssh-from-ansible-host-and-localhost.yml.
![alt text](./img/14.png)
## 5. Check /etc/hosts.allow and deny.
![alt text](./img/7.png)
## 6. Testing:
   - logged in to VM #2 and #3;
   - tried to log in to VM #1.

From Redhat to Redhat

![alt text](./img/8.png)

From Debian to Redhat

![alt text](./img/13.png)

