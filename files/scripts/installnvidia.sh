#!/usr/bin/env bash

# Copyright 2025 Universal Blue
# Copyright 2025 The Secureblue Authors
# Copyright 2025 The BlueBuild Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

set -oue pipefail

mkdir -p /var/tmp
chmod 1777 /var/tmp

##################################
# Repository setup
##################################
if [[ "$IMAGE_NAME" == *open* ]]; then
    nvidia_repo='fedora-nvidia'
else
    nvidia_repo='fedora-nvidia-580'
fi

KERNEL_VERSION="$(rpm -q "kernel" --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
RELEASE="$(rpm -E '%fedora.%_arch')"

curl -fLsS --retry 5 -o "/etc/yum.repos.d/${nvidia_repo}.repo" "https://negativo17.org/repos/${nvidia_repo}.repo"

#################################
# Kernel module
#################################
dnf install -y --setopt=install_weak_deps=False "kernel-devel-matched-$(rpm -q 'kernel' --queryformat '%{VERSION}')"

dnf install -y --setopt=install_weak_deps=False akmods gcc-c++

cp /usr/sbin/akmodsbuild /usr/sbin/akmodsbuild.backup

# TODO remove this when fixed upstream
sed -i '/if \[\[ -w \/var \]\] ; then/,/fi/d' /usr/sbin/akmodsbuild

dnf install -y --setopt=install_weak_deps=False \
    --enable-repo="${nvidia_repo}" \
    nvidia-kmod-common nvidia-modprobe

echo "Installing kmod..."
akmods --force --kernels "${KERNEL_VERSION}" --kmod "nvidia"

mv /usr/sbin/akmodsbuild.backup /usr/sbin/akmodsbuild

# Depends on word splitting
# shellcheck disable=SC2086
modinfo /usr/lib/modules/${KERNEL_VERSION}/extra/nvidia/nvidia{,-drm,-modeset,-peermem,-uvm}.ko.xz > /dev/null || \
    (cat "/var/cache/akmods/nvidia/*.failed.log" && exit 1)

# View license information
# Depends on word splitting
# shellcheck disable=SC2086
modinfo -l /usr/lib/modules/${KERNEL_VERSION}/extra/nvidia/nvidia{,-drm,-modeset,-peermem,-uvm}.ko.xz

chmod +x ./signmodules.sh
./signmodules.sh "nvidia"

##################################
# Extra packages
##################################
nvidia_packages_list=(\
    'nvidia-driver' \
    'nvidia-persistenced' \
    'nvidia-settings' \
    'nvidia-driver-cuda' \
    'nvidia-container-toolkit' \
    'libnvidia-fbc' \
    'libva-nvidia-driver' \
)

curl -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo \
    -o /etc/yum.repos.d/nvidia-container-toolkit.repo
sed -i 's/^gpgcheck=0/gpgcheck=1/' /etc/yum.repos.d/nvidia-container-toolkit.repo

if ! [ -f /etc/pki/tls/certs/ca-bundle.crt ]; then
    ln /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem /etc/pki/tls/certs/ca-bundle.crt
fi

dnf -y --setopt=install_weak_deps=False install \
    --enable-repo='nvidia-container-toolkit' \
    --enable-repo="${nvidia_repo}" \
    "${nvidia_packages_list[@]}"

kmod_version=$(rpm -qa | grep akmod-nvidia | awk -F':' '{print $(NF)}' | awk -F'-' '{print $(NF-1)}')
negativo_version=$(rpm -qa | grep nvidia-modprobe | awk -F':' '{print $(NF)}' | awk -F'-' '{print $(NF-1)}')

echo "kmod_version: ${kmod_version}"
echo "negativo_version: ${negativo_version}"
if [[ "$kmod_version" != "$negativo_version" ]]; then
    echo "Version mismatch!"
    exit 1
fi

curl -L https://raw.githubusercontent.com/NVIDIA/dgx-selinux/master/bin/RHEL9/nvidia-container.pp \
    -o nvidia-container.pp
semodule -i nvidia-container.pp

##################################
# Cleanup
##################################
dnf -y remove akmod-nvidia akmods kernel-devel kernel-headers

rm -f nvidia-container.pp
rm -f /etc/yum.repos.d/nvidia-container-toolkit.repo
rm -f "/etc/yum.repos.d/${nvidia_repo}.repo"
