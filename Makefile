
# `LIGO style' detector prefix --- arbitrary and probably should be changed 
# because there will eventually be a K1 interferometer. For reference:
# K1 -- Krakow
# B1 -- Berkeley
detector="K1"
# Input sampling rate
in_rate=1000
# Output sampling rate
out_rate=1024
# Duration of an individual frame file (see output format below)
output_stride=120
# Arbitary GPS timestamp for data to start at
gps_start=1000000000

#
# A note on channel names: Both the `open' and `shorten' data sets have four 
# columns of data corresponding to four different channels. The first two are
# partially shielded and the second are fully shielded. The names provided here
# are purely ad-hoc to be more descriptive and keep track of the individual time
# series as they are recorded in the frames. We should decide on (a possibly
# better) naming convention if this is not descriptive enough or totally
# inappropriate.
#

PSDS=K1-K1_MAG-PART_SHIELD_CHAN2_REF_PSD.xml.gz K1-K1_MAG-PART_SHIELD_CHAN1_REF_PSD.xml.gz K1-K1_MAG-FULL_SHIELD_CHAN2_REF_PSD.xml.gz K1-K1_MAG-FULL_SHIELD_CHAN1_REF_PSD.xml.gz

#
# Preliminaries -- unpack the data if provided in tarball form
#
shorten:
	gunzip shorten.tgz

open:
	gunzip open.tgz

#
# Power spectra density (PSD) estimations for each channel and plotting them all
# together
#
plot_psds: ${PSDS}
	./plot_psds_single ${detector} ${PSDS}

K1-K1_MAG-PART_SHIELD_CHAN1_REF_PSD.xml.gz: open_frames_resampled.cache
	gstlal_reference_psd  \
        --data-source frames \
        --frame-cache $< \
        --channel-name K1=MAG-PART_SHIELD_CHAN1 \
        --gps-start-time 1000000000 \
        --gps-end-time 1000005880 \
        --sample-rate 1024 \
        --write-psd $@ \
        --verbose

K1-K1_MAG-PART_SHIELD_CHAN2_REF_PSD.xml.gz: open_frames_resampled.cache
	gstlal_reference_psd  \
        --data-source frames \
        --frame-cache $< \
        --channel-name K1=MAG-PART_SHIELD_CHAN2 \
        --gps-start-time 1000000000 \
        --gps-end-time 1000005880 \
        --sample-rate 1024 \
        --write-psd $@ \
        --verbose

K1-K1_MAG-FULL_SHIELD_CHAN1_REF_PSD.xml.gz: open_frames_resampled.cache
	gstlal_reference_psd  \
        --data-source frames \
        --frame-cache $< \
        --channel-name K1=MAG-FULL_SHIELD_CHAN1 \
        --gps-start-time 1000000000 \
        --gps-end-time 1000005880 \
        --sample-rate 1024 \
        --write-psd $@ \
        --verbose

K1-K1_MAG-FULL_SHIELD_CHAN2_REF_PSD.xml.gz: open_frames_resampled.cache
	gstlal_reference_psd  \
        --data-source frames \
        --frame-cache $< \
        --channel-name K1=MAG-FULL_SHIELD_CHAN2 \
        --gps-start-time 1000000000 \
        --gps-end-time 1000005880 \
        --sample-rate 1024 \
        --write-psd $@ \
        --verbose

#
# These rules explicitly converts the ASCII formatted data to 'gwf' formatted 
# data. More information on the gwf format can be found at
# https://dcc.ligo.org/LIGO-T970130/public
#
# The short story is that these are just binary containers for things like time
# series and other data --- LIGO rarely uses them for any thing but time series
#
# Implicitly: this also upsamples the data to the closest power of two, but this
# is controllable through the "out_rate" variable
#
open_frames_resampled.cache:
	./makeframes -d $(detector) -i $(in_rate) -o $(out_rate) -c MAG-PART_SHIELD_CHAN1=1 -c MAG-PART_SHIELD_CHAN2=2 -c MAG-FULL_SHIELD_CHAN1=3 -c MAG-FULL_SHIELD_CHAN2=4 -s $(output_stride) -S $(gps_start) open/open*.txt
	mkdir -p open_frames_resampled/
	mv *.gwf open_frames_resampled/
	find open_frames_resampled -name "*gwf" | lalapps_path2cache > open_frames_resampled.cache

shorten_frames_resampled.cache:
	./makeframes -d $(detector) -i $(in_rate) -o $(out_rate) -c MAG-PART_SHIELD_CHAN1=1 -c MAG-PART_SHIELD_CHAN2=2 -c MAG-FULL_SHIELD_CHAN1=3 -c MAG-FULL_SHIELD_CHAN2=4 -s $(output_stride) -S $(gps_start) shorten/shorten*.txt
	mkdir -p shorten_frames_resampled/
	mv *.gwf shorten_frames_resampled/
	find shorten_frames_resampled -name "*gwf" | lalapps_path2cache > shorten_frames_resampled.cache

#
# Plot the time series data we just made
#
open_frames_resampled.png: open_frames_resampled.cache
	./plot_ts $<

shorten_frames_resampled.png: shorten_frames_resampled.cache
	./plot_ts $<
