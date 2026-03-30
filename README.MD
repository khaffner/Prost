
<div align="center">
  <h1>🍻 Prost</h1>
  <strong>Payload runner over Syncthing<br>Also, "Prost" means "Cheers" in German.</strong>
  
  <br>
  
  ![Status](https://img.shields.io/badge/Status-Work%20In%20Progress-yellow?style=for-the-badge)
  
  <br>
  
  [![CI](https://github.com/khaffner/prost/actions/workflows/ci.yml/badge.svg)](https://github.com/khaffner/prost/actions/workflows/ci.yml)
  [![PowerShell](https://img.shields.io/badge/PowerShell-7.4+-blue.svg)](https://github.com/PowerShell/PowerShell)
  [![Syncthing](https://img.shields.io/badge/Syncthing-required-green.svg)](https://syncthing.net/)
  [![License](https://img.shields.io/github/license/khaffner/prost)](LICENSE)
  [![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/khaffner/prost/graphs/commit-activity)
  
  [![Platform](https://img.shields.io/badge/Platform-Linux-blue.svg)](https://www.linux.org/)
  [![Systemd](https://img.shields.io/badge/Systemd-required-orange.svg)](https://systemd.io/)
  [![GitHub issues](https://img.shields.io/github/issues/khaffner/prost)](https://github.com/khaffner/prost/issues)
  [![GitHub last commit](https://img.shields.io/github/last-commit/khaffner/prost)](https://github.com/khaffner/prost/commits)
  [![Contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](CONTRIBUTING.md)
  
  [![GitHub stars](https://img.shields.io/github/stars/khaffner/prost?style=social)](https://github.com/khaffner/prost/stargazers)
  [![GitHub forks](https://img.shields.io/github/forks/khaffner/prost?style=social)](https://github.com/khaffner/prost/network/members)
  
</div>



---

## 🚀 What is Prost?

<sub><em>(Tip: You should be familiar with Syncthing before using this.)</em></sub>


Prost lets you manage your devices and servers. Push scripts, collect results, and automate tasks across your fleet, all with minimal setup, backed by Syncthing.

**Why?**
- Ensure packages are installed
- Make sure services are running
- Collect node info or logs
- ...and more


---

## 👤 Who is Prost for?

Not for enterprises, those should use mature solutions like Chef, Ansible, etc. Prost is my weird idea after learning Chef, but loving the decentralized nature and simplicity of Syncthing. Prost is for you who just want to push scripts and get results back, with no extra network config.

---

## 🛠️ Requirements

- **Systemd**
- **Syncthing**
  - Should run as a service at boot
  - `root` must be able to run `syncthing cli` at all times
- **PowerShell**
  - Any supported version is fine, but depends on your payloads
    - Your stuff might need the newest version
  - Must be at /usr/bin/pwsh

---

## ⚡ Quickstart

1. **Download latest release** to your master node (laptop, VM, etc). Syncthing must already be installed and running. You can also just clone down the repo, the releases are just a stripped down snapshot of the repo.

### On the Master Node
- Add `prost-input` as **Send Only*** (slaves can't write back)
  - Or use **Send & Receive** if you trust the devices and/or want multiple master nodes
- Add `prost-output` as **Send & Receive** (shared dumping ground for outputs/logs)
- remove _template from the assignments csv
- Add your slave nodes and share both folders with them

### On Each Slave Node
- Accept both folders:
  - `prost-input` as **Receive Only**
  - `prost-output` as **Send & Receive**
- Run `install.ps1` as root to set up the systemd service (runs `run.ps1` every hour, adjust as needed)

### Want another Master Node?
- Share both folders between all Master Nodes as **Send & Receive**

---

## 📝 Assigning Scripts & Getting Results

1. **Pause** the `prost-input` folder in Syncthing on the master node you work on. (prevents accidental WIP deployments). [CLI tip](https://forum.syncthing.net/t/stcli-or-how-to-pause-resume-sync-from-cli-in-2022/19345/2)
2. **Create your script** in [`prost-input/payloads/`](prost-input/payloads/). (Try `nodeinfo.ps1` as a starter!)
3. **Assign nodes** in [`assignments.csv`](prost-input/assignments.csv)
   - Use only the first section of the Syncthing ID
4. **Unpause** the `prost-input` folder to sync scripts to your nodes

**What happens next?**

1. Files sync to the slave node(s)
2. The slave node runs `run.ps1` hourly
3. `run.ps1` decides what/how to run
4. Scripts may write output to `prost-output`

---

## 🔄 System Flow Diagram

```mermaid
flowchart TD
  subgraph "Master Node (start)"
    minput["prost-input folder"]
  end
  subgraph "Slave Nodes"
    sinput["prost-input folder"]
    soutput["prost-output folder"]
    run.ps1
    nodeinfo.ps1["nodeinfo.ps1 (example)"]
  end
    subgraph "Master Node (end)"
    moutput["prost-output folder"]
  end

  minput --Send only-->sinput--Hourly systemd task-->run.ps1 -->nodeinfo.ps1-->soutput<--Send & Receive-->moutput
```

---


<div align="center">
  <strong>🍻 Prost!</strong>
</div>