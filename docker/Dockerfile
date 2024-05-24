FROM debian:unstable-slim

#####
# apt

ENV DEBIAN_PRIORITY=critical
ENV DEBIAN_FRONTEND=noninteractive

##############
# repositories

RUN truncate --size=0 /etc/apt/sources.list
RUN rm -rf /etc/apt/sources.list.d
RUN mkdir -p /etc/apt/sources.list.d
COPY debian-testing.list /etc/apt/sources.list.d/
COPY debian-unstable.list /etc/apt/sources.list.d/

RUN apt-get update && apt-get upgrade -y

####################
# basic dev packages

RUN apt-get update \
  && apt-get install -y \
    build-essential \
    make libtool \
    dkms \
    libffi-dev

#############
# GPU drivers

RUN apt-get update \
  && apt-get install -y \
    vainfo \
      mesa-va-drivers \
    vdpauinfo \
      mesa-vdpau-drivers \
    vulkan-tools \
      mesa-vulkan-drivers \
    mesa-opencl-icd \
    intel-media-va-driver-non-free \
      intel-gpu-tools \
      intel-opencl-icd \
    nvidia-driver \
      nvidia-driver-full \
      nvidia-kernel-dkms \
      nvidia-vdpau-driver \
      nvidia-cuda-toolkit \
      nvidia-tesla-driver \
        nvidia-tesla-kernel-dkms \
        nvidia-tesla-opencl-icd \
        nvidia-tesla-vulkan-icd

##########
# python 3

RUN apt-get update \
  && apt-get install -y \
    python-is-python3 \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-venv

RUN python3 -m venv /srv/venv

###############################
# jupyter-lab and python kernel

RUN . /srv/venv/bin/activate \
  && CFLAGS="-march=native" \
    CPPFLAGS="-march=native" \
    pip install --upgrade \
      ipython \
      jupyterlab \
      \
      ipykernel \
      \
      matplotlib \
      numpy \
      pandas \
      rdkit \
      tensorboard \
      tensorflow \
      tensorrt

#############
# openbabel 3

RUN apt-get update \
  && apt-get install -y \
    libopenbabel-dev \
    swig

RUN . /srv/venv/bin/activate \
  && CFLAGS="-march=native" \
    CPPFLAGS="-march=native" \
    pip install --upgrade \
      --global-option="build_ext" \
      --global-option="-I/usr/include/openbabel3" \
      openbabel

#############
# ruby kernel

# https://github.com/SciRuby/iruby?tab=readme-ov-file#installation
RUN apt-get update \
  && apt-get install -y \
    ruby ruby-dev
RUN . /srv/venv/bin/activate \
  && gem install \
    iruby \
    matplotlib \
  && iruby register --force

##########
# R kernel

RUN apt-get update \
  && apt-get install -y \
    r-base r-recommended

# https://irkernel.github.io/installation/#binary-panel
RUN . /srv/venv/bin/activate \
  && Rscript \
    -e "install.packages('IRkernel')" \
    -e "IRkernel::installspec(user = FALSE)"

############
# entrypoint

ENV NOTEBOOKS_DIR="/src/notebooks"
RUN mkdir -p "${NOTEBOOKS_DIR}"

COPY entrypoint.sh /srv
ENTRYPOINT "/srv/entrypoint.sh"

#########
# cleanup

RUN apt-get upgrade -y
RUN apt autoremove --purge -y
RUN apt-get clean -y
RUN rm -rf /var/lib/apt/lists/*
