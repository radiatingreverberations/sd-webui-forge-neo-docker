variable "DOCKER_REGISTRY_URL" {
    default = "ghcr.io/radiatingreverberations/"
}

variable "FORGE_NEO_VERSION" {
    default = "neo"
}

variable "REFRESH_FORGE_NEO" {
    default = "0"
}

variable "CPU_BASE_IMAGE" {
    default = "ghcr.io/offloadr/base/cpu-core:py3.12-torch2.10.0-cpu"
}

variable "AMD_BASE_IMAGE" {
    default = "ghcr.io/offloadr/base/amd-core:py3.12-torch2.10.0-rocm7.1.1"
}

variable "NVIDIA_BASE_IMAGE" {
    default = "ghcr.io/offloadr/base/nvidia-full:py3.12-torch2.10.0-cuda13.0.2"
}

variable "IMAGE_LABEL" {
    default = "latest"
}

variable "BASE_FLAVOR" {
    default = "cpu"
    validation {
        condition     = BASE_FLAVOR == "nvidia" || BASE_FLAVOR == "cpu" || BASE_FLAVOR == "amd"
        error_message = "The variable 'BASE_FLAVOR' must be 'nvidia', 'cpu', or 'amd'."
    }
}

group "default" {
    targets = [
        "sd-webui-forge-neo"
    ]
}

target "sd-webui-forge-neo" {
    context    = "src"
    dockerfile = "dockerfile"
    args = {
        FORGE_NEO_VERSION = "${FORGE_NEO_VERSION}"
        REFRESH_FORGE_NEO = "${REFRESH_FORGE_NEO}"
        BASE_IMAGE        = BASE_FLAVOR == "nvidia" ? NVIDIA_BASE_IMAGE : BASE_FLAVOR == "amd" ? AMD_BASE_IMAGE : CPU_BASE_IMAGE
    }
    tags       = ["${DOCKER_REGISTRY_URL}sd-webui-forge-neo:${notequal("nvidia", BASE_FLAVOR) ? "${BASE_FLAVOR}-" : ""}${IMAGE_LABEL}"]
    platforms  = ["linux/amd64"]
    cache-from = ["type=registry,ref=${DOCKER_REGISTRY_URL}sd-webui-forge-neo:${notequal("nvidia", BASE_FLAVOR) ? "${BASE_FLAVOR}-" : ""}${IMAGE_LABEL}"]
    cache-to   = ["type=inline"]
}

