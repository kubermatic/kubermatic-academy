#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# Node-level teardown script — run ON EACH NODE to fully reset it.
#
# Source:       Adapted from cloudnativetrainings/kubev/99_teardown/teardown.sh
# Adaptations:  - Added error-checked logging (head/tail of each apt step
#                 instead of full output).
#               - Added removal of kube-ovn-ctl + cdi remnants that can
#                 survive kubeadm reset on a KubeV cluster.
# Used by:      Chapter 10 — OPTIONAL full-cluster teardown section.
#               Also invoked by chapter-03-install/pre-record.sh to clean
#               a node before a re-record of Ch03.
#
# Intended invocation:
#     ssh root@controlplane-node 'bash -s' < teardown.sh
#     ssh root@worker-node       'bash -s' < teardown.sh
#
# Effects:
#   - kubeadm reset -f
#   - apt remove kubeadm/kubelet/kubectl/containerd.io
#   - purge /etc/kubernetes, /var/lib/etcd, /var/lib/kubelet, /etc/cni
#   - unhold any held packages
#   - apt upgrade + auto-remove
# ----------------------------------------------------------------------------

set -euo pipefail

echo "[teardown] kubeadm reset"
kubeadm reset -f 2>&1 | tail -5

echo "[teardown] removing kube* + containerd.io packages"
for pkg in kubeadm kubelet kubectl containerd.io; do
    apt remove -y --allow-change-held-packages "$pkg" 2>&1 | tail -1 || true
done

echo "[teardown] purging /etc/kubernetes, etcd, kubelet, cni"
rm -rf /etc/kubernetes/ /var/lib/etcd/ /var/lib/kubelet/ /etc/cni/

# KubeV-specific remnants — not in Hubert's original teardown.
echo "[teardown] purging kube-ovn + cdi remnants"
rm -rf /var/run/ovn/ /etc/origin/ovn/ /var/lib/ovn/ 2>/dev/null || true
rm -rf /var/lib/cdi/ 2>/dev/null || true

echo "[teardown] releasing package holds"
if HELD=$(apt-mark showhold 2>/dev/null); then
    [ -n "$HELD" ] && apt-mark unhold $HELD 2>&1 | tail -1 || true
fi

echo "[teardown] apt update + upgrade + auto-remove"
apt update 2>&1 | tail -1
apt upgrade -y 2>&1 | tail -1
apt auto-remove -y 2>&1 | tail -1

echo "[teardown] complete on $(hostname)"
