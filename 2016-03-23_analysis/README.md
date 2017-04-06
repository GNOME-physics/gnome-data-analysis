# Data Analysis scripts for March 23rd 2016 run

## Description

This repository contains some tools to do excess-power analysis on the first
all stations run from March 23rd, 2016. 

## Getting Started

### Prerequisites

The program is working with the following packages:

- `python 2.7.13`
- `numpy 1.12.1`
- `scipy 0.18.0`
- `glue 1.54.1`
- `lal 6.18.0`
- `lalburst 1.4.4`
- `pycbc 1.6.8`
- `h5py 2.6.0`
- `gwpy 0.4`
- `astropy 1.3.2`
- `matplotlib 2.0.0`

We note that the Scipy v0.19.0 released in early March 2017 is not compatible
with the some of the LIGO modules used when the scripts were written. In
particular, the now deprecated scipy.weave library has been removed. This
library is used by the pycbc package.

### Running the program

The `pyburst_excesspower_gnome` script can be run along with specific arguments
to specific the characteristics of the tiles we want to study. For instance,
we can run the following:

	./pyburst_excesspower_gnome \
		--verbose \
		--sample-rate 1000 \
		--channels 1023 \
		--channel-name H1:FAKE-STRAIN \
		--gps-start-time 0 \
		--gps-end-time 1 \
		--min-frequency 0 \
		--max-frequency 500 \
		--psd-segment-stride 32 \
		--psd-segment-length 64 \
		--psd-estimation median-mean \
		--pad-data 4 \

The above command along with all the option is already included in the shell script
`example_run.sh` as followws:

	sh example_run.sh
