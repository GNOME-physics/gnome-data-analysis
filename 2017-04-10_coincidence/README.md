# Scripts for coincidence analysis

## Description

I am gathering here some scripts shared by Chris to perform coincidence analysis.

## Getting Started

### Prerequisites

Almost all the modules were installed through the Python package manager pip,
with the exceptions of the lal and lalburst packages which were installed via
Macports. The scripts present in this repository work properly with the version
of each package:

- `python 2.7.13`
- `numpy 1.12.1`
- `scipy 0.18.0`
- `pycbc-glue 1.0.1`
- `pycbc-pylal 1.0.1`
- `lal 6.18.0`
- `lalburst 1.4.4`
- `pycbc 1.6.8`
- `h5py 2.6.0`
- `gwpy 0.1`
- `astropy 1.3.2`
- `matplotlib 2.0.0`

### Module issue

#### pylal.llwapp.set_process_end_time

We note that in the original `ligolw_tisi` executable, the `llwapp` module no longer exists from the most recent `pylal` package. However, the `set_process_end_time` sub-module that is needed in that script can be found in the `glue.ligolw.utils.process` module.

### pylal.ligolw_tisi

#### pylal.ligolw_tisi.time_slides_vacuum

The `ligolw_tisi` module is no longer present in `pylal`. However, the `time_slides_vacuum` sub-module needed in this work can be found under the `glue.ligolw.utils.time_slide` module.

### Other required pylal.ligolw_tisi modules

In the `ligolw_tisi` executable, we found several more modules required from the `ligolw_tisi` package that are no longer available. In order to make this script running, we downloaded the original `ligolw_tisi.py` module from [here](https://gitlab.aei.uni-hannover.de/brevilo/lalsuite/blob/162ee1be3489a1f849bf5fc82b2a919e1b91e139/pylal/pylal/ligolw_tisi.py) and import this one instead in the script.
