# Gnome Magnetometer Analysis 8/16/2014

Notes:

  * All channels are sampled at (I think) a rate of 1000 Hz. I have resampled them up to 1024 Hz for ease of use with existing tools. This has introduced some high frequency 'fuzz'. The resampler I'm using (from scipy) probably doesn't have a well tuned low pass filter to avoid aliasing. I'm ignoring this for now unless it becomes a big problem down the road.
  * Since I don't know the timestamps of the data samples, All data sets have been assigned (arbitrarily) the GPS time 1000000000. If there are timestamps available, let me know and I'll adjust the analysis accordingly.
  * LIGO's channels are generally denoted with `[site][ifo_number]:subsystem_prefix-channel_name`. So as to play nicely with LIGO's analysis software, I've assigned Krakow the site (K) and 'ifo number' 1. Berkeley (should it be needed again) will be B1. Since the magnetometer is not as complex as an interferometer, it only has one 'subsystem' which I've designated as 'MAG'.
  * Channels have been assigned somewhat arbitrary names (this is going off what I recall from the previous analysis):
    1. Column 1: `K1:MAG-FULL_SHIELD_CHAN1`
    1. Column 2: `K1:MAG-FULL_SHIELD_CHAN2`
    1. Column 3: `K1:MAG-PART_SHIELD_CHAN1`
    1. Column 4: `K1:MAG-PART_SHIELD_CHAN2`
  * The Makefile is also well commented with conventions and explanations for names and the like, so I'm limiting discussion here to the finer points of the analysis.

