# Deploy RKE2 Kubernetes Cluster on openSUSE MicroOS

![Kubernetes Logo](https://raw.githubusercontent.com/kubernetes-sigs/kubespray/master/docs/img/kubernetes-logo.png)


## Quick Start

Below is the way to deploy a two nodes RKE2 Kubernetes cluster on openSUSE MicroOS. The following steps will guide you through the process. 

### Prepare
1. A local linux machine used as `Ansible Host`, and internet is required for downloading rke2 packages,image bundles and other dependencies.

2. Install 2 target nodes(Virtial Machine or Bare Metal) with `openSUSE MicroOS`, with one NIC for each of node, and they can be connected to each other via the same network.
    - Hardware Minimal Requirements is:
      - RKE2 Server Node:  Memory 4 GB
      - RKE2 Agent Node:   Memory 4 GB
    - Internet is required(for installing python3 on the 2 target nodes)

3. Make sure your `Ansible Host` could ssh to your target nodes without password, and also ensure all nodes have the same root password.
    ```ShellSession
    ssh-copy-id -i ~/.ssh/id_rsa.pub <user>@<node0>
    ssh-copy-id -i ~/.ssh/id_rsa.pub <user>@<node1>
    ```

### Steps
1. Install Ansible according to [Ansible installation guide](/docs/ansible/ansible.md#installing-ansible) on local linux ansible host(tested on Ubuntu 24.04.1 LTS)
    ```ShellSession
    pip3 install ansible
    pip install --upgrade ansible
    ```

2. Create inventory as following on local machine:
    > **Note:** It will create a two nodes kubernetes cluster, with one master (control-plane,etcd,master) and one worker
    ```ShellSession
    cp -rfp inventory/sample_two_nodes inventory/mycluster

    # Review and change hosts file under `inventory/mycluster`
    cat inventory/mycluster/inventory.ini

    # Review and change parameters under `inventory/mycluster/group_vars`
    cat inventory/mycluster/group_vars/all/all.yml
    ```

3. Download rke2 install package and images if not exist on local machine:
  - 3.1 Update settings in all.yml according to your environment if needed.
    ```yaml
    rke2_artifact_path_local: <path to local rke2 artifacts, example /home/x/download/rke2-airgap-images, where packages will be downloaded>
    rke2_version: <rke2 version, example v1.30.6%2Brke2r1>
    ```
  - 3.2 Run download.yaml
    ```ShellSession
    ansible-playbook -i inventory/mycluster/inventory.ini download.yml
    ```

4. Generate self-signed certificates (Optional). If you want to use self-signed certificates with your own configration, see the Steps and Example below.
  - 4.1 Modify `gen-ca-certs/root-ca.conf` and `gen-ca-certs/intermediate-ca.conf` according to your own infomation
    ```ShellSession
    cat gen-ca-certs/root-ca.conf
    cat gen-ca-certs/intermediate-ca.conf
    ```

  - 4.2 Generate self-signed root CA and intermediate CA (Skip if you have your own root CA and intermediate CA). 
  `DATA_DIR` is the directory where the CA bundle will be generated. Example:
    ```ShellSession
    DATA_DIR="/home/x/rke2-certs" PRODUCT="rke2" gen-ca-certs/generate-self-signed-ca.sh
    ```

  - 4.2 Generate all required CA bundles for rke2, example:
    ```ShellSession
    DATA_DIR="/home/x/rke2-certs" PRODUCT="rke2" gen-ca-certs/generate-custom-ca-certs.sh
    ```

  - 4.3 Set `ca_cert_dir` in `inventory/mycluster/group_vars/all/all.yml` to point to the CA bundle directory `DATA_DIR`, example:
    ```yaml
    ca_cert_data_dir: /home/x/rke2-certs
    ```


5. Clean up old Kubernetes cluster with Ansible Playbook (Skip this step if you want to upgrade your rke2 cluster!) 
    > **Note:** Be mind it will remove the current kubernetes cluster (if it's running)!
    ```ShellSession
    ansible-playbook -i inventory/mycluster/inventory.ini --ask-become-pass reset.yml
    ```

6. Deploy rke2 cluster with Ansible Playbook
    ```ShellSession
    # Append -vvvvv to see more playbook output messages for debugging
    ansible-playbook -i inventory/mycluster/inventory.ini --ask-become-pass cluster.yml
    ```
    > It should be finished in about 10 minutes if network is good.

    > If successful, you will see the following message for all your rke2 nodes:
    ```Text
    ok: [k8s0] => {
        "msg": "Hooray! RKE2 is installed successfully!"
    }
    ok: [k8s1] => {
        "msg": "Hooray! RKE2 is installed successfully!"
    }
    ```

## Debug and troubleshooting
- How to check hosts with Ansible before running the playbook?
  ```ShellSession
  ansible-inventory -i inventory/mycluster/inventory.ini --list
  ```

- How to check nodes/pods on rke2-server node?
  ```ShellSession
  sudo kubectl get nodes -A
  sudo kubectl get pods -A
  ```

- How to Check rke2 service logs?
  ```ShellSession
  sudo journalctl -u rke2-server -f   # for rke2-server node
  sudo journalctl -u rke2-agent -f    # for rke2-agent  node
  ```

- How to check rke2 service status?
  ```ShellSession
  sudo systemctl status rke2-server   # for rke2-server node
  sudo systemctl status rke2-agent    # for rke2-agent  node
  ```

- How to restart rke2 service?
  ```ShellSession
  sudo systemctl restart rke2-server   # for rke2-server node
  sudo systemctl restart rke2-agent    # for rke2-agent  node
  ```

- How to Check helm release on rke2-server node?
  ```ShellSession
  sudo helm list -n kube-system
  ```

## Documents
- [RKE2](https://docs.rke2.io/)
- [RKE2 Certificate Management](https://docs.rke2.io/security/certificates)
- [openSUSE MicroOS](https://get.opensuse.org/microos/)
- [SUSE MicroOS Doc](https://microos.opensuse.org/)
- [Administration Guide](https://documentation.suse.com/sle-micro/5.3/html/SLE-Micro-all/book-administration-slemicro.html)

## Supported Components
- Network Plugin
  - [cilium](https://github.com/cilium/cilium)

- Application
  - [cert-manager](https://github.com/jetstack/cert-manager) v1.13.2 - TBD
  - [gitlab](https://github.com/coredns/coredns) v1.11.1 - TBD
  - [helm](https://helm.sh/)
  - [registry](https://github.com/distribution/distribution) v2.8.1 - TBD

- Storage Plugin
  - TBD



