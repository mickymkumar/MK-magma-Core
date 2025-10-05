# Magma AGW Setup on Ubuntu 24.04 with Open vSwitch

This document outlines the steps to set up the Magma Access Gateway (AGW) on **Ubuntu 24.04** running an **AWS kernel 6.14**, including installing and configuring **Open vSwitch (OVS)**.

---

## 1. System Preparation

### 1.1 Verify the running kernel

```bash
uname -r
# Expected: 6.14.0-1011-aws
```

### 1.2 Update and install basic dependencies

```bash
sudo apt update
sudo apt install -y build-essential dkms libelf-dev linux-libc-dev pkg-config \
                    python3 python3-pip python3-venv
```

---

## 2. Kernel Headers

### 2.1 Remove old or mismatched headers

```bash
sudo apt-get purge -y linux-headers-6.8.0-85* linux-headers-generic
sudo apt-get autoremove -y
```

### 2.2 Install headers for the running kernel

```bash
sudo apt update
sudo apt install -y linux-headers-$(uname -r)
```

* Ensures DKMS modules can build against the correct kernel.

---

## 3. Open vSwitch Installation

### 3.1 Clean existing DKMS build (if any)

```bash
sudo dkms remove -m openvswitch -v 2.15.4-9 --all
sudo rm -rf /var/lib/dkms/openvswitch-2.15.4-9/build
```

### 3.2 Install Open vSwitch from Ubuntu repository

```bash
sudo apt install -y openvswitch-switch openvswitch-datapath-dkms
```

* This version is patched for the AWS 6.14 kernel.
* Avoids manual DKMS compilation issues.

---

## 4. Verify Open vSwitch

### 4.1 Check loaded kernel modules

```bash
lsmod | grep openvswitch
```

### 4.2 Start OVS daemons manually (required in Docker/containers)

```bash
sudo /usr/share/openvswitch/scripts/ovs-ctl start
```

### 4.3 Verify OVS database

```bash
sudo ovs-vsctl show
```

---

## 5. Integration Bridge Setup

### 5.1 Create the integration bridge

```bash
sudo ovs-vsctl add-br br-int
sudo ovs-vsctl show
```

### 5.2 Verify bridge

```bash
sudo ovs-ofctl show br-int
```

* The `LOCAL` port should exist.
* `PORT_DOWN` and `LINK_DOWN` are normal until a physical or virtual interface is added.

### 5.3 Optional: Attach an uplink interface

```bash
sudo ovs-vsctl add-port br-int eth1
sudo ip link set eth1 up
sudo ovs-ofctl show br-int
```

---

## 6. Run Magma AGW Post-Install

Once OVS is ready, execute the AGW post-install script:

```bash
/root/agw_post_install_ubuntu.sh install
```

This will:

* Configure Magma LTE/5G services
* Create required OVS flows and tunnels
* Initialize the Magma AGW environment

---

## 7. Notes & Tips

* **Systemd is not required in containers**; OVS daemons can be started with `/usr/share/openvswitch/scripts/ovs-ctl`.
* Ensure **kernel headers match the running kernel** to avoid DKMS build errors.
* Use Ubuntu repo OVS packages (`openvswitch-switch`, `openvswitch-datapath-dkms`) for AWS kernels ≥6.x.
* The integration bridge `br-int` is required for Magma to manage tunnels and flows.

---

## 8. Verification Checklist

* Kernel headers installed:

```bash
dpkg -l | grep linux-headers
```

* Open vSwitch modules loaded:

```bash
lsmod | grep openvswitch
```

* OVS database running:

```bash
sudo ovs-vsctl show
```

* Integration bridge exists:

```bash
sudo ovs-ofctl show br-int
```

* AGW services can start successfully:

```bash
/root/agw_post_install_ubuntu.sh install
```

---

**End of Documentation**
