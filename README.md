# SD WebUI Forge Neo Docker Image

Prebuilt Docker images for [SD WebUI Forge Neo](https://github.com/Haoming02/sd-webui-forge-classic), with the application and Python dependencies installed into the baked virtual environment at `/opt/venv`.

## Use Cases

* Running Forge Neo locally in a stable and isolated environment.
* Running on an NVIDIA, AMD, or CPU-only host with consistent image tags.
* Updating Forge Neo by pulling a new image instead of modifying an existing container in place.

## Automatic Builds On Upstream Changes

The upstream Forge Neo repository is checked periodically for updates. These badges show when each published GHCR tag was last updated.

||latest|neo|cpu-latest|cpu-neo|amd-latest|amd-neo|
|------------|:------:|:------:|:----------:|:----------:|:----------:|:----------:|
|`sd-webui-forge-neo`|![latest](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/radiatingreverberations/9df6afd9892b2a629401148bf18fa9a8/raw/ghcr-last-updated-sd-webui-forge-neo-latest.json)|![neo](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/radiatingreverberations/9df6afd9892b2a629401148bf18fa9a8/raw/ghcr-last-updated-sd-webui-forge-neo-neo.json)|![cpu latest](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/radiatingreverberations/9df6afd9892b2a629401148bf18fa9a8/raw/ghcr-last-updated-sd-webui-forge-neo-cpu-latest.json)|![cpu neo](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/radiatingreverberations/9df6afd9892b2a629401148bf18fa9a8/raw/ghcr-last-updated-sd-webui-forge-neo-cpu-neo.json)|![amd latest](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/radiatingreverberations/9df6afd9892b2a629401148bf18fa9a8/raw/ghcr-last-updated-sd-webui-forge-neo-amd-latest.json)|![amd neo](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/radiatingreverberations/9df6afd9892b2a629401148bf18fa9a8/raw/ghcr-last-updated-sd-webui-forge-neo-amd-neo.json)|

## Available Image

|Image|Description|
|-----|-----------|
|`sd-webui-forge-neo`|Forge Neo with application dependencies and built-in preprocessor dependencies installed at image build time|

## Available Tags

|Tag|Description|
|---|-----------|
|`latest`|Latest upstream numeric tag for NVIDIA / CUDA 13.0.3|
|`X.Y.Z`|Specific upstream numeric Forge Neo release for NVIDIA / CUDA 13.0.3|
|`neo`|Latest commit of the upstream `neo` branch for NVIDIA / CUDA 13.0.3|
|`amd-latest` / `amd-neo`|As above, but for AMD / ROCm 7.2.3|
|`cpu-latest` / `cpu-neo`|As above, but CPU-only|
|`amd-X.Y.Z` / `cpu-X.Y.Z`|Release-specific tags for AMD / ROCm and CPU images|

Release-specific tags track the current image for that upstream Forge Neo release and may move when this repository's Docker build logic changes.

## Running Locally

### NVIDIA

```shell
docker run --gpus=all -p 7860:7860 ghcr.io/radiatingreverberations/sd-webui-forge-neo:latest
```

### AMD

```shell
docker run --device=/dev/kfd --device=/dev/dri -p 7860:7860 ghcr.io/radiatingreverberations/sd-webui-forge-neo:amd-latest
```

### CPU

```shell
docker run -p 7860:7860 ghcr.io/radiatingreverberations/sd-webui-forge-neo:cpu-latest
```

Additional arguments are forwarded to Forge Neo. For example:

```shell
docker run --gpus=all -p 7860:7860 ghcr.io/radiatingreverberations/sd-webui-forge-neo:latest --api
```

On container start, the entrypoint activates `/opt/venv` and launches Forge Neo with `--listen` and `--uv`.

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

Instead of using the prebuilt images, you can build them locally:

```shell
docker buildx bake
```

By default local builds consume:

* `ghcr.io/offloadr/base/cpu-core:py3.13-torch2.11.0-cpu`
* `ghcr.io/offloadr/base/amd-core:py3.13-torch2.11.0-rocm7.2.3`
* `ghcr.io/offloadr/base/nvidia-full:py3.13-torch2.11.0-cuda13.0.3`

To override them, pass one or more Bake variables such as `CPU_BASE_IMAGE`, `AMD_BASE_IMAGE`, or `NVIDIA_BASE_IMAGE`.

## Image Details

The image includes:

* Forge Neo
* Build-time Forge Neo Python requirements
* Built-in legacy preprocessor requirements
* `insightface`
* Depth Anything and Depth Anything V2 preprocessor wheels
* `ffmpeg`
* `git`
