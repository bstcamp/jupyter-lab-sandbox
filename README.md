# Jupyter Lab sandboxed environment

A sandboxed container with the complete environment needed to run
Jupyter Lab without installing additional software on the host computer.

Kernels pre-installed on the container:
- Python: [`ipykernel`](https://github.com/ipython/ipykernel)
- R: [`IRkernel`](https://irkernel.github.io/)
- Ruby: [`iruby`](https://github.com/SciRuby/iruby)

A pre-built image can be found at [`bstlang/jupyter-lab`](https://hub.docker.com/r/bstlang/jupyter-lab).

Build the docker image in Linux with `make`, `make build` or `./build.sh`.

Run the docker container with `make run` (ensures image is built beforehand) or `./run.sh`.

Open the lab's URL on your web browser (default: http://localhost:52019).

Configure Jupyter Lab with the following settings:
- `NOTEBOOKS_DIR`: notebooks root directory (default: repo root)
- `IMAGE_NAME`: name of the image to use for the container (default:
  jupyter-lab)
- `IMAGE_TAG`: tag of the image to use for the container (default: latest)
- `CONTAINER_NAME`: name of the container to create when running the lab
  sandbox (default: ${IMAGE_NAME})
- `LAB_ADDR`: host address to bind the server to (default: `127.0.0.1`)
- `LAB_PORT`: host port to bind the server to (default: `52019`)

Settings can be declared as environment variables. If a config file is found,
it overrides a previously setting found in environment variables. The config
file lookup path is as follows:
- `./.jupyter_lab`
- `~/.jupyter_lab
- `~/.jupyter_lab/config`
- `.jupyter_lab` on the same directory as the `run.sh` script

E.g.:
```
# run the lab on the default address and port
make run

# run the lab on http://127.0.0.2:51776
make run LAB_ADDR=127.0.0.2 LAB_PORT=51776
```

# Running as a local service

The container can be run as a local service that will automatically restart,
even after the machine is rebooted.

Print a help message `make help` or `./run.sh --help`.
Install/start the service with `make start` or `./run.sh --start`.
Force restart a running service (or restart it after stopped) with `make restart` or `./run.sh --restart`.
Stop the service without destroying the container with `make stop` or `./run.sh --stop`.
Uninstall the service with `make kill` or `./run.sh --kill`.
