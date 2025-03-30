/*
recordingDir
s.record
thisProcess.platform.recordingsDir = "/Users/david/Documents/supercollider/projects/tapes/"
s.record(bus: 4, numChannels:24)
s.stopRecording
*/

T : InstrTrack {}

InstrTrack {

    classvar <all;
    classvar <>daw;
    classvar <>proto;
    classvar <recnode;

    var <tracks;
    var <key;

    *new {|key|
		var res;
        if (key.isNil) {key = 't'};
        res = all.at(key);
		if(res.isNil) {
			res = super.new.prInit(key)
		};
		^res
	}

    at {|index|
        ^tracks[index]    
    }

    put {|index, val ...args|

        var proxy;
        var key = "%%".format(this.key, index).asSymbol;
        proxy = tracks[index];

        if (proxy.isNil) {
            if (val.isKindOf(String) or: { val.isKindOf(Symbol) }  ) {
                var myval = val.asString;
                case (
                    { myval.beginsWith("vst:") }, {
                        myval = myval[4..].asSymbol;
                        proxy = VstInstrProxy(key).instrument_(myval);
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
                    }
                );
            } {
                proxy = InstrProxy(key);
            };

            proxy.out = key;
            proxy.proto = proto;
            tracks[index] = proxy;
        };

        ^proxy
    }

    /*
    *gui {
        UiModule("workspace").gui
    }
    */

    *tempo_ {|tempo|
        TempoClock.default.tempo = tempo.debug("tempo");
    }

    *tempo {
        ^TempoClock.default.tempo
    }

    *record {

        //var pn = PathName(thisProcess.nowExecutingPath).pathOnly
        var path;
        var root = proto['root'] ?? 4;
        var bpm = 60/InstrTrack.tempo.reciprocal;
        var scale = proto['scale'] ?? Scale.major;
        if (scale.isArray) {
            scale = Scale(scale);
        };
        scale = scale.name.asString.toLower;
        scale = scale.replace(" ", "");
        root = root.midiname.asString.split($-)[0];
        root = root.toLower;
        bpm = bpm.asString.split($.)[0];

        path = "%instr_bpm-%_key-%_scale-%_%.wav".format(
            PathName(thisProcess.nowExecutingPath).pathOnly,
            bpm, root, scale,
            Date.new.asSortableString
        );

        recnode = RecNodeProxy.audio(Server.default, 2);
        recnode.source = {
            var offset = 4;
            var tracks = 8;
            var chans = (tracks * 2) + offset;
            var left = (offset..(chans-1)).select({|v| v.even });
            var right = (offset..(chans-1)).select({|v| v.odd });
    
            var sigl = In.ar(left);
            var sigr = In.ar(right);
            var sig = [sigl.sum, sigr.sum];
            sig
        };
        recnode.open(path, headerFormat: "wav", sampleFormat:"int32");
        recnode.record(false)
    }

    *stopRecording {

        var pn;
        var path;
        var normalized;

        path = recnode.path;
        recnode.close;
        recnode.free;

        pn = PathName(path);
        normalized = "%%-3db.%".format(pn.pathOnly, pn.fileNameWithoutExtension, pn.extension).debug("InstrTrack.stopRecording");

        {
            SoundFile.normalize(
                path:path, 
                outPath:normalized,
                maxAmp:-3.dbamp
            );

            /*
            {
                "remove silence".debug("InstrTrack.stopRecording");
                Sox().silence.transform(normalized, normalized, false);
            }.defer(5);
            */

            {
                "delete %".format(path).debug("InstrTrack.stopRecording");
                File.delete(path);
            }.defer(2);

        }.defer(2)

    }

    prInit {|argKey|
        tracks = Order();
        key = argKey;
        all.put(key, this);
        ^this;
    }

    *initClass {
        all = Dictionary();
        daw = \Reaper.asClass;

        StartUp.add({
            proto = Event.default;
        });
    }
}

