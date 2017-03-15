from glue.segments import segment
from gwpy.timeseries import TimeSeries
#from pycbc.types import TimeSeries
#
# GNOME specific data retrieval
#

#ts_data = strain.from_cli(args, precision='double', dyn_range_fac=DYN_RANGE_FAC)

def construct_utc_from_metadata(datestr, t0str):
    instr = "%d-%d-%02dT" % tuple(map(int, datestr.split('/')))
    instr += t0str
    from astropy import time
    t = time.Time(instr, format='isot', scale='utc')
    return t.gps

import datetime
import h5py
def retrieve_data_timeseries(hfile, setname):
    dset = hfile[setname]
    sample_rate = dset.attrs["SamplingRate(Hz)"]
    gps_epoch = construct_utc_from_metadata(dset.attrs["Date"], dset.attrs["t0"])
    data = retrieve_channel_data(hfile, setname)
    ts_data = TimeSeries(data, sample_rate=sample_rate, epoch=gps_epoch)
    #ts_data = TimeSeries(data, delta_t=1.0/sample_rate, epoch=gps_epoch)
    return ts_data

def retrieve_channel_data(hfile, setname):
    return hfile[setname][:]

def _file_to_segment(hfile, segname="MagneticFields"):
    attrs = hfile[segname].attrs
    dstr, t0, t1 = attrs["Date"], attrs["t0"], attrs["t1"]
    return segment(construct_utc_from_metadata(dstr, t0), construct_utc_from_metadata(dstr, t1))

if False:
    #fname = "data/GNOMEDrive/gnome/serverdata/berkeley01/2016/03/23/berkeley01_20160323_000008.hdf5"
    import glob
    data_order = {}
    for fname in glob.glob("data/GNOMEDrive/gnome/serverdata/berkeley01/2016/03/23/berkeley01_20160323_*.hdf5"):
        hfile = h5py.File(fname, "r")
        data_order[_file_to_segment(hfile)] = hfile

    seglist = segmentlist(data_order.keys())
    seglist.sort()
    #print type(seglist), seglist

    # This is just to get metadata
    setname = "MagneticFields"
    ts_data = retrieve_data_timeseries(hfile, setname)
    print ts_data.delta_t, ts_data.start_time

    full_data = numpy.hstack([retrieve_channel_data(data_order[seg], "MagneticFields") for seg in seglist])
    # Zero pad. :(
    zpad = math.ceil(math.log(len(full_data)*ts_data.delta_t, 2))
    zpad = int(2**zpad) - len(full_data)*ts_data.delta_t
    zpad = numpy.zeros(int(zpad/ts_data.delta_t / 2.0))
    full_data = numpy.hstack((zpad, full_data, zpad))
    ts_data = types.TimeSeries(full_data, ts_data.delta_t, epoch=seglist[0][0])

    print ts_data

    for v in data_order.values():
        v.close()
    del data_order
