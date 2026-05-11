# SD WebUI Forge Neo Docker Image

This repository builds prebuilt Docker images for [SD WebUI Forge Neo](https://github.com/Haoming02/sd-webui-forge-classic). The structure follows the same build pattern as `rr-comfyui-docker`, but this repo currently publishes a single application image instead of separate extension or SSH variants.

## Available Image

|Image|Description|
|-----|-----------|
|`sd-webui-forge-neo`|Forge Neo with dependencies installed into the baked Offloadr virtual environment|

## Tags

|Tag|Description|
|---|-----------|
|`latest`|Latest upstream numeric tag for NVIDIA / CUDA 13.0|
|`neo`|Latest commit of the upstream `neo` branch for NVIDIA / CUDA 13.0|
|`amd-latest` / `amd-neo`|As above, but for AMD / ROCm 7.1.1|
|`cpu-latest` / `cpu-neo`|As above, but CPU-only|
|`amd-X.Y.Z` / `cpu-X.Y.Z`|Release-specific tags for AMD / ROCm and CPU images|

Release-specific tags track the current image for that upstream Forge Neo release and may move when this repository's Docker build logic changes.

## Running Locally

```shell
docker run --gpus=all -p 7860:7860 ghcr.io/radiatingreverberations/sd-webui-forge-neo:latest
```

Additional arguments are forwarded to Forge Neo. For example:

```shell
docker run --gpus=all -p 7860:7860 ghcr.io/radiatingreverberations/sd-webui-forge-neo:latest --api
```

The entrypoint launches `python launch.py --listen` from `/sd-webui-forge-neo` after activating the baked virtual environment at `/opt/venv`.

## Persistent Storage

Without mounts, files created inside the container are lost when the container is removed. Mount these paths for normal use:

|Container Path|Purpose|
|--------------|-------|
|`/sd-webui-forge-neo/models`|Model files|
|`/sd-webui-forge-neo/extensions`|User-installed extensions|
|`/sd-webui-forge-neo/output`|Generated outputs|
|`/sd-webui-forge-neo/cache`|Application cache|
|`/sd-webui-forge-neo/config.json`|UI settings|
|`/sd-webui-forge-neo/ui-config.json`|UI layout settings|

Forge Neo also supports referencing external Automatic1111 or ComfyUI model folders with `--forge-ref-a1111-home`, `--forge-ref-comfy-home`, and `--forge-ref-comfy-yaml`.

## Runtime Preparation

Dependencies are installed at image build time, so the container starts with `--skip-prepare-environment` by default. To allow Forge Neo to run its normal startup preparation, set:

```shell
docker run --gpus=all -e FORGE_PREPARE_ENVIRONMENT=1 -p 7860:7860 ghcr.io/radiatingreverberations/sd-webui-forge-neo:latest
```

## Docker Compose

```yaml
services:
  forge-neo:
    image: ghcr.io/radiatingreverberations/sd-webui-forge-neo:latest
    ports:
      - "7860:7860"
    volumes:
      - ./models:/sd-webui-forge-neo/models
      - ./extensions:/sd-webui-forge-neo/extensions
      - ./output:/sd-webui-forge-neo/output
      - ./cache:/sd-webui-forge-neo/cache
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    restart: unless-stopped
```

## Building

```shell
docker buildx bake
```

By default local builds consume:

* `ghcr.io/offloadr/base/cpu-core:py3.12-torch2.10.0-cpu`
* `ghcr.io/offloadr/base/amd-core:py3.12-torch2.10.0-rocm7.1.1`
* `ghcr.io/offloadr/base/nvidia-full:py3.12-torch2.10.0-cuda13.0.2`

To override them, pass Bake variables such as `CPU_BASE_IMAGE`, `AMD_BASE_IMAGE`, or `NVIDIA_BASE_IMAGE`.
