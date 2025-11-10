export BB_REGISTRY := "ghcr.io"
export BB_REGISTRY_NAMESPACE := "blue-build"
export BB_GENISO_SECURE_BOOT_URL := "https://github.com/blue-build/base-images/raw/main/files/base/etc/pki/akmods/certs/akmods-blue-build.der"
export BB_GENISO_ENROLLMENT_PASSWORD := "bluebuild"
export BB_GENISO_VARIANT := "kinoite"

build *args:
    bluebuild build {{args}}

generate-iso recipe:
    #!/usr/bin/env nu
    let recipe = open {{ recipe }}
        | default [] alt-tags
        | select name alt-tags
    let tag = if ($recipe.alt-tags | is-empty) {
        'latest'
    } else {
        $recipe.alt-tags | first
    }
    let name = $recipe.name
    let image = $'(
            $env.BB_REGISTRY
        )/(
            $env.BB_REGISTRY_NAMESPACE
        )/(
            $name
        ):($tag)'
    (^bluebuild
        generate-iso
        --iso-name $'($name)-($tag).iso'
        --output-dir .iso/
        image $image)

generate-secureboot-key:
    openssl req -config ./openssl.cnf \
        -new -x509 -newkey rsa:2048 \
        -nodes -days 36500 -outform DER \
        -keyout ./MOK.priv \
        -out ./files/base/etc/pki/akmods/certs/akmods-blue-build.der
