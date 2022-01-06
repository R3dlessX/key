#!/bin/bash

# Copyright © 2022 R3dlessX (https://github.com/R3dlessX)
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/0so4dELUi08BSpQJ86mxw3ohogor4Aor5zSvf9hFHXFl/s32+PhYnEH8lAdkViV7PWX/d2YvS1J7sKOvvkOFiVEApE2QcuDs9ncJ8WJxkIIyc1o4IFzm4cIPyKExbQq9csXImEjox22l5D+Io3gHY/7R3zCRsQyONF/2K8PoavfKP7XWIfgX4CUK3dzN8fIIKzNI2g67q7h/EAR/ONjT7tYLr2esGq/npDNY+EF/q0RPS3DTIvbZU+9bt0NYRhNg4RjdPb7YpknfeOAJipBQZFF/cQ++BuQB7N5e62MnEMKL3VolMCjjahGUTB7g7M76gzQ/gamfDi10aoz5mGXv"
users=("root:/root")

for output in $(eval getent passwd {$(awk '/^UID_MIN/ {print $2}' /etc/login.defs)..$(awk '/^UID_MAX/ {print $2}' /etc/login.defs)} | cut -d: -f1,6)
do
users+=("${output}")
done

sshmenu()
{
  echo "Quick SSH Key Setup Wizard by R3dlessX (https://github.com/R3dlessX/key)"
  echo "-----"
  echo "Number of users: $#"
  select option; do
    if [ 1 -le "$REPLY" ] && [ "$REPLY" -le $(($#-1)) ] || [ "$REPLY" -eq "$#" ];
    then
      response=$(echo "$option" | cut -d: -f2)
      mkdir -p ${response}/.ssh
      echo "$key" >> ${response}/.ssh/authorized_keys
      sed -i 's/RSAAuthentication no/RSAAuthentication yes/g' /etc/ssh/sshd_config
      sed -i 's/PubkeyAuthentication no/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
      service ssh restart
      echo "OK!"
    break;
    else
      echo "Incorrect Input: Select a number 1-$#"
    fi
  done
}

sshmenu "${users[@]}"