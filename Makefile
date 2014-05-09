
detector="K1"
in_rate=1000
out_rate=1024
output_stride=120
gps_start=1000000000

open_frames_resampled.cache:
	#./makeframes -d $(detector) -i $(in_rate) -o $(out_rate) -c MAG-PART_SHIELD_CHAN1=1 -c MAG-PART_SHIELD_CHAN2=2 -c MAG-FULL_SHIELD_CHAN1=3 -c MAG-FULL_SHIELD_CHAN2=4 -s $(output_stride) -S $(gps_start) open/open*.txt
	mkdir -p open_frames_resampled/
	mv *.gwf open_frames_resampled/
	find open_frames_resampled -name "*gwf" | lalapps_path2cache > open_frames_resampled.cache
