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

        \superinit.postln;
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

    *initClass { all = () }
}


TwisterKnob {

    classvar key = 'twisterknob';

    var <device, <midiout, ccChan;
    var <spec, <node, <ccNum, <default, <func, <>label;
    var onkey, offkey, nodekey, cckey;
    var view, nb, knob;

    *new {|ccNum, device, midiout|
        ^super.new.prInit(ccNum, device, midiout);
    }

    prInit {|argNum, argDevice, argMidiout|
        ccNum = argNum;
        device = argDevice.debug(\device);
        midiout = argMidiout.debug(\midiout);
        label = "kn" ++ argNum;
    }

    cc {|argSpec, chan=0|

        ccChan = chan;
        spec = argSpec.asSpec;
        default = spec.default.linlin(spec.minval, spec.maxval, 0, 127);
        nodekey = "%_%_cc%".format(key, ccChan, ccNum).asSymbol.debug(\ccmap);
        node = Ndef(nodekey.asSymbol, { \val.kr(spec:spec) });
        func = {|val|
            node.set(\val, spec.map(val/127));
        };
        this.prInitCC(ccNum, func, ccChan);
    }

    note {|on, off, chan=1|

        var srcid = device.uid;
        var srcdevice = this.prNormalize(device.device);

        onkey = ("%_%_%_on").format(key, chan, ccNum).asSymbol;
        offkey = ("%_%_%_off").format(key, chan, ccNum).asSymbol;

        if (on.isNil) {
            this.prFreeNoteOn;
        }{
            "register %".format(onkey).debug(key);
            MIDIdef.noteOn(onkey, func:{arg vel, note, chan, src;
                on.(note, vel, chan);
            }, noteNum: ccNum, chan:chan, srcID:srcid)
            .permanent_(true);
        };

        if (off.isNil){
            this.prFreeNoteOff;
        }{
            "register %".format(offkey).debug(key);
            MIDIdef.noteOff(offkey, func:{arg vel, note, chan, src;
                off.(note, chan);
            }, noteNum: ccNum, chan:chan, srcID:srcid)
            .permanent_(true);
        };
    }

    prFreeNoteOn {
        "free %".format(onkey).debug(key);
        MIDIdef(onkey).permanent_(false).free;
    }
    prFreeNoteOff {
        "free %".format(offkey).debug(key);
        MIDIdef(offkey).permanent_(false).free;
    }
    prFreeCc {
        "free %".format(cckey).debug(key);
        MIDIdef(cckey).permanent_(false).free;
    }
    prFreeNode {
        node.clear;
    }

    free {
        this.prFreeNoteOn;
        this.prFreeNoteOff;
        this.prFreeCc;
        this.prFreeNode;
    }

    asMap {
        ^node
    }

    asPfunc {
        ^Pfunc({
            node.get(\val)
        });
    }

    prInitCC {|num, func, chan|

        var srcid = device.uid;
        var srcdevice = this.prNormalize(device.device);
        cckey = "%_%_cc%".format(key, chan, num).asSymbol;
        if (func.isNil) {
            this.prFreeCc;
        }{
            "register %".format(cckey).debug(key);
            MIDIdef.cc(cckey, {arg val, ccNum, chan, src;
                func.(val, ccNum, chan);
                {
                    if (view.isNil.not and: {view.isClosed.not}) {
                        knob.value_(val/127);
                        nb.value_(spec.map(val/127));
                    }
                }.defer
            }, ccNum: num, chan:chan, srcID:srcid)
            .permanent_(true);
        };
        if (midiout.isNil.not) {
            midiout.control(ccChan, ccNum, default);
        };
    }

    asView {
        nb = NumberBox();
        knob = Knob();
        view = View().layout_(VLayout(
            StaticText().string_(label).align_(\center),
            knob.mode_(\vert).action_({|ctrl|
                func.(ctrl.value.linlin(0, 1, 0, 127));
                nb.value_(spec.map(ctrl.value));
                if (midiout.isNil.not) {
                    midiout.control(ccChan, ccNum, ctrl.value.linlin(0, 1, 0, 127));
                }
            })
            .value_(spec.unmap(node.get(\val))),

            nb
            .value_(node.get(\val))
            .background_(Color.white)
        )
        .spacing_(0)
        .margins_(0)
        )
        .background_(Color.blue.alpha_(0.2));
        ^view
    }

    prNormalize {arg str;
        ^str.toLower().stripWhiteSpace().replace(" ", "")
    }

    *classInit {
    }
}

