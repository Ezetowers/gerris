FROM centos:latest

WORKDIR /

ENV PKG_CONFIG_PATH /usr/local/lib/pkgconfig

# Add common directory
ADD Gerris /gerris

# RUN echo "proxy=http://10.1.1.88:3128" >> /etc/yum.conf && \
# 	echo "proxy_username=pgmendez" >> /etc/yum.conf && \
# 	echo "proxy_password=Octubre2017" >> /etc/yum.conf && \
# 	yum update -y

RUN yum update -y

########## Install dependencies ##########

RUN yum groupinstall "Development Tools" -y && \
	yum groupinstall "Compatibility Libraries" -y && yum install startup-notification-devel-0.12-8.el7.i686 startup-notification-devel-0.12-8.el7.x86_64 ncurses-devel zlib-devel texinfo gtk2-devel qt-devel tcl-devel tk-devel kernel-headers kernel-devel fftw-devel-3.3.3-8.el7.i686 fftw-devel-3.3.3-8.el7.x86_64 -y && \
	yum install gerris/packages/pangox-compat-0.0.2-2.el7.x86_64.rpm -y && yum install gerris/packages/pangox-compat-devel-0.0.2-2.el7.x86_64.rpm -y

# install gtklext
RUN tar -xvzf /gerris/packages/gtkglext-1.2.0.tar.gz && \
    cd /gtkglext-1.2.0 && ./configure --prefix=/opt/gtkglex-1.2.0 && \
    make -j4 && make install && \
    cd / && rm -rf /gerris/packages/gtkglext-1.2.0* /gtkglext-1.2.0*

# install openmpi
RUN tar -xvzf /gerris/packages/openmpi-3.0.0.tar.gz &&\
    cd /openmpi-3.0.0 && \
    ./configure --prefix=/opt/openmpi-3.0.0 && \
    make -j4 && make install && \
    cd / && rm -rf /gerris/packages/openmpi-3.0.0* /openmpi-3.0.0*

ADD env /opt/env

# install hypre
RUN source /opt/env/openmpi-3.0.0.sh && \
    tar -xvzf /gerris/packages/hypre-2.11.2.tar.gz && \
    cd /hypre-2.11.2/src && \
    ./configure --prefix=/opt/hypre-2.11.2 --enable-shared && \
    make -j4 && make install && \
    cd / && rm -rf /gerris/packages/hypre-2.11.2* /hypre-2.11.2*

# install ffmpeg
RUN tar -xvzf /gerris/packages/ffmpeg-3.4.tar.gz && \
    cd ffmpeg-3.4 && ./configure --enable-shared --disable-x86asm --prefix=/opt/ffmpeg-3.4 && \
    make -j4 && make install && \
    cd / && rm -rf /gerris/packages/ffmpeg-3.4* /ffmpeg-3.4*

# install gts
RUN source /opt/env/openmpi-3.0.0.sh && \
    source /opt/env/ffmpeg-3.4.sh && \
    source /opt/env/hypre-2.11.2.sh && \
    source /opt/env/gtkglext-1.2.0.sh && \
    cd /gerris/gerris/gts-stable && \
    sh autogen.sh && \
    automake --add-missing && \
    ./configure --prefix=/opt/gts-stable && \
    make -j4 install && \
    cd / && rm -rf /gerris/gerris/gts-stable*

# install gerris
RUN source /opt/env/openmpi-3.0.0.sh && \
    source /opt/env/ffmpeg-3.4.sh && \
    source /opt/env/hypre-2.11.2.sh && \
    source /opt/env/gtkglext-1.2.0.sh && \
    source /opt/env/gts-stable.sh && \
    cd /gerris/gerris/gerris-stable && \
    sh autogen.sh && \
    automake --add-missing && \
    ./configure --prefix=/opt/gerris-stable && \
    make -j4 install && cd / && rm -rf /gerris/gerris/gerris-stable*

# install Custom Gerris
RUN git clone https://github.com/pablodroca/Gerris-ControllerModule.git
RUN source /opt/env/openmpi-3.0.0.sh && \
    source /opt/env/ffmpeg-3.4.sh && \
    source /opt/env/hypre-2.11.2.sh && \
    source /opt/env/gtkglext-1.2.0.sh && \
    source /opt/env/gts-stable.sh && \
    source /opt/env/gerris-stable.sh && \
    cd /Gerris-ControllerModule/gerris-stable && \
    sh autogen.sh && \
    # sh autogen.sh CFLAGS='-ggdb -g -Og -DG_DEBUG=\"debug\"' && \
    ./configure --prefix=/opt/gerris-stable-custom && \
    make -j4 && make install
