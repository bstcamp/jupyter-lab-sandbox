#!/bin/bash -e

SRC_DIR="${SRC_DIR:-"$(git rev-parse --show-toplevel)"}"

for config_file in .jupyter_lab "${HOME}/.jupyter_lab" "${HOME}/.jupyter_lab/config" "$(dirname "$(realpath "$0")")/.jupyter_lab"; do
  if [ -e "${config_file}" ]; then
    echo "config file found at '"${config_file}"'"
    source "${config_file}"
    break
  fi
done

notebooks_dir="${NOTEBOOKS_DIR:-""}"

image_name="${IMAGE_NAME:-"$(basename "${SRC_DIR}")"}"
image_tag="${IMAGE_TAG:-latest}"

container_image="${image_name}:${image_tag}"
container_name="${CONTAINER_NAME:-"${image_name}"}"

lab_addr="${LAB_ADDR:-127.0.0.1}"
lab_port="${LAB_PORT:-52019}"

docker_args=()
docker_extra_args=()

mode=run

while [ "$#" -gt 0 ]; do
  arg="$1"; shift
  case "${arg}" in
    --help)
      cat <<EOF
usage: $0 [command [args...]] [docker_cli_args...]

commands:
  --help:     print a help message and exit

  --run:      runs the lab sandbox in interactive mode (stop with Ctrl-C)
              this is the default command when none are given

  --start:    runs the lab sandbox in the background as a service it will restart
              after every reboot until stopped/killed

  --restart:  force restart a previously started lab sandbox, even if it was stopped

  --stop:     gracefully terminates a lab sandbox running in the background,
              allowing the possibility of restarting it later

  --kill:     forcefully stops a lab sandbox running in the background, releasing
              its resources and preventing it from running after every reboot

run/start args:
  --notebooks <dir>:  host directory containing jupyter notebooks that should be
                      mounted in the container; allows notebooks to be persisted on
                      the host even after the container is killed; also allows the
                      container access to notebooks currently on the host
EOF
      exit 0
      ;;

    --run|--start|--restart|--stop|--kill)
      mode="${arg:2}"
      ;;

    --notebooks)
      [ "$#" -gt 0 ] || (echo "expected notebooks directory"; exit 1)
      notebooks_dir="$1"; shift
      ;;

    *)
      docker_extra_args+=("${arg}")
      ;;
  esac
done

cat >&2 <<EOF
notebooks dir: ${notebooks_dir}
image name: ${container_image}
container name: ${container_name}
lab address: http://${lab_addr}:${lab_port}/

EOF

case "${mode}" in
  run)
    docker_args+=(run -it --rm)
    ;;

  start)
    docker_args+=( \
      run
      --name "${container_name}"
      --detach
      --restart unless-stopped
    )
    ;;

  restart)
    docker_args+=(container restart "${container_name}")
    ;;

  stop)
    docker_args+=(container stop "${container_name}")
    ;;

  kill)
    docker_args+=(container rm -f "${container_name}")
    ;;

  *)
    echo "invalid mode: ${mode}"
    exit 1
    ;;
esac

docker_args+=("${docker_extra_args[@]}")

if [ "${mode}" = "start" ] || [ "${mode}" = "run" ]; then
  docker_args+=( \
    --env LAB_PORT="${lab_port}"
    --publish "${lab_addr}:${lab_port}:${lab_port}"
  )

  if [ -d "${notebooks_dir}" ]; then
    docker_args+=(--volume "${notebooks_dir}:/src/notebooks")
  fi

  if [ -e /dev/dri ]; then
    docker_args+=(--device /dev/dri:/dev/dri)
  fi

  docker_args+=("${container_image}")
fi

(set -x; docker "${docker_args[@]}")
