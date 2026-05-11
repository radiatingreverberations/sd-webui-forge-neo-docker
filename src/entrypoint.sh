#!/bin/bash
set -e

source ./runtime-venv.sh

has_flag() {
    local needle="$1"
    shift

    for arg in "$@"; do
        case "$arg" in
            "${needle}"|"${needle}="*) return 0 ;;
        esac
    done

    return 1
}

if ! has_flag "--listen" "$@"; then
    set -- --listen "$@"
fi

if [ "${FORGE_PREPARE_ENVIRONMENT:-0}" != "1" ] && ! has_flag "--skip-prepare-environment" "$@"; then
    set -- --skip-prepare-environment "$@"
fi

if [ -n "${OFFLOADR_FORCE_CPU:-}" ]; then
    if ! has_flag "--cpu" "$@"; then
        set -- --cpu "$@"
    fi

    if ! has_flag "--skip-torch-cuda-test" "$@"; then
        set -- --skip-torch-cuda-test "$@"
    fi
fi

exec python launch.py "$@"
