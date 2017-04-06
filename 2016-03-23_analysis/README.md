# Data Analysis scripts for March 23rd 2016 run

## Description

This repository contains some tools to do excess-power analysis on the first
all stations run from March 23rd, 2016. 

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
- `lal 6.18.0`
- `lalburst 1.4.4`
- `pycbc 1.6.8`
- `h5py 2.6.0`
- `gwpy 0.1`
- `astropy 1.3.2`
- `matplotlib 2.0.0`

### Module issues

#### scipy.weave

We note that the Scipy v0.19.0 released in early March 2017 is not compatible
with the some of the LIGO modules used when the scripts were written. In
particular, the now deprecated scipy.weave library has been removed. This
library is used by the pycbc package.

#### gwpy.plotter.SpectrumPlot

Version newer than 0.1 of the `gwpy` package do not have the `SpectrumPlot`
package required to run properly the `plot_spectrogram` script. If one
wants to run the analysis scripts here, one needs to use gwpy-0.1.

#### glue.ligolw.table.CompareTableNames

If you installed the `glue` package via Macports, that version will not work
with the scripts here as the `CompareTableNames` module does not exist on this
version. You will therefore be prompt an ImportError message telling you that
the module cannot be imported. Instead, install the `pycbc-glue` package from
pip.

## Getting running

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
