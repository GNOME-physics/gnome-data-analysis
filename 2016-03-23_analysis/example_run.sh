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
