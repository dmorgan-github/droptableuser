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

    var <key, <src, <>enabled;


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
        enabled = true;
        MIDIClient.init;

        if (inSrcKey.isNil) {
            inSrcKey = "IAC Driver";
        };

        src = MIDIClient.sources
        .select({arg src; src.device.beginsWith(inSrcKey)})
        .first;

        //MIDIIn.connect(device:src);
        MIDIIn.connectAll;
    }

    *trace {arg enable=true;
        // TODO need to ensure midi is initialized and connected
        MIDIClient.init;
        MIDIIn.connectAll;
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
                if (enabled) {
                    on.(note, vel, chan);
                }
            }, chan:chan, srcID:srcid)
            .permanent_(true);
        };

        if (off.isNil){
            "free %".format(offkey).debug(this.key);
            MIDIdef(offkey).permanent_(false).free;
        }{
            "register %".format(offkey).debug(this.key);
            MIDIdef.noteOff(offkey, func:{arg vel, note, chan, src;
                if (enabled) {
                    off.(note, chan);
                }
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
                if (enabled) {
                    func.(val, ccNum, chan);
                }
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
                if (enabled) {
                    func.(val, chan);
                }
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
                if (enabled) {
                    func.(val, chan);
                }
            }, chan:chan, srcID:srcid)
            .permanent_(true);
        }
    }

    clear {
        this.note(nil, nil);
        this.bend(nil);
        // clear all with brute force
        127.do({arg i;
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

    *stopMidiwatch {
        SkipJack.stop(\midiwatch);
    }

    *startMidiwatch {
        var devices = [];
        "midiwatch start".debug(\MidiCtrl);
        SkipJack({
            var new;
            MIDIClient.init(verbose:false);
            new = MIDIClient.sources.collect({|val| val.device.asSymbol }).difference(devices);
            devices = devices.addAll(new);
            if (new.size > 0) {
                new.debug("midi detected");
            };
            MIDIIn.connectAll;
            new.do({|device|
                var data = (device:device, status:\connect);
                Evt.trigger(\midiconnect, data)
            });

        }, dt:5, name:\midiwatch, autostart:true)

    }

    *initClass {
        all = ();
    }
}

TwisterKnob {

    classvar key = 'twisterknob';
    var <ccNum, <ccChan, <noteChan;
    var <onkey, <offkey, <cckey;

    *new {|ccNum, ccChan=0, noteChan=1|
        ^super.new.prInit(ccNum, ccChan, noteChan);
    }

    prInit {|argNum, argCcChan=0, argNoteChan=1|
        ccNum = argNum;
        ccChan = argCcChan;
        noteChan = argNoteChan;
        this.prInitCC();
        this.prInitNote();
    }

    prInitNote {

        onkey = ("%_%_on").format(key, ccNum).asSymbol;
        offkey = ("%_%_off").format(key, ccNum).asSymbol;

        "register %".format(onkey).debug(key);
        MIDIdef.noteOn(onkey, func:{arg vel, note, chan, src;
            Evt.trigger(onkey, (note:note, vel:vel, chan:chan));
        }, noteNum: ccNum, chan:noteChan)
        .permanent_(true);

        "register %".format(offkey).debug(key);
        MIDIdef.noteOff(offkey, func:{arg vel, note, chan, src;
            Evt.trigger(offkey, (note:note, vel:vel, chan:chan));
        }, noteNum: ccNum, chan:noteChan)
        .permanent_(true);
    }

    free {
        this.prFreeNote;
        this.prFreeCc;
    }

    prInitCC {
        cckey = "%_%_cc".format(key, ccNum).asSymbol;
        "register %".format(cckey).debug(key);
        MIDIdef.cc(cckey, {arg val, ccNum, chan, src;
            Evt.trigger(cckey, (val:val/127, ccNum:ccNum, chan:chan));
        }, ccNum: ccNum, chan:ccChan)
        .permanent_(true);
    }

    prFreeNote {
        if (onkey.isNil.not) {
            "free %".format(onkey).debug(key);
            MIDIdef(onkey).permanent_(false).free;
        };

        if (offkey.isNil.not) {
            "free %".format(offkey).debug(key);
            MIDIdef(offkey).permanent_(false).free;
        }
    }

    prFreeCc {
        if (cckey.isNil.not) {
            "free %".format(cckey).debug(key);
            MIDIdef(cckey).permanent_(false).free;
        }
    }

    *classInit {
    }
}

Twister {

    classvar <knobOrder;
    classvar <deviceName = "Midi Fighter Twister";
    classvar <devicePort = "Midi Fighter Twister";
    classvar <>ccChan=0, <>noteChan=1;

    *knobs {|ccNum|
        var knob = knobOrder[ccNum];
        if (knob.isNil) {
            knob = TwisterKnob(ccNum, ccChan, noteChan);
            knobOrder[ccNum] = knob;
        };
        ^knob;
    }

    *clear {
        knobOrder.do({|knob, i|
            knob.free;
        });
        knobOrder.makeEmpty;
    }

    *initClass {
        knobOrder = Order.new;
    }
}

Microlab : MidiCtrl {

    classvar id;

    var <>ccChan, <>noteChan;

    *new {|chan=2|
        ^super.new(id, "Arturia MicroLab");
    }

    *initClass {
        id = ('microlab_' ++ UniqueID.next).asSymbol;
    }
}

Roli : MidiCtrl {

    classvar id;

    // bend semitones
    classvar <>bendst;

    classvar instance;

    var <>ccChan, <>noteChan;

    var <bendMap;


    *new {
        if (instance.isNil) {
            instance = super.new(id, "Lightpad BLOCK");
        }
        ^instance;
    }

    *doesNotUnderstand {|selector ...args|
        var res = this.new();
        ^res.perform(selector, *args);
    }

    init {|inKey, inSrcKey|
        super.init(inKey, inSrcKey);
        bendMap = Ndef((inKey ++ '_bend').asSymbol, {\val.kr(0).lag(0.5) });
        this.ccChan = 2;
        this.noteChan = 2;
        this.bend({|val|
            var bend = val.linlin(0, 16383, bendst.neg, bendst);
            bendMap.set(\val, bend);
        }, this.ccChan);
    }

    note {|on, off|
        var bendoff = {|note, chan|
            off.(note, chan);
            bendMap.set(\val, 0);
        };
        super.note(on, bendoff, noteChan);
    }


    *initClass {
        id = ('roli_' ++ UniqueID.next).asSymbol;
        bendst = 12;
    }
}