Twister {

    classvar <knobOrder, <device, <midiout;
    classvar <deviceName = "Midi Fighter Twister";
    classvar <devicePort = "Midi Fighter Twister";

    *connect {
        MIDIClient.init;

        device = MIDIIn.findPort(deviceName, devicePort);
        if (device.isNil) {
            "% device is not connected".format(deviceName).warn;
            device = MIDIIn.findPort("IAC Driver", "Bus 1");
        } {
            midiout = MIDIOut.newByName(deviceName, devicePort);
        };

        MIDIIn.connectAll;
    }

    *knobs {|ccNum|
        var knob = knobOrder[ccNum];
        if (knob.isNil) {
            knob = TwisterKnob(ccNum, device, midiout);
            knobOrder[ccNum] = knob;
        };
        ^knob;
    }

    *clear {
        knobOrder.do({|knob, i|
            [knob, i].postln;
            knob.free;
            knobOrder[i] = nil
        });
    }

    *view {
        var rows = 4, cols = 4;
        var cells = rows.collect({|row|
            cols.collect({|col|
                var num = col + (row * cols);
                var view;
                if (knobOrder[num].isNil.not and: { (view = knobOrder[num].asView).isNil.not } ) {
                    view;
                } {
                    view = StaticText()
                    .string_(num)
                    .align_(\center)
                };
                view
                .minWidth_(75)
                .minHeight_(75)
            });
        });

        var view = View()
        .layout_(
            GridLayout.rows(*cells).margins_(0).spacing_(0)
        )
        .palette_(QPalette.dark);

        ^view
    }

    *initClass {
        knobOrder = Order.new;
    }
}


/*
Twister2 : MidiCtrl {

    classvar id;

    classvar <instance;

    var <>ccChan, <>noteChan;

    var <>midiout;

    var <>midimap;

    *new {
        if (instance.isNil) {
            instance = super.new(id, "Midi Fighter Twister");
        };
        ^instance;
    }

    *doesNotUnderstand {|selector ...args|
        var res = this.new();
        ^res.perform(selector, *args);
    }

    init {|inKey, inSrcKey|
        super.init(inKey, inSrcKey);
        this.midiout = MIDIOut.newByName("Midi Fighter Twister", "Midi Fighter Twister");
        this.midimap = Order.new;
        this.ccChan = 0;
        this.noteChan = 1;
        ^this;
    }

    ccMap {|ccNum, spec|

        var nodeKey = "%_%_cc%".format(this.key, ccChan, ccNum).asSymbol.debug(\ccmap);
        var myspec = spec.asSpec;
        var node = Ndef(nodeKey.asSymbol, { \val.kr(spec:myspec) });
        var default = myspec.default.linlin(myspec.minval, myspec.maxval, 0, 127);
        // initialize
        midimap[ccNum] = (
            num: ccNum,
            spec:myspec,
            node:node
        );
        midiout.control(ccChan, ccNum, default);
        super.cc(ccNum, {|val|
            node.set(\val, myspec.map(val/127));
        }, ccChan);
        ^node;
    }

    ccFunc {|ccNum, func, default=0|
        var nodeKey = "%_%_cc%".format(this.key, ccChan, ccNum).asSymbol.debug(\ccfunc);
        // initialize
        default = default.linlin(0, 1, 0, 127);
        midiout.control(ccChan, ccNum, default);
        super.cc(ccNum, func, ccChan);
    }

    note {|on, off|
        super.note(on, off, noteChan);
    }

    noteFunc {|num, on, off|
        var onfunc = {|note, vel|
            if (note == num) {
                on.(note, vel);
            }
        };
        var offfunc = {|note|
            if (note == num) {
                off.(note);
            }
        };
        super.note(onfunc, offfunc, noteChan);
    }

    asMap {|ccNum|
        var nodeKey = "%_%_cc%".format(this.key, ccChan, ccNum).asSymbol.debug(\ccmap);
        ^Ndef(nodeKey.asSymbol);
    }

    clear {
        midimap.do({|item|
            item.clear;
        });
        super.clear();
    }

    *initClass {
        id = ('twister_' ++ UniqueID.next).asSymbol;
    }
}
*/

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


