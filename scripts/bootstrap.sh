#!/bin/bash

set -e

sudo apt update && sudo apt install -y \
  build-essential \
  curl \
  git \
  unzip \
  zip \
  zsh \
  fd-find \
  ripgrep \
  fzf \
  tmux \
  python3 \
  python3-pip \
  libssl-dev \
  libreadline-dev \
  zlib1g-dev \
  libbz2-dev \
  libsqlite3-dev \
  llvm \
  libncursesw5-dev \
  xz-utils \
  tk-dev \
  libxml2-dev \
  libxml2sec1-dev \
  libffi-dev \
  liblzma-dev \
  software-properties-common

echo "System packages installed."
