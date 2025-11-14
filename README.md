# BlueBuild Base Images Repo

This repo consists of base images maintained by the BlueBuild org and built with the BlueBuild CLI. These images come with batteries included and were modeled after the [Ublue Main Images](https://github.com/ublue-os/main) before they were reduced in scope. Thanks to [Ublue](https://universal-blue.org/) for giving us a good starting point!

## Images

| Recipe                                  | Image                                                   | Versions    |
|-----------------------------------------|---------------------------------------------------------|-------------|
| recipe/fedora-base.yml                  | ghcr.io/blue-build/base-images/fedora-base              | 43 (latest) |
| recipe/fedora-base-nvidia.yml           | ghcr.io/blue-build/base-images/fedora-base-nvidia       | 43 (latest) |
| recipe/fedora-cosmic.yml                | ghcr.io/blue-build/base-images/fedora-cosmic            | 43 (latest) |
| recipe/fedora-cosmic-nvidia.yml         | ghcr.io/blue-build/base-images/fedora-cosmic-nvidia     | 43 (latest) |
| recipe/fedora-silverblue.yml            | ghcr.io/blue-build/base-images/fedora-silverblue        | 43 (latest) |
| recipe/fedora-silverblue-nvidia.yml     | ghcr.io/blue-build/base-images/fedora-silverblue-nvidia | 43 (latest) |
| recipe/fedora-kinoite.yml               | ghcr.io/blue-build/base-images/fedora-kinoite           | 43 (latest) |
| recipe/fedora-kinoite-nvidia.yml        | ghcr.io/blue-build/base-images/fedora-kinoite-nvidia    | 43 (latest) |
| recipe/fedora-base-gts.yml              | ghcr.io/blue-build/base-images/fedora-base              | 42 (gts)    |
| recipe/fedora-base-nvidia-gts.yml       | ghcr.io/blue-build/base-images/fedora-base-nvidia       | 42 (gts)    |
| recipe/fedora-cosmic-gts.yml            | ghcr.io/blue-build/base-images/fedora-cosmic            | 42 (gts)    |
| recipe/fedora-cosmic-nvidia-gts.yml     | ghcr.io/blue-build/base-images/fedora-cosmic-nvidia     | 42 (gts)    |
| recipe/fedora-silverblue-gts.yml        | ghcr.io/blue-build/base-images/fedora-silverblue        | 42 (gts)    |
| recipe/fedora-silverblue-nvidia-gts.yml | ghcr.io/blue-build/base-images/fedora-silverblue-nvidia | 42 (gts)    |
| recipe/fedora-kinoite-gts.yml           | ghcr.io/blue-build/base-images/fedora-kinoite           | 42 (gts)    |
| recipe/fedora-kinoite-nvidia-gts.yml    | ghcr.io/blue-build/base-images/fedora-kinoite-nvidia    | 42 (gts)    |

## Installation

To rebase an existing atomic Fedora installation to the latest build:

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  bootc switch ghcr.io/blue-build/base-images/fedora-kinoite:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```
  bootc switch --enforce-container-sigpolicy ghcr.io/blue-build/base-images/fedora-kinoite:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/blue-build/base-images/fedora-base:latest
```
