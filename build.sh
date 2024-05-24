#!/bin/bash -e

SRC_DIR="${SRC_DIR:-"$(git rev-parse --show-toplevel)"}"

for config_file in .jupyter_lab "${HOME}/.jupyter_lab" "${HOME}/.jupyter_lab/config" "$(dirname "$(realpath "$0")")/.jupyter_lab"; do
  if [ -e "${config_file}" ]; then
    echo "config file found at '"${config_file}"'"
    source "${config_file}"
    break
  fi
done

image_name="${IMAGE_NAME:-"$(basename "${SRC_DIR}")"}"
image_tag="${IMAGE_TAG:-latest}"

container_image="${image_name}:${image_tag}"
container_name="${CONTAINER_NAME:-"${image_name}"}"

cat >&2 <<EOF
container name: ${container_name}
EOF

(set -x; \
  DOCKER_BUILDKIT=1 \
    docker build \
      -t "${container_image}" \
      "$@" \
      docker \
)
