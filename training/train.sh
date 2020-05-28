rm -rf training/tensorboard
mkdir training/tensorboard

python training/scripts/pascal_xml_to_csv.py -i training/images/train -o training/images/train_labels.csv -p train
python training/scripts/pascal_xml_to_csv.py -i training/images/validation -o training/images/validation_labels.csv -p validation

python ../keras-retinanet/keras_retinanet/bin/train.py \
    --freeze-backbone \
    --random-transform \
    --batch-size 1 \
    --steps 50 \
    --epochs 1 \
    --weights training/pre-trained-model/resnet50_coco_best_v2.1.0.h5 \
    --tensorboard-dir training/tensorboard \
    csv training/images/train_labels.csv training/images/labels.csv --val-annotations training/images/validation_labels.csv
