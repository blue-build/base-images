# Copyright 2025 Universal Blue
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

# Enroll Nvidia driver & KMOD signing key for secure boot - Enter password "bluebuild" if prompted
enroll-secure-boot-key:
    #!/usr/bin/bash
    ENROLLMENT_PASSWORD="bluebuild"
    SECUREBOOT_KEY=/etc/pki/akmods/certs/akmods-blue-build.der
    sudo mokutil --timeout -1
    echo -e "$ENROLLMENT_PASSWORD\n$ENROLLMENT_PASSWORD" | sudo mokutil --import "$SECUREBOOT_KEY"
    echo 'At next reboot, the mokutil UEFI menu UI will be displayed (*QWERTY* keyboard input and navigation).\nThen, select "Enroll MOK", and input "bluebuild" as the password'

# Enable automatic LUKS unlock via TPM
setup-luks-tpm-unlock:
    #!/usr/bin/bash
    sudo /usr/libexec/luks-enable-tpm2-autounlock

# Disable automatic LUKS unlock via TPM
remove-luks-tpm-unlock:
    #!/usr/bin/bash
    sudo /usr/libexec/luks-disable-tpm2-autounlock
