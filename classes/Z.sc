Z : Pdef {

    var <chan, <midiout;
    var <device, <port;

    *new {|key, chan, devicekey|

        var res = Pdef.all[key];
        if (res.isNil) {
            res = super.new(key).prInit(chan, devicekey)
        };

        currentEnvironment[key] = res;
        ^res;
    }

    @ {|val, adverb|

        if (adverb.isNil and: val.isKindOf(Array)) {
            this.set(*val);
        } {
            var func = Fdef("dialects/%".format(adverb).asSymbol);
            if (func.source.isNil) {
                this.set(adverb, val);
            }{
                func.(val, this);
            }
        }
    }

    source_ {|pattern|

        var chain = Pchain(

            Pbind(

                \cc_set, Pfunc({|evt|
                    var current = evt;
                    var chan = evt['chan'];
                    var midiout = evt['midiout'];
                    current = current.select({|v, k|
                        k.asString.beginsWith("cc")
                    })
                    .pairsDo({|k, v|
                        var num = k.asString[2..].asInteger;
                        midiout.control(chan, num, v);
                    });
                })
            ),

            pattern,

            Pbind(
                \type, \midi,
                \midicmd, \noteOn,
                \midiout, Pfunc({midiout}),
                \chan, Pfunc({chan})
            );
        );

        super.source = chain;

        ^this;
    }

    cc {|ctrlNum, val|
        midiout.control(chan, ctrlNum, val);
    }

    noteOn {|note, vel|
        midiout.noteOn(chan, note, vel);
    }

    noteOff {|note, vel|
        midiout.noteOff(chan, note, vel);
    }

    prInit {|argChan, argDeviceKey|

        var info;
        var mapping = (
            'local': ["IAC Driver", "Bus 1"]
        );

        chan = argChan;
        clock = W.clock;

        info = mapping[argDeviceKey ?? 'local'];
        device = info[0];
        port = info[1];

        midiout = MIDIOut.newByName(device, port);
        midiout.connect;

        super.source = Pbind();
        this.set(\amp, -12.dbamp);
        this.quant = 4.0;
        ^this
    }
}
