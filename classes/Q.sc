/*
EQ
*/

Q {
    classvar vst, synth, <ctrl, synthdef=\vsteq;

    *start {|bus=0|
        //VSTPlugin.search;
        synth = Synth(synthdef, [\bus, bus], target: RootNode(Server.default), addAction:\addToTail);
        ctrl = VSTPluginController(synth, \eq).open("MEqualizer", editor:true);
    }

    *view {
        ctrl.editor;
    }

    *free {
        ctrl.close;
        synth.free;
    }

    *initClass {
        StartUp.add({
            SynthDef(synthdef, {
                var bus = \bus.kr(0);
                var sig = In.ar(bus, 2);
                sig = VSTPlugin.ar(sig, 2, id: \eq);
                ReplaceOut.ar(bus, sig);
            }).add;
        });
    }
}
/*
Q : Device {

    var <guikey;

    deviceInit {

        var fromControl;
        fromControl = {arg controls;
            controls.clump(3).collect({arg item;
                [(item[0] + 1000.cpsmidi).midicps, item[1], 10**item[2]]
            });
        };

        this.wakeUp;
        this.play;

        this.put(100, \filter -> {arg in;

            var frdb, input = in;
            frdb = fromControl.(Control.names([\eq_controls]).kr(0!15));
            input = BLowShelf.ar(input, *frdb[0][[0,2,1]].lag(0.1));
            input = BPeakEQ.ar(input, *frdb[1][[0,2,1]].lag(0.1));
            input = BPeakEQ.ar(input, *frdb[2][[0,2,1]].lag(0.1));
            input = BPeakEQ.ar(input, *frdb[3][[0,2,1]].lag(0.1));
            input = BHiShelf.ar(input, *frdb[4][[0,2,1]].lag(0.1));
            input = RemoveBadValues.ar(input);
            input;
        });
    }

    view {
        ^U(\eq, this)
    }
}
*/