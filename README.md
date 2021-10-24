# aspycgal
aspycgal is a Python Package a convenient wrapper on the cgal library, primarily for computing polyhedra and their properties.
Current Version: 0.0.1

## Dependencies

CGAL, Cython, Numpy

## Install & Setup

aspycgal is now a python package and can be installed using pip directly:
```bash
$ pip install git+https://github.com/akcelita/aspycgal.git
```

To contribute you may need to run:
```bash
$ pip install -r requirements.txt
```
## Usage

There are several python scripts in the main repository, among them munkres_sample.py. They show basic usage with Artificial Sensing infrastructure. But the most important steps are:

```python
import cv2
from aspycgal import Tracker

tracker = Tracker()
video = "file.avi"
c = cv2.VideoCapture(video)

################# Iterate over video or stream ################################
while True:
	_,image = c.read()
    contours, hierarchy = cv2.findContours(image, cv2.RETR_LIST,
                                           cv2.CHAIN_APPROX_SIMPLE)

################## Find contours and their centroids ##########################
    frame_targets = []
    for cnt in contours:
        try:
            x, y, w, h = cv2.boundingRect(cnt)
            cv2.rectangle(color_image, (x, y), (x+w, y+h), (255, 0, 0), 2)

            moments = cv2.moments(cnt)
            x = int(moments['m10'] / moments['m00'])
            y = int(moments['m01'] / moments['m00'])

            frame_targets.append((x, y))
        except:
            print("Bad Rectangle.")

################## Track the centroids ########################################

    if len(frame_targets) > 0:
        tracker.track_targets(frame_targets, [0, 0, 640, 480])

```


## Testing

To run tests, use `pytest`:

```sh
python -m pytest
```

If you don't have `pytest` installed, then just install it:

```sh
pip install pytest
```

Some tests require [test data files](https://akcelita-aspycgal.s3.amazonaws.com/aspycgal/tests/test_data.tar.gz), which you can download and untar:

```sh
wget https://akcelita-aspycgal.s3.amazonaws.com/aspycgal/tests/test_data.tar.gz
tar -xzf test_data.tar.gz
```

## CYTHON

To run profiler for Cython files

cd into `~/aspycgal/cythonmodules/`

```sh
cython -a [file_name].pyx
```

Full command to compile cython files and run aspycgal

```sh
python setup.py build_ext --inplace && [run command]
```



## Samples
Some samples require [sample data files](https://akcelita-aspycgal.s3.amazonaws.com/aspycgal/samples/sample_data.tar.gz), which you can download and untar:

```sh
wget https://akcelita-aspycgal.s3.amazonaws.com/aspycgal/samples/sample_data.tar.gz
tar -xzf sample_data.tar.gz
```
