FROM docker.io/osrf/ros:iron-desktop-full
LABEL org.opencontainers.image.title="0reg.cf/tiger3018/ros-ws:iron"

ARG S6_OVERLAY_VERSION=3.1.5.0

RUN  echo "deb http://mirrors.cqu.edu.cn/ubuntu jammy main universe multiverse restricted\ndeb http://mirrors.cqu.edu.cn/ubuntu jammy-security main universe multiverse restricted\ndeb http://mirrors.cqu.edu.cn/ubuntu jammy-updates main universe multiverse restricted"> /etc/apt/sources.list \
&&   echo "deb http://mirrors.cqu.edu.cn/ros2/ubuntu jammy main" > /etc/apt/sources.list.d/ros2-latest.list \
&&   apt-get update \
&&   apt-get install ssh curl vim tini -y \
&&   apt-get install ros-iron-foxglove-bridge ros-iron-rosbridge-suite -y \
&&   apt-get install libasio-dev can-utils -y \
&&   apt-get clean \
&&   find /var/log/ -type f -delete

# <https://github.com/just-containers/s6-overlay>
RUN  curl -L https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz > /tmp/s6-overlay-noarch.tar.xz \
&&   curl -L https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz > /tmp/s6-overlay-x86_64.tar.xz \
&&   tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
&&   tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz \
&&   rm -rf /tmp/*

RUN  echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /root/.bashrc

# <https://github.com/antoineco/sshd-s6-docker>
COPY etc/ /etc

ARG USER_SSH_PUBKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEJs5wNeBjDuCMZyK3kzXvsN40WIzF/1n8/P+VqHCOk3"
RUN  mkdir -p /root/.ssh \
&&   mkdir -p /root/work \
&&   echo "${USER_SSH_PUBKEY}" > /root/.ssh/authorized_keys

#COPY bin/ /root/.vscodium-server/bin/
#RUN  tar zxf $(find /root/.vscodium-server/bin/ -name '*.tar.gz')
RUN /etc/code-server.sh

ENV S6_KEEP_ENV=1
EXPOSE 2222 8765
WORKDIR /root/work
# This is s6-overlay
ENTRYPOINT ["/init"] 
CMD ["tini", "-s", "/etc/user_script/workspace_entrypoint.sh", "ros2", "launch", "foxglove_bridge", "foxglove_bridge_launch.xml", "address:=127.0.0.1"]

