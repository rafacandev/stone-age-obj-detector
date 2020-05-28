FROM tensorflow/tensorflow:2.2.0
# Base root folder /tensorflow
ENV TENSORFLOW_FOLDER /tensorflow
WORKDIR ${TENSORFLOW_FOLDER}

# Required system packages
RUN apt-get update -y
RUN apt-get install -y wget curl git protobuf-compiler python-pil python-lxml libsm6 libxext6 libxrender-dev

# Clone Keras Retinanet repository
RUN git clone https://github.com/rafasantos/keras-retinanet.git
ENV KERAS_RETINANET_FOLDER ${TENSORFLOW_FOLDER}/keras-retinanet

# Required pip packages
RUN pip install pandas
RUN pip install cython
RUN pip install matplotlib
RUN pip install progressbar2

# Install Keras Retinanet
WORKDIR ${KERAS_RETINANET_FOLDER}
RUN git fetch --all
RUN git checkout tensorboard-image-previews
RUN pip install .
RUN python setup.py build_ext --inplace

# Default workdir
WORKDIR ${TENSORFLOW_FOLDER}/workspace
