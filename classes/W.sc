/*
Workspace
*/
W : Environment {

    var <>daw;

    *transport {|clock|
        U(\transport, clock);
    }

    *recdir {
        var path = Document.current.dir;
        thisProcess.platform.recordingsDir_(path.debug(\recdir));
    }

    *mixer {
        var m = NdefMixer(Server.default);
        ProxyMeter.addMixer(m);
        m.switchSize(0);
        ^m;
    }

    record {
        if (daw == \bitwig) {
            Bitwig.record;
        };
        if (daw == \reaper) {
            Reaper.record
        }
    }

    stopRecording {
        if (daw == \bitwig) {
            Bitwig.stop;
        };
        if (daw == \reaper) {
            Reaper.stopRecording;
        }
    }

    tempo {|bps=1|
        if (daw == \bitwig) {
            Bitwig.tempo(bps)
        };
        if (daw == \reaper) {
            Reaper.tempo(bps)
        }
    }

    time {|val=0|
        if (daw == \bitwig) {
            Bitwig.time(val)
        };
        if (daw == \reaper) {
            Reaper.time(val);
        }
    }
}