#!/bin/bash

# Function to start installation
Init (){
  # check the path or use the path parameter
  if [ $# -eq 0 ]; then
    PWDINIT=$PWD
  else
    PWDINIT=$1
  fi

  # confirmation and installation/aborted
  echo "Directory of Installation is $PWDINIT"
  read -s -N 1 -t 10 -p "Do you want to continue? [Y/n]" key; echo $key

  case $key in
    [yY])
      echo "installing..."
      Installation $PWDINIT
      ;;
    [nN])
      echo "installing..."
      Installation $PWDINIT
      ;;
    *)
      if [ "$key" == $'\x0a' ] ;then
        echo "installing..."
        Installation $PWDINIT
      else
        echo "Aborting installation."
        exit
      fi
      ;;
  esac
}


# function to install.
Installation (){
  $PWDINIT=$1

  # check who the user is and tour permission.
  SUDO=''
  WUSER=`stat -c "%a - %n" "$PWDINIT" | cut -c 3`
  if [ "$EUID" -eq 0 ]; then
    SUDO='sudo'
    Download $SUDO $PWDINIT
    SLinks 1
  else
    if [ "$WUSER" -eq "7" ]; then
      Download $SUDO $PWDINIT
      SLinks 0
      echo "Installation completed!"
    else
      echo "Permission denied."
      echo "Installation aborted."
    fi
  fi
}

Download (){
  SUDO=$1
  PWDINIT=$2

  # create a directory for install node.js.
  $SUDO mkdir -p $PWDINIT"/nodejs"
  cd $PWDINIT"/nodejs"

  # download the "last" binary node.js and unconpress tar.xz.
  wget https://nodejs.org/dist/v16.13.1/node-v16.13.1-linux-x64.tar.xz
  tar -xf node-v16.13.1-linux-x64.tar.xz
  $SUDO mv node-v16.13.1-linux-x64 node-v16.13.1
}

# function to create symbolic links
SLinks (){
  Arg=$1
  if [ $Arg = 1 ]; then
    # create a directory on /opt/app and create symbolik link of node, npm and npx.
    $SUDO unlink /usr/bin/node
    $SUDO unlink /usr/bin/npm
    $SUDO unlink /usr/bin/npx
    $SUDO ln -s $PWDINIT/nodejs/node-v16.13.1/bin/node /usr/bin/node
    $SUDO ln -s $PWDINIT/nodejs/node-v16.13.1/bin/npm /usr/bin/npm
    $SUDO ln -s $PWDINIT/nodejs/node-v16.13.1/bin/npx /usr/bin/npx

    # run version of node.js
    node -v
    npm version
    npx -v
  elif [ $Arg = 0 ]; then
    # run version of node.js
    echo "Local of nodejs bin"
    echo "$PWDINIT/nodejs/node-v16.13.1/bin/node"
    $PWDINIT/nodejs/node-v16.13.1/bin/node -v
    echo "$PWDINIT/nodejs/node-v16.13.1/bin/npm"
    $PWDINIT/nodejs/node-v16.13.1/bin/npm version
    echo "$PWDINIT/nodejs/node-v16.13.1/bin/npx"
    $PWDINIT/nodejs/node-v16.13.1/bin/npx -v
  fi

  echo "Installation completed!"
}

[ $# -eq 0 ] && Init && exit

[ "$1" = "-h" -o "$1" = "--help" ] && echo "
Usage: $0
or: $0 [OPTION]
Without option, it will be installed in the local directory.
Option:
-d, --dir-install   directory of installation. Ex: -d 'directory'.
-h, --help          display this help and exit.
" && exit

[ "$1" = "-d" -o "$1" = "--dir-install" ] && Init $2 && exit

[  "$1" != "-h" -o "$1" != "--help" -o "$1" != "-d" -o "$1" != "--dir" ] && echo "
chmod: invalid option -- '$1'
Try '$0 -h' or '$0 --help' for more information.
"  && exit
