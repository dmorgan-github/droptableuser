// InstrProxyNotePlayer {{{
InstrProxyNotePlayer {

    var <synths;
    var <instr;
    var <stream;
    var <synthdef;
    var <>filter;
    var <>debug;
    var <monoNotes;

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
        var index;

        evt = instr.envir.copy.parent_(Event.default);
        evt['vel'] = velocity;
        if (note > 11) {
            evt['midinote'] = note;
        } {
            evt['degree'] = note;
        };

        evt['out'] = instr.node.bus.index;
        instrument = instr.instrument;

        evt[\gate] = 1;
        if (filter.notNil) {
            evt.use(filter)
        };

        args = evt.use({
            ~freq = ~freq.value;
            ~amp = ~amp.value;
            ~sustain = ~sustain.value;
            //~dur = ~dur.value;
            //~stretch = ~stretch.value;
            instr.msgFunc.valueEnvir
        });

        if (debug) {
            args.asCompileString.postln;
        };

        index = note;
        if (instr.isMono) {
            index = 0;
            monoNotes.add(note);
        };

        if (instr.synthdef.hasGate) {
            if (synths[index].isNil) {
                synths[index] = Synth(instrument, args, target:target, addAction:\addToHead);
            } {
                synths[index].set(\freq, note.midicps);
            }
        } {
            Synth(instrument, args, target:target, addAction:\addToHead);
        }    
    }

    off {|note|
        var index = note;
        if (instr.isMono) {
            index = 0;
            monoNotes.remove(note);
        };
        if (instr.synthdef.hasGate) {
            if (instr.isMono and: { monoNotes.size >= 1 }) {
                var mynote = monoNotes.last;
                synths[index].set(\freq, mynote.midicps)
            } {
                synths.removeAt(index).set(\gate, 0)
            }
        }
    }

    prInit {|instrproxy|
        instr = instrproxy;
        stream = instr.asStream;
        synthdef = instr.synthdef;
        synths = Order.new;
        monoNotes = List();
        debug = false;
    }
}
// }}}