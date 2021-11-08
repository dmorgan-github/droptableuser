
MidiCtrl {

    var <key, <ccChan, <noteChan;

    *new {|key=\iac, ccChan=0, noteChan=0|
        var res = super.new.init(key, ccChan, noteChan);
        ^res;
    }

    init {arg argKey, argCcChan, argNoteChan;
        key = argKey;
        ccChan = argCcChan;
        noteChan = argNoteChan;
    }

    *trace {arg enable=true;
        MIDIFunc.trace(enable);
    }

    note {arg on, off, chan;

        var mychan = if (chan.isNil) {noteChan} {chan};
        var onkey = ("%_%_on").format(this.key, mychan).asSymbol;
        var offkey = ("%_%_off").format(this.key, mychan).asSymbol;

        if (on.isNil) {
            "free %".format(onkey).debug(this.key);
            MIDIdef(onkey).permanent_(false).free;
        }{
            "register %".format(onkey).debug(this.key);
            MIDIdef.noteOn(onkey, func:{arg vel, note, chan, src;
                on.(note, vel, chan);
            }, chan:mychan)
            .permanent_(true);
        };

        if (off.isNil){
            "free %".format(offkey).debug(this.key);
            MIDIdef(offkey).permanent_(false).free;
        }{
            "register %".format(offkey).debug(this.key);
            MIDIdef.noteOff(offkey, func:{arg vel, note, chan, src;
                off.(note, chan);
            }, chan:mychan)
            .permanent_(true);
        };

        ^this;
    }

    cc {arg num, func, chan;

        var mychan = if (chan.isNil) {"all"}{chan};
        var key = "%_%_cc%".format(this.key, mychan, num).asSymbol;
        if (func.isNil) {
            "free %".format(key).debug(this.key);
            MIDIdef(key).permanent_(false).free;
        }{
            "register %".format(key).debug(this.key);
            MIDIdef.cc(key, {arg val, ccNum, chan, src;
                func.(val, ccNum, chan);
            }, ccNum: num, chan:mychan)
            .permanent_(true);
        }
    }

    bend {arg func, chan;
        var mychan = if (chan.isNil) {this.noteChan}{chan};
        var key = "%_%_bend".format(this.key, mychan).asSymbol;
        if (func.isNil) {
            "free %".format(key).debug(this.key);
            MIDIdef(key).permanent_(false).free;
        }{
            "register %".format(key).debug(this.key);
            MIDIdef.bend(key, {arg val, chan, src;
                // var bend = val.linlin(0, 16383, 0.9, 1.1);
                func.(val, mychan);
            }, chan:chan)
            .permanent_(true);
        }
    }

    // pressure
    touch {arg func, chan;
        var mychan = if (chan.isNil) {"all"}{chan};
        var key = "%_%_touch".format(this.key, mychan).asSymbol;
        if (func.isNil) {
            "free %".format(key).debug(this.key);
            MIDIdef(key).permanent_(false).free;
        }{
            "register %".format(key).debug(this.key);
            MIDIdef.touch(key, {arg val, chan, src;
                func.(val, chan);
            }, chan:chan)
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
        //all.removeAt(key)
    }

    *connect {

        /*
        MIDIClient.disposeClient;
		MIDIClient.init;
		MIDIIn.connectAll;
        */
        MIDIClient.disposeClient;
        MIDIClient.init(verbose:true);
        MIDIIn.connectAll(verbose: true);
    }
}

