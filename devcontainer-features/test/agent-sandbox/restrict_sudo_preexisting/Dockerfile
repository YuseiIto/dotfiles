FROM ubuntu:24.04
RUN apt-get update && apt-get install -y --no-install-recommends sudo \
 && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu \
 && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
 && chmod 0440 /etc/sudoers.d/ubuntu
