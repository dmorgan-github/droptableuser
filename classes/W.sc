/*
Workspace
*/
W : Environment {

    var <>daw;

    classvar <synths;

    *transport {|clock|
        U(\transport, clock);
    }

    *recdir {|path|
        var mypath = path ?? {Document.current.dir};
        thisProcess.platform.recordingsDir_(mypath.debug(\recdir));
    }

    *mixer {
        var m = NdefMixer(Server.default);
        ProxyMeter.addMixer(m);
        m.switchSize(0);
        ^m;
    }

    *setParentEvent {|evt|
        Event.addParentType(\note, evt);
        Event.addParentType(\monoNote, evt);
        Event.addParentType(\monoSet, evt);

        /*
        Event.addParentType(\note, (root:0, scale:#[ 0, 2, 5, 7, 9 ], stepsPerOctave: 12));
        g = EnvirGui.new((root:0, scale:#[ 0, 2, 5, 7, 9 ], stepsPerOctave: 9), numItems:8);
        g.putSpec(\stepsPerOctave, [1, 128, \lin, 1, 12]);
        g.putSpec(\root, [-12, 12, \lin, 1, 0]);
        */
    }

    *getParentEvent {
        var evt = Event.parentTypes[\note] ?? { () };
        ^evt;
    }

    *sendToTwister {
        var new = currentEnvironment
        .select({|v, k| v.isKindOf(S) or: v.isKindOf(O) })
        .reject({|v, k| synths.collect({|assoc| assoc.key}).includes(k) })
        .keysValuesDo({|k, v|
            var pos = synths.pos;
            synths.put(pos, k -> v);
            Twister.knobs(pos)
            .ccFunc({|vel|
                if (v.isKindOf(S)) {
                    v.node.vol = vel/127;
                } {
                    v.vol = vel/127;
                }
                //[pos, vel].postln;
            }, [0, 1, \lin, 0, 0])
            .note({ v.play; },{ v.stop; })
            .label_(k);
            //v.set(\vel, Twister.knobs(pos).asMap)
        });
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

    *initClass {
        synths = Order.new;
    }
}