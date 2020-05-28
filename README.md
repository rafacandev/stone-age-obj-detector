Tensorflow Object Detection Training With One Custom Class and Transfer Learning Tutorial
=========================================================================================

Introduction
------------
This tutorial describes how to training a custom Tensorflow (v2.2.0) with Tensorflow Keras. It also automates some of the common tasks and also demonstrates how to execute the process in a docker container.

It also serves as basis if we want to expand and create your own training setup. For simplicity, we are going to train a custom model to detect car's tire.

Requirements
------------
The following applications should be installed:
- **Docker**: as described in [Docker Website](https://docs.docker.com/get-docker/).
- **LabelImg**: as described in [LabelImg Website](https://github.com/tzutalin/labelImg)

Create a Project Folder
=======================
Create a project root folder in your system. From now on, this folder will be referenced as `PRJ_FOLDER`.
```
mkdir PRJ_FOLDER
cd PRJ_FOLDER
```

Preparing the Workspace
-----------------------

In `PRJ_FOLDER`, run:
```
mkdir training
mkdir training/images
mkdir training/images/train
mkdir training/images/validation
mkdir training/pre-trained-model
mkdir training/scripts
```

Directory Layout
----------------
At this point your `PRJ_FOLDER` should look like:
```
├── Dockerfile
└── training
    ├── images
    │   ├── train
    │   └── validation
    ├── pre-trained-model
    ├── scripts
```

- `Dockerfile`: used when training in a docker container
- `training`: files for training our custom model
- `training/annotations`: all `*.csv` files and the respective TensorFlow `*.record` files, which contain the list of annotations for our dataset images.
- `training/images`: files related to our dataset. It contains all images and annotation files.
- `training/images/train`: training images and their respective Pascal VOC annotation files used to train our model
- `training/images/validation`: validation images and their respective Pascal VOC annotation files used to validate our model
- `training/pre-trained-model`: pre-trained model of our choice to be used as a starting checkpoint for our training job

Prepare the Dataset
===================

Download Images
---------------
Save the training images in the `PRJ_FOLDER/training/images/train`. In our example, save the [download_training_images.sh](training/scripts/download_training_images.sh) in `PRJ_FOLDER/training/scripts/download_training_images.sh`.

In `PRJ_FOLDER`, run:
```
sh training/scripts/download_training_images.sh
```

In `PRJ_FOLDER`, verify if the images are downloaded in the correct folders:
```
ls -l training/images/train/ | grep jpg | wc -l
#> 120
ls -l training/images/test/ | grep jpg | wc -l
#> 20
```

Label the Images
----------------
Run **LabelImg** and label the images in `PRJ_FOLDER/training/images/train` and `PRJ_FOLDER/training/images/train`. Make sure to label the images using **PascalVOC** format as described in [LabelImg Usage](https://github.com/tzutalin/labelImg#steps-pascalvoc). In some instances, you might see a image without any tire, that is alright just make sure to save a corresponding `.xml` label file without objects in it. Alternatively, if you want to skip the manual labelling; then, you can donwload our [train labels](training/images/train) and [validation labels](training/images/test).

> **Note**: _Labels_ are also known as _classes_ and these terms are used interchangeably.

At this point, `PRJ_FOLDER/training/images/train` and `PRJ_FOLDER/training/images/train` should contain a label `.xml` file for each image.

In `PRJ_FOLDER`, verify that the labels are created:
```
ls -l training/images/train/ | grep xml | wc -l
#> 120
ls -l training/images/test/ | grep xml | wc -l
#> 20
```

Create a Labels File
--------------------
We need a file to describe the labels (aka classes) that we are going to use. In our case, there will be only one label named `tire` at index 0.

Create `PRJ_FOLDER/training/images/labels.csv` as:
```
tire,0
```

Converting *.xml to *.csv
-------------------------
Save the [pascal_xml_to_csv.py](training/scripts/pascal_xml_to_csv.py) in `PRJ_FOLDER/training/scripts/pascal_xml_to_csv.py`.

In `PRJ_FOLDER`, run:
```
python training/scripts/pascal_xml_to_csv.py -i training/images/train -o training/images/train_labels.csv -p train
python training/scripts/pascal_xml_to_csv.py -i training/images/validation -o training/images/validation_labels.csv -p validation
```


Prepare a Pre Trained Model
===========================

In `PRJ_FOLDER`, save a pre-trained model:
```
wget -P training/pre-trained-model https://github.com/fizyr/keras-retinanet/releases/download/0.5.1/resnet50_coco_best_v2.1.0.h5
```

Train using a Docker Container
==============================

Build a Docker Container
------------------------

In `PRJ_FOLDER`, save our [Dockerfile](Dockerfile).

In `PRJ_FOLDER`, build a docker image named `keras-retinanet` with tagged as `1.0`:
```
docker build --tag keras-retinanet:1.0 .
```

In `PRJ_FOLDER`, run a docker container:
```
docker run --name kr -it --rm -p 0.0.0.0:6006:6006 -v $PWD:/tensorflow/workspace keras-retinanet:1.0 bash
```
- `--name`: a name for the container.
- `-it`: run in a interactive terminal.
- `--rm`: remove the container when done.
- `-p`: binds ports from the container to our host system.
- `-v`: populates the content of `$PWD` (current directory) into the container's `/tensorflow/workspace` folder.
- `keras-retinanet:1.0`: the docker image, in our case the one we just built.
- `bash`: runs bash in the interactive terminal.

Now the terminal is attached to bash running in our docker container. Moreover, `-v $PWD:/tensorflow/workspace` mounts the content of the current folder into the container's `/tensorflow/workspace` which means that we should see the content `PRJ_FOLDER` from this interactive terminal.


In `Docker Interactive Terminal`,
```
sh training/train.sh
```

In `PRJ_FOLDER`, start an instance of _tensorboard_:
```
docker exec kr tensorboard --host 0.0.0.0 --port 6006 --logdir=/tensorflow/workspace/training/tensorboard
```

Navigate to http://localhost:6006 and visualize our training performance.

### Other Userful Commands
Start training in detached mode:
```
docker run --name kr -d --rm -p 0.0.0.0:6006:6006 -v $PWD:/tensorflow/workspace keras-retinanet:1.0 sh training/train.sh
```

See the logs:
```
docker logs -f kr
```

Development
===========

Virtual Environment
-------------------
This project uses [pip Virtual Environment].

Create a virtual environment located in the `venv/` folder:
```commandline
python -m venv venv
``` 

To activate the virtual environment: 
```commandline
source venv/bin/activate
```

To leave the virtual environment:
```commandline
deactivate
```

Environment Setup
-----------------
Install *keras-retinanet*:
```commandline
git clone https://github.com/fizyr/keras-retinanet.git
cd keras-retinanet
pip install .
python setup.py build_ext --inplace
```

Install project dependencies:
```commandline
pip install pandas
pip install cython
pip install matplotlib
pip install progressbar2
```

```commandline
wget -P resources https://github.com/fizyr/keras-retinanet/releases/download/0.5.1/resnet50_coco_best_v2.1.0.h5
mv resources/resnet50_coco_best_v2.1.0.h5 resources/pretrained_model.h5

wget -P resources 'https://drive.google.com/uc?export=download&id=1YgTANSod7X5Yf-3YvsrbJPSwvESxq2b2'
mv resources/uc\?export\=download\&id\=1YgTANSod7X5Yf-3YvsrbJPSwvESxq2b2 resources/goat_dataset.zip
unzip -d resources/dataset resources/goat_dataset.zip 
```

Start Training
==============

```commandline
./keras-retinanet/keras_retinanet/bin/train.py \
    --freeze-backbone --random-transform --weights ./resources/pretrained_model.h5 \
    --batch-size 8 --steps 500 --epochs 10 \
    csv annotations.csv classes.csv
```

```commandline
./keras-retinanet/keras_retinanet/bin/train.py \
    --freeze-backbone --random-transform --weights ./resources/pretrained_model.h5 \
    --batch-size 1 --steps 1 --epochs 1 \
    --tensorboard-dir tensorboard \
    csv annotations.csv classes.csv --val-annotations val_annotations.csv
```

[pip Virtual Environment]: https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/
