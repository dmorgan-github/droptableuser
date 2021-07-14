/*
(
MidiCtrl(\qaryrf)
.note(
{arg note, vel;
var myvel = vel/127;
S(\usmo).on(note, myvel)
},
{arg note;
S(\usmo).off(note)
}
)
.cc(0, {arg val, num, chan;
var myval = val/127;
S(\usmo).set(\start, myval);
});
)
MidiCtrl(\qaryrf).note(nil, nil).cc(0, nil);
*/
MidiCtrl {

    classvar <all;

    var <key, <src;

    *new {arg key, src=\iac;
        var res = all[key];
        if (res.isNil) {
            res = super.new.init(key, src);
            all.put(key, res);
        };
        ^res;
    }

    init {arg inKey, inSrcKey;
        key = inKey;
    }

    *trace {arg enable=true;
        MIDIFunc.trace(enable);
    }

    note {arg on, off, chan;
        var mychan = if (chan.isNil) {"all"}{chan};
        var srcid = if (this.src.isNil.not){src.uid}{nil};
        var srcdevice = if (this.src.isNil.not){this.prNormalize(src.device)}{"any"};
        var onkey = ("%_%_%_on").format(this.key, mychan, srcdevice).asSymbol;
        var offkey = ("%_%_%_off").format(this.key, mychan, srcdevice).asSymbol;

        if (on.isNil) {
            "free %".format(onkey).debug(this.key);
            MIDIdef(onkey).permanent_(false).free;
        }{
            "register %".format(onkey).debug(this.key);
            MIDIdef.noteOn(onkey, func:{arg vel, note, chan, src;
                on.(note, vel, chan);
            }, chan:chan, srcID:srcid)
            .permanent_(true);
        };

        if (off.isNil){
            "free %".format(offkey).debug(this.key);
            MIDIdef(offkey).permanent_(false).free;
        }{
            "register %".format(offkey).debug(this.key);
            MIDIdef.noteOff(offkey, func:{arg vel, note, chan, src;
                off.(note, chan);
            }, chan:chan, srcID:srcid)
            .permanent_(true);
        };

        ^this;
    }

    cc {arg num, func, chan;

        var mychan = if (chan.isNil) {"all"}{chan};
        var srcid = if (this.src.isNil.not){src.uid}{nil};
        var srcdevice = if (this.src.isNil.not){this.prNormalize(src.device)}{"any"};
        var key = "%_%_%_cc%".format(this.key, mychan, srcdevice, num).asSymbol;
        if (func.isNil) {
            "free %".format(key).debug(this.key);
            MIDIdef(key).permanent_(false).free;
        }{
            "register %".format(key).debug(this.key);
            MIDIdef.cc(key, {arg val, ccNum, chan, src;
                func.(val, ccNum, chan);
            }, ccNum: num, chan:chan, srcID:srcid)
            .permanent_(true);
        }
    }

    bend {arg func, chan;
        var mychan = if (chan.isNil) {"all"}{chan};
        var srcid = if (this.src.isNil.not){src.uid}{nil};
        var srcdevice = if (this.src.isNil.not){this.prNormalize(src.device)}{"any"};
        var key = "%_%_%_bend".format(this.key, mychan, srcdevice).asSymbol;
        if (func.isNil) {
            "free %".format(key).debug(this.key);
            MIDIdef(key).permanent_(false).free;
        }{
            "register %".format(key).debug(this.key);
            MIDIdef.bend(key, {arg val, chan, src;
                // var bend = val.linlin(0, 16383, 0.9, 1.1);
                func.(val, chan);
            }, chan:chan, srcID:srcid)
            .permanent_(true);
        }
    }

    // pressure
    touch {arg func, chan;
        var mychan = if (chan.isNil) {"all"}{chan};
        var srcid = if (this.src.isNil.not){src.uid}{nil};
        var srcdevice = if (this.src.isNil.not){this.prNormalize(src.device)}{"any"};
        var key = "%_%_%_touch".format(this.key, mychan, srcdevice).asSymbol;
        if (func.isNil) {
            "free %".format(key).debug(this.key);
            MIDIdef(key).permanent_(false).free;
        }{
            "register %".format(key).debug(this.key);
            MIDIdef.touch(key, {arg val, chan, src;
                func.(val, chan);
            }, chan:chan, srcID:srcid)
            .permanent_(true);
        }
    }

    clear {
        this.note(nil, nil);
        this.bend(nil);
        // clear all with brute force
        128.do({arg i;
            this.cc(i, nil);
        });
        all.removeAt(key)
    }

    prNormalize {arg str;
        ^str.toLower().stripWhiteSpace().replace(" ", "")
    }

    *clearAll {
        all.do({arg m; m.clear()});
        all.clear;
    }

    *connect {
        MIDIClient.init(verbose:true);
        MIDIIn.connectAll(verbose: true);
    }

    *initClass {
        all = ();
    }
}

