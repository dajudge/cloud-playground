#! /bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

IMG=$(docker build -q $DIR/.workbench)

docker run --rm \
    -v /etc/passwd:/etc/passwd \
    -v /etc/group:/etc/group \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/run/libvirt/libvirt-sock:/var/run/libvirt/libvirt-sock \
    -v /var/lib/libvirt:/var/lib/libvirt \
    -v $HOME:$HOME \
    -w $DIR \
    --net host \
    --privileged \
    -it $IMG sudo -u ${USER} -i sh -c "cd $DIR; bash"