# Docker Container Networking Fix for Magma Install

This guide helps fix network connectivity issues in Docker containers on Ubuntu hosts. This is especially useful when containers cannot reach external IPs or hostnames (e.g., `archive.ubuntu.com`, `github.com`).

---

## Symptoms

* `Temporary failure resolving 'archive.ubuntu.com'`
* `fatal: unable to access 'https://github.com/magma/magma.git/'`
* Containers cannot ping IPs or hostnames
* `docker0` interface is down

---

## Steps to Fix

### 1. Verify Host Internet

Check that the host machine has internet connectivity:

```bash
ping -c 3 8.8.8.8
ping -c 3 google.com
```

If these fail, fix host networking first (firewall, VPC, or routing).

---

### 2. Check Docker Bridge Interface

Check if `docker0` exists and its state:

```bash
ip a | grep docker0
docker network inspect bridge
```

* `state DOWN` indicates the bridge is inactive.

---

### 3. Bring Up Docker Bridge

Manually bring the bridge up:

```bash
sudo ip link set dev docker0 up
```

Verify:

```bash
ip a | grep docker0
# Should show state UP
```

---

### 4. Enable IP Forwarding

Enable forwarding for NAT:

```bash
sudo sysctl -w net.ipv4.ip_forward=1
```

Make it permanent:

```bash
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

---

### 5. Configure NAT (iptables)

Check existing NAT rules:

```bash
sudo iptables -t nat -L -n | grep MASQUERADE
```

If missing, add:

```bash
sudo iptables -t nat -A POSTROUTING -s 172.17.0.0/16 ! -o docker0 -j MASQUERADE
```

---

### 6. Test Container Connectivity

Run a test container to confirm network access:

```bash
docker run --rm busybox ping -c 3 8.8.8.8
docker run --rm busybox ping -c 3 google.com
```

* Success means containers can reach external networks.

---

### 7. Optional: Set Docker DNS

If containers can ping IPs but not hostnames, configure Docker DNS:

```bash
sudo mkdir -p /etc/docker
echo '{ "dns": ["8.8.8.8", "1.1.1.1"] }' | sudo tee /etc/docker/daemon.json
sudo systemctl restart docker
```

---

### 8. Proceed with Magma Install

Once networking works, retry Magma installation scripts:

```bash
cd ~/MK-magma-Core
/root/agw_install_docker.sh
# or
/root/agw_post_install_ubuntu.sh install
```

---

This ensures Docker containers have proper NAT, DNS, and can access external repositories for successful Magma setup.
