MidiSynth : Ndef {

    var <synthdef, <hasGate, <instrument;
    var <noteonkey, <noteoffkey, <cckey;

    *new {|key|
        var res = Ndef.dictFor(Server.default).envir[key];
        if (res.isNil) {
            res = super.new(key).prInit;
        };
        ^res;
    }

    prInit {
        noteonkey = "%_noteon".format(this.key).asSymbol;
        noteoffkey = "%_noteff".format(this.key).asSymbol;
        cckey = "%_cc".format(this.key).asSymbol;
        ^this;
    }

    note {|noteChan, note|
        MIDIdef.noteOn(noteonkey, {|vel, note, chan|
            if (this.hasGate) {
                this.put(note, instrument, extraArgs:[\freq, note.midicps, \vel, vel/127, \gate, 1])
            } {
                this.put(note, instrument, extraArgs:[\freq, note.midicps, \vel, vel/127])
            }
        }, noteNum:note, chan:noteChan)
        .fix;

        MIDIdef.noteOff(noteoffkey, {|vel, note, chan|
            if (this.hasGate) {
                this.objects[note].set(\gate, 0);
            }
        }, noteNum:note, chan:noteChan)
        .fix;
    }

    synth {|synth|
        synthdef = SynthDescLib.global.at(synth);
        instrument = synth;
        hasGate = synthdef.hasGate;
        this.prime(synth);
    }

    cc {|ctrl, ccNum, ccChan=0|
        var order = Order.newFromIndices(ctrl.asArray, ccNum.asArray);
        MIDIdef.cc(cckey, {|val, num|
            var ctrl = order[num];
            var spec = if (this.getSpec(ctrl).notNil) {
                this.getSpec(ctrl)
            }{
                [0, 1].asSpec;
            };
            var mapped = spec.map(val/127);
            this.set(ctrl, mapped);
        }, ccNum:ccNum, chan:ccChan)
        .fix;
    }

    disconnect {
        MIDIdef.noteOn(noteonkey).permanent_(false).free;
        MIDIdef.noteOff(noteoffkey).permanent_(false).free;
        MIDIdef.cc(cckey).permanent_(false).free;
    }
}