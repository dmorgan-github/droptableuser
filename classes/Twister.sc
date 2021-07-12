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