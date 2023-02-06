FROM ubuntu:22.04
RUN mkdir /app
WORKDIR /app
RUN apt-get update && apt-get install -y tzdata

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
    apt-transport-https \
    build-essential \
    apt-utils \
    libssl-dev \
    pkg-config \
    libgstrtspserver-1.0-dev \
    gstreamer1.0-rtsp \
    vim \
    git \
    cmake \
    gcc \
    clang \
    wget
RUN apt-get install -y python3-gi python3-gst-1.0 libgirepository1.0-dev libcairo2-dev gir1.2-gstreamer-1.0 gir1.2-gtk-3.0 python3-pip
RUN pip install --upgrade wheel pip setuptools
RUN wget https://gstreamer.freedesktop.org/src/gstreamer/gstreamer-1.22.0.tar.xz --no-check-certificate
RUN tar -xf gstreamer-1.22.0.tar.xz
RUN cd gstreamer-1.22.0
RUN ls -a
RUN mkdir build
RUN pip3 install meson
RUN which meson && meson --version
RUN apt-get update && apt-get install flex -y
RUN apt-get update && apt-get install bison -y
RUN apt-get update && apt-get -y install ninja-build
RUN cd /app/gstreamer-1.22.0 && meson build -Dintrospection=disabled
RUN cd /app/gstreamer-1.22.0/build && ninja && ninja install
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && /bin/bash ~/miniconda.sh -b -p /opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH
RUN conda config --add channels conda-forge
RUN conda config --set channel_priority strict
RUN conda install gst-plugins-bad
RUN conda install gst-plugins-good
RUN conda install gst-plugins-ugly
RUN conda install gst-plugins-base
RUN conda install gst-libav
RUN cd /app
RUN apt-get install -y gstreamer-1.0 gstreamer1.0-dev
RUN apt-get install -y git autoconf automake libtool
RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
    libgstrtspserver-1.0-dev \
    gstreamer1.0-rtsp
COPY . .
RUN gcc rtsp_mp4_server.c -o rtsp_mp4_server `pkg-config --cflags --libs gstreamer-1.0 gstreamer-rtsp-server-1.0`
EXPOSE 8554/tcp
CMD ["./rtsp_mp4_server"]
