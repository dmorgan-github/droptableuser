/*
recordingDir
s.record
thisProcess.platform.recordingsDir = "/Users/david/Documents/supercollider/projects/tapes/"
s.record(bus: 4, numChannels:24)
s.stopRecording
*/

T : InstrTrack {}

InstrTrack {

    classvar <>mod;
    classvar <tracks;
    classvar <parentEvent;
    classvar <>daw;
    classvar <>proto;

    at {|index|
        ^tracks[index]    
    }

    put {|index, val ...args|

        var proxy;
        var key = "t%".format(index).asSymbol;
        if (val.isKindOf(String) or: { val.isKindOf(Symbol) }  ) {
            var myval = val.asString;
            case (
                { myval.beginsWith("vst:") }, {
                    myval = myval[4..].asSymbol;
                    proxy = VstInstrProxy(key).instrument_(myval);
                    proxy.out = key;
                },
                { myval.beginsWith("midi:") }, {
                    var parts, device, chan = 0;
                    myval = myval[5..];
                    parts = myval.split($/);
                    device = parts[0];
                    if (parts.size > 1) {
                        chan = parts[1].asInteger;
                    };
                    [key, device, chan].debug("midi");
                    proxy = MidiInstrProxy(device, chan);//.key_(key);
                    proxy.instrument = device;
                    proxy.out = key;
                }
            )
        }{
            proxy = tracks[index];
            if (proxy.isNil) {
                proxy = InstrProxy(key);
                proxy.out = key;
            }
        };

        if (tracks[index].isNil) {
            proxy.proto = proto;
            tracks.put(index, proxy);
            T.changed(\trackadded, [index, proxy]);
        }
        ^proxy
    }

    *gui {
        UiModule("workspace").gui
    }

    /*
    *serverGui {
        Server.default.makeGui
    }
    */

    /*
    // TODO: not entirely sure about this
    *parentEvent_ {|evt|
        parentEvent = evt.debug("parentEvent");
        Event.addParentType(\note, parentEvent);
        Event.addParentType(\monoNote, parentEvent);
        Event.addParentType(\monoSet, parentEvent);
        //Event.addParentType(\vst_midi, parentEvent);

        / *
        Event.addParentType(\note, (root:0, scale:#[ 0, 2, 5, 7, 9 ], stepsPerOctave: 12));
        g = EnvirGui.new((root:0, scale:#[ 0, 2, 5, 7, 9 ], stepsPerOctave: 9), numItems:8);
        g.putSpec(\stepsPerOctave, [1, 128, \lin, 1, 12]);
        g.putSpec(\root, [-12, 12, \lin, 1, 0]);
        * /
    }
    */

    *tempo_ {|tempo|
        TempoClock.default.tempo = tempo.debug("tempo");
    }

    *tempo {
        ^TempoClock.default.tempo
    }

    *record {
        var dir = PathName(thisProcess.nowExecutingPath).pathOnly;
        Platform.recordingsDir = dir;
        //s.record
        //s.recordBus(bus, duration, path, numChannels, node)
    }

    *initClass {
        tracks = Order();
        daw = \Reaper.asClass;

        StartUp.add({
            proto = Event.default;
        });
    }
}

