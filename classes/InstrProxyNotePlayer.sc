// InstrProxyNotePlayer {{{
InstrProxyNotePlayer {

    var <synths;
    var <instr;
    var <stream;
    var <synthdef;
    var <>func;
    var <>debug;

    *new {|instrproxy|
        ^super.new.prInit(instrproxy);
    }

    clear {
        synths.clear;
    }

    on {|note, vel=127, extra|
        var args;
        var target = instr.node.group.nodeID;
        var instrument, evt;
        var velocity = (vel/127).squared;
        var freq;
        evt = instr.envir.copy.parent_(Event.default);
        evt['vel'] = velocity;
        if (note > 11) {
            evt['midinote'] = note;
        } {
            evt['degree'] = note;
        };
        evt['out'] = instr.node.bus.index;
        // TODO: perhaps this can be an option
        //evt = stream.next( evt );
        instrument = instr.instrument;

        evt[\gate] = 1;
        if (extra.notNil) {
            evt = evt ++ extra;
        };

        args = evt.use({
            ~freq = ~freq.value;
            ~amp = ~amp.value;
            ~sustain = ~sustain.value;
            ~dur = ~dur.value;
            ~stretch = ~stretch.value;

            instr.msgFunc.valueEnvir
        });

        if (debug) {
            args.asCompileString.postln;
        };

        if (instr.synthdef.hasGate) {
            if (synths[note].isNil) {
                if ( func.(\on, note, args) != false) {
                    synths[note] = Synth(instrument, args, target:target, addAction:\addToHead);
                }
            }
        } {
            if ( func.(\on, note, args) != false) {
                Synth(instrument, args, target:target, addAction:\addToHead);
            }
        }    
    }

    off {|note|
        if ( func.(\off, note) != false) {
            if (instr.synthdef.hasGate) {
                synths.removeAt(note).set(\gate, 0)
            }
        }
    }

    prInit {|instrproxy|
        instr = instrproxy;
        stream = instr.asStream;
        synthdef = instr.synthdef;
        synths = Order.new;
        debug = false;
    }
}
// }}}