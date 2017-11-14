FROM centos:latest

WORKDIR /tmp

ADD raw_installation_files /tmp

# Install minimal dependencies
RUN yum install m4 gcc glib2-devel which libXv openssh-clients -y

# Untar Gerris dependencies in /opt
RUN mkdir -p /opt && cd /opt && \
    tar xJvf /tmp/gerris2D_with_deps.tar.xz && \
    cp -r /tmp/gerris2D.sh /opt/gerris-stable-custom/bin && \
    rm -rf /tmp/gerris2D_with_deps.tar.xz

CMD cd /tmp/cylinder_control && \
    /opt/gerris-stable-custom/bin/gerris2D.sh -m cylinder_control.gfs && \
    tail -f /dev/null
