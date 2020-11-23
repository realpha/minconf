#!/bin/bash 
THIS_CONFIG_HOME=.
BASE_DIR=$(dirname "$0")

determine_config_home_path() {
  if [ -z "$1" ]
  then
    THIS_CONFIG_HOME=$HOME
  elif [ -d "$1" ]
  then 
    THIS_CONFIG_HOME=$1
  else
    echo "ERROR: Target directory $1 does not exist!"
    exit 1
  fi
  echo "Target directory is $THIS_CONFIG_HOME"
}

setup_kubectl() {
  cat $BASE_DIR/kube.setup >> $THIS_CONFIG_HOME/.bashrc
  source $THIS_CONFIG_HOME/.bashrc
}

setup_krew() {
  cd "$(mktemp -d)" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz" &&
  tar zxf krew.tar.gz &&
  KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_$(uname -m | sed -e 's/x86_64/amd64/' -e 's/arm.*$/arm/')" &&
  "$KREW" install krew
  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
  kubectl krew install view-allocations view-secret modify-secret mtail example ctx ns tree
}

setup_vim() {
  cat $BASE_DIR/vim.setup >> $THIS_CONFIG_HOME/.vimrc
}

setup_tmux() {
  cat $BASE_DIR/profile.setup >> $THIS_CONFIG_HOME/.bash_profile
  cat $BASE_DIR/tmux.setup >> $THIS_CONFIG_HOME/.tmux.conf
}

main() {
  determine_config_home_path $1
  setup_kubectl
  setup_vim
  setup_tmux
  setup_krew 
}

main $1 &> $BASE_DIR/.setup.log
exit $?
