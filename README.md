# Yolov7 + StrongSORT with OSNet





<div align="center">
<p>
<img src="MOT16_eval/track_pedestrians.gif" width="400"/> <img src="MOT16_eval/track_all.gif" width="400"/> 
</p>
<br>
<div>
<a href="https://github.com/mikel-brostrom/Yolov7_DeepSort_Pytorch/actions"><img src="[https://github.com/mikel-brostrom/Yolov7_DeepSort_Pytorch/workflows/CI%20CPU%20testing/badge.svg](https://github.com/mikel-brostrom/Yolov7_StrongSORT_OSNet/actions/workflows/ci-testing.yml/badge.svg?branch=main)" alt="CI CPU testing"></a>
<br>  
<a href="https://colab.research.google.com/drive/18nIqkBr68TkK8dHdarxTco6svHUJGggY?usp=sharing"><img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"></a>
 
 [![CI CPU testing](https://github.com/mikel-brostrom/Yolov7_StrongSORT_OSNet/actions/workflows/ci-testing.yml/badge.svg?branch=main)](https://github.com/mikel-brostrom/Yolov7_StrongSORT_OSNet/actions/workflows/ci-testing.yml)
 
</div>

</div>


## Introduction

This repository contains a highly configurable two-stage-tracker that adjusts to different deployment scenarios. The detections generated by [YOLOv7](https://github.com/WongKinYiu/yolov7), a family of object detection architectures and models pretrained on the COCO dataset, are passed to [StrongSORT](https://github.com/dyhBUPT/StrongSORT)[](https://arxiv.org/pdf/2202.13514.pdf) which combines motion and appearance information based on [OSNet](https://github.com/KaiyangZhou/deep-person-reid)[](https://arxiv.org/abs/1905.00953) in order to tracks the objects. It can track any object that your Yolov7 model was trained to detect.

## Before you run the tracker

1. Clone the repository recursively:

`git clone --recurse-submodules https://github.com/mikel-brostrom/Yolov7_StrongSORT_OSNet.git`

If you already cloned and forgot to use `--recurse-submodules` you can run `git submodule update --init`

2. Make sure that you fulfill all the requirements: Python 3.8 or later with all [requirements.txt](https://github.com/mikel-brostrom/Yolov7_DeepSort_Pytorch/blob/master/requirements.txt) dependencies installed, including torch>=1.7. To install, run:

`pip install -r requirements.txt`


## Tracking sources

Tracking can be run on most video formats

```bash
$ python track.py --source 0  # webcam
                           img.jpg  # image
                           vid.mp4  # video
                           path/  # directory
                           path/*.jpg  # glob
                           'https://youtu.be/Zgi9g1ksQHc'  # YouTube
                           'rtsp://example.com/media.mp4'  # RTSP, RTMP, HTTP stream
```


## Select object detection and ReID model

### Yolov7

There is a clear trade-off between model inference speed and accuracy. In order to make it possible to fulfill your inference speed/accuracy needs
you can select a Yolov7 family model for automatic download

```bash


$ python track.py --source 0 --yolo-weights yolov7.pt --img 640
                                            yolov7x.pt --img 640
                                            yolov7-e6e.pt --img 1280
                                            ...
```

### StrongSORT

The above applies to StrongSORT models as well. Choose a ReID model based on your needs from this ReID [model zoo](https://kaiyangzhou.github.io/deep-person-reid/MODEL_ZOO)

```bash


$ python track.py --source 0 --strong-sort-weights osnet_x0_25_market1501.pt
                                                   osnet_x0_5_market1501.pt
                                                   osnet_x0_75_msmt17.pt
                                                   osnet_x1_0_msmt17.pt
                                                   ...
```


## Filter tracked classes

By default the tracker tracks all MS COCO classes.

If you want to track a subset of the MS COCO classes, add their corresponding index after the classes flag

```bash
python track.py --source 0 --yolo-weights yolov7.pt --classes 16 17  # tracks cats and dogs, only
```

[Here](https://tech.amikelive.com/node-718/what-object-categories-labels-are-in-coco-dataset/) is a list of all the possible objects that a Yolov7 model trained on MS COCO can detect. Notice that the indexing for the classes in this repo starts at zero.


## MOT compliant results

Can be saved to your experiment folder `runs/track/<yolo_model>_<deep_sort_model>/` by 

```bash
python track.py --source ... --save-txt
```


## Cite

If you find this project useful in your research, please consider cite:

```latex
@misc{yolov7-strongsort-osnet-2022,
    title={Real-time multi-camera multi-object tracker using YOLOv7 and StrongSORT with OSNet},
    author={Mikel Broström},
    howpublished = {\url{https://github.com/mikel-brostrom/Yolov7_StrongSORT_OSNet}},
    year={2022}
}
```

## Contact 

For Yolov7 DeepSort OSNet bugs and feature requests please visit [GitHub Issues](https://github.com/mikel-brostrom/Yolov7_StrongSORT_OSNet/issues). For business inquiries or professional support requests please send an email to: yolov5.deepsort.pytorch@gmail.com