Software packages required:

  * numpy/scipy -- python based numerical and scientific analysis package
  * matplotlib -- extensive python based plotting library, integrates with numpy/scipy
  * lalsuite -- LAL: LSC Algorithm Library, see (https://www.lsc-group.phys.uwm.edu/daswg/projects/lalsuite.html)
  * pylal -- Python wrappings of LAL, see (https://www.lsc-group.phys.uwm.edu/daswg/projects/pylal.html)
  * glue -- glue: Grid LSC User Environment, see (https://www.lsc-group.phys.uwm.edu/daswg/projects/glue.html)
  * gstlal -- gstlal: gstreamer + LAL, core analysis library, see (https://www.lsc-group.phys.uwm.edu/daswg/projects/gstlal.html)
  * gstlal-ugly -- unstable gstlal analysis libraries, see (https://www.lsc-group.phys.uwm.edu/daswg/projects/gstlal.html)

For most Linux based package managers, installing gstlal-ugly will pull in everything else, since it is dependent on the remaining items in the list.

## Time Series

The original input is eight sets of data, labelled 'open' and 'shorten'. Each data set is taken at four different gain voltages: 1.25 V, 2.5 V, 5 V, and 10V. One set's last text file is empty, so it's slightly shorter than the others. The structure I set up is as follows:

```
open/
├── v10
│   ├── open\ Sensitivity10V\ Index\ 1.txt
│   ├── open\ Sensitivity10V\ Index\ 10.txt
    ...
│   ├── open\ Sensitivity10V\ Index\ 8.txt
│   └── open\ Sensitivity10V\ Index\ 9.txt
├── v1p25
│   ├── open\ Sensitivity1_25V\ Index\ 1.txt
│   ├── open\ Sensitivity1_25V\ Index\ 10.txt
    ...
│   ├── open\ Sensitivity1_25V\ Index\ 8.txt
│   └── open\ Sensitivity1_25V\ Index\ 9.txt
├── v2p5
│   ├── open\ Sensitivity2_5V\ Index\ 10.txt
│   ├── open\ Sensitivity2_5V\ Index\ 11.txt
    ...
│   ├── open\ Sensitivity2_5V\ Index\ 8.txt
│   └── open\ Sensitivity2_5V\ Index\ 9.txt
└── v5
    ├── open\ Sensitivity5V\ Index\ 1.txt
    ├── open\ Sensitivity5V\ Index\ 10.txt
    ...
    ├── open\ Sensitivity5V\ Index\ 8.txt
    └── open\ Sensitivity5V\ Index\ 9.txt
```

The common data format for LIGO analyses are frames. See the Makefile for more details. The program `makeframes` will do this for you. See example usage in the Makefile. The upshot is that the set of data/voltage is converted into a set of frames, each frame containing 120 seconds of each of the 4 channels.

```
open_frames_resampled
└── open
    ├── v10
    │   ├── K-K1_TEST_MAG-1000000000-120.gwf
    │   ├── K-K1_TEST_MAG-1000000120-120.gwf
    │   ├── K-K1_TEST_MAG-1000000240-120.gwf
    │   ├── K-K1_TEST_MAG-1000000360-120.gwf
    │   ├── K-K1_TEST_MAG-1000000480-120.gwf
    ...

$ FrChannels open_frames_resampled/open/v10/K-K1_TEST_MAG-1000000000-120.gwf
K1:MAG-FULL_SHIELD_CHAN2 1024
K1:MAG-PART_SHIELD_CHAN1 1024
K1:MAG-PART_SHIELD_CHAN2 1024
K1:MAG-FULL_SHIELD_CHAN1 1024
```

There are plots of each of the data sets (`make all_ts_plots`):
Naming comvention: {dataset}_{gain_voltage}_frames_resampled.png

Each plot has each of the four channels plotted.

## Power Spectral Densities

See `make K1-K1_MAG_*-PART_SHIELD_CHAN1_OPEN_REF_PSD.xml.gz` and others for examples.

The power spectral density is measured by the [gstlal_reference_psd](https://ligo-vcs.phys.uwm.edu/cgit/gstlal/tree/gstlal/bin/gstlal_reference_psd) program. It uses a mean-median estimator. They are saved in an XML format so that they can be digested easier by downstream programs. If a text file is needed try:

```bash
ligolw_print -a K1 K1-K1_MAG_v10-FULL_SHIELD_CHAN1_OPEN_REF_PSD.xml.gz -d " "
```

NOTE: the ligolw_print program is installed as part of glue.

There are plots of each of the data sets (`make K1-K1_MAG_*-PART_SHIELD_CHAN1_OPEN_REF_PSD.png` and friends), with each of the four voltages for one channel plotted in one figure. They are named K1-K1_MAG-{FULL,PART}_CHAN{1,2}_{OPEN,SHORTEN}_REF_PSD.png.

Most sets have some fairly sharp power line resonances (mostly taken care of by the PSD estimation). Two which don't are FULL_SHIELD_CHAN{1,2} in the shorten set, though a little disruption can be seen at harmonics (100 Hz?).

## Time-frequency Analysis and Trigger Generation

The `gstlal_excesspower` program is used to generate time-frequency maps and trigger sets from the analysis channel. Each channel is analyzed independently (see MAG_%_PART_SHIELD_CHAN2_open and friends Makefile rules). An invocation of `gstlal_excesspower` looks something like this:

```bash
    gstlal_excesspower  \
        --data-source frames \
        --frame-cache open_v10_frames_resampled.cache \
        --channel-name K1=MAG-PART_SHIELD_CHAN1 \
        --sample-rate 1024 \
        --initialization-file gnome_test_open_v10.ini \
        --gps-start-time 1000000000 \
        --gps-end-time 1000003600 \
        --verbose
```

The two non-obvious options here correspond to the input data source (the frames we just created), and the initialization file (part of the git repository) tells the analysis what bandwidths and durations to analyze, basically.

The triggers generated by these programs are distributed as follows:

```
shorten_triggers
├── v10
│   └── K1
│       ├── MAG-FULL_SHIELD_CHAN1_excesspower
│       │   └── 10000
│       │       ├── K1-MAG_FULL_SHIELD_CHAN1_excesspower-1000000000-600.xml.gz
│       │       ├── K1-MAG_FULL_SHIELD_CHAN1_excesspower-1000000600-600.xml.gz
│       │       ├── K1-MAG_FULL_SHIELD_CHAN1_excesspower-1000001200-600.xml.gz
│       │       ├── K1-MAG_FULL_SHIELD_CHAN1_excesspower-1000001800-600.xml.gz
│       │       ├── K1-MAG_FULL_SHIELD_CHAN1_excesspower-1000002400-600.xml.gz
│       │       └── K1-MAG_FULL_SHIELD_CHAN1_excesspower-1000003000-595.xml.gz
```

These are the 'raw' tiles, the direct output of the analysis. They are in the same XML format as the PSDs (roughly), and infomration can be accessed:

```
ligolw_print -t sngl_burst -c peak_time -c peak_time_ns, -c duration -c central_freq -c bandwidth -c snr shorten_triggers/v10/K1/MAG-FULL_SHIELD_CHAN1_excesspower/10000/ K1-MAG_FULL_SHIELD_CHAN1_excesspower-1000000000-600.xml.gz
```

for example.

### Clustering

The final product of the single channel analysis, however, clusters these tiles together into triggers. I perform the clustering as an intermediate step on the way to adding together all the files from one channel's analysis (see, for example `make open_triggers_clustered.cache`).

Plots of each of the clustered channel's triggers are available as K-ALL_TRIGGERS_COINC_{SHORTEN,OPEN}_{voltage}.png. Each of the four channels is on a single figure for comparison.

NOTE: There's a typo on these plots. It says 'Tile Energy' on the color axis, but that should actually read 'Tile SNR'. It's the difference of the square root (SNR is normalized amplitude).

In general:
  * Higher voltage gains are cleaner, as one might expect.
  * Lower voltage gains allow more power from the power lines to bleed into the surrounding bandwidth, causing several sets of triggers in the region.
  * One set (K-ALL_TRIGGERS_COINC_SHROTEN_v1p25) is particularly troublesome. It's a bit counterintuitive, but it can be understood better in the mode I've engaged the analysis.
    * The default for the analysis is to use a whitener which keeps a running history of the PSDs its estimated. While the method is quite robust, if the spectrum difts appreciably over the span of a minute or so, then the estimator will begin to adapt to it.
    * The instrument in this case looks like it 'dropped out' for a period of a minute or two. When this happened, the PSD in the history was still using the nominal one, so it appears to have a 'gap'.
    * After a minute or so, the PSD returned to normal, but the algorithm had already adapted to the 'new' spectrum, so now it looks to the analysis like a high broadband noise period and the glitchiness kicks up.
    * Then the analysis readapts to the nominal spectrum and all is well again.
    * This effect has a periodicity of about 10 minutes. It's difficult to tell, but there appears to be some effect (though not as prominent) in the other channels. In particular, K1:MAG-FULL_PART_SHIELD_CHAN1 seems to go haywire __during__ the second (since the data stretch seems to __start__ on a gap) gap.
    * Most of the other trigger sets are either fairly clean or have triggers which are mostly related to variations from the power line(s).

## Coincidence Analysis

Please take note. Most of these tools have been lying around for some time (long story) and many have been affected by bit rot. It took some time and __a lot_ of hacking to get them to work at all, and even more hacking to get them to work with the 'non-standard' set of data.

The coincidence analysis proceeds by checking whether or not a trigger's time-frequency extent consistent (to within light-travel time) with a trigger in another channel. This is the 'zero-lag'/foreground/on-source analysis. In LIGO speak, it's the check for whether a signal is coincident between instruments.

The 'time-lagged'/background/off-source analysis proceeds by taking each channel and shifting it in time by a amount, and redoing the coincidennce. Since we shift past the light-travel time of a signal between two instruments, these coincidences are certainly spurious and we use this to measure our false coincidence rate. The more slides one can do, the better the estimation of the background.

Most LIGO searches involve two or three instruments; there is only a very small segment of time when four instruments were operational, and two of them were at the same site and thus were never slid relative to each other. So, to my knowledge, a four instrument coincidence analysis --- while certainly possible -- has never been done. The computational scaling of coincidence algorithm scales as the __exponent__ of the number of channels analyzed, so as one could imagine, this would get tricky quickly.

I tried a number of configurations for the coincidence, including a test with sliding all four around. It worked, but was not incredibly illuminating. Interpreting it would have been complicated, so I opted instead to do a little more extensive analysis with a smaller set of slides. I still use all four channels for any given dataset, but I only allow the first two channels to slide. The time offset (in multiples of 1 second intervals) for slides is:

    * K1:MAG-FULL_SHIELD_CHAN1: `-5 < \delta t < 5`
    * K1:MAG-FULL_SHIELD_CHAN2: `-5 < \delta t < 5`
    * K1:MAG-PART_SHIELD_CHAN1: no slide
    * K1:MAG-PART_SHIELD_CHAN2: no slide

The combinatorics are not always easy to visualize, I suggest drawing a picture. So this is a four instrument "network" where 'background' corresponds to any set of offsets where `|\delta t| > 0`, and "foreground" is the unique set where all offsets are zero (no sliding is done).

The coincidence algorthm used is `ligolw_burca`, see the Makefile for details. I've run the result through a program designed to visualize the output. The plots here can be very hard to interpret, so I'll try my best to outline their functionality (if any). Each dataset/gain voltage has its own coincidence analysis (Makefile targets not yet added). You'll notice that they use a sqlite database. This is a design decision for efficiency in plotting and result archival.

Each set has plot number (the last number in gnome_{set}_{voltage}_##.png). They are as follows:

*00*: Coincidence rate between channel 1 and 2. This is the only one of this subset that has any real information, because these are the only two channels being slid. Forgreound is in the middle of the plot, with successive offsets radiating in either direction. I don't think enough slides have been done here to produce an informative plot, so I'm working on making one that will be more illuminating.
*01-05*: Same as above, but for the other channel combinations. Channels 3 and 4 are not slid, so they become degenerate in the plots.
*06*: Channel 1 confidence vs channel 2 confidence: Confidence is a measure of the statistical significance of obtaining a given tile in the present of Gaussian noise. Higher confidences correspond to lower probability of the tile being produced by Gaussian noise. This attempts a density with the foreground (red) plotted over the background (black). I think it suffers from low number statistics. I'll attempt a simpler plot later.
*06-08*: As above for other combinations.
*09*: Same as 06, but using the accumulated SNR of a trigger rather than the confidence. Ignore the denominator in the axis labels. F_+ and F_x are the interferometer antenna patterns, and they indicate the geometric sensitvity of the instrument. Since magnetometers do not have the same directional sensitivity, these factors have been set to unity within the hacked version of the code.
*10-11*: As above for other combinations.
*12*: Ignore this plot. I think I understand it, but I've not yet made it relevant for our case.
*13-16*: Probably the easiest to understand, and the one most relevant to the question at hand. This is a cumulative coincidence rate versus signal confidence plot. The foreground is red and background is black. It is plotted for each channel, so the confidence reported on the y-axis is the confidence *for that channel's trigger which participated in the coincidence*. The 'tail' in many cases is a tile with both a high SNR and large extent on the time-frequency plane. The high SNR/confidence pushes it to the tail of the distribution, and hence its cumulant. The large extent allows it to participate in many coincidences (you can think of it as having a high cross-section), and hence the 'drops' in the tail. If you get too many of these, the effect is obvious: many high cross-section, high SNR coincidences which extend into a *long* tail. This is what kills search sensitivity in LIGO: unexplained and unremovable background which mimics a signal.

  * The foreground is generally consistent with the background (the red follows the black closely). A 'signal' would case the red curve to deviate to the right from the black curve near the tail: a high SNR/confidence event which is not consistent with the background distribution.
  * The best way to understand search sensitivity to background is to flip between the high to low voltage coincidence cases for each set, notice how the curves (especially the tail locations and density) change. In this case, no data set is particularly 'clean', but we've made no attempt at data quality vetoing or tuning the search parameters, and I suspect things like the high frequency 'fuzz' are containminating this.
