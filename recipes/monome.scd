MonoM.connect
~m = MonoM.new("/monome", 0)
~m.useDevice(0)
MidiCtrl.connect

m = NdefMixer(s, 25);
ProxyMeter.addMixer(m)

MIDIdef.all.do(_.free)
OSCdef.all.do(_.free)
~m.ledall(0);
~m.levset(0, 0, 15);




(
var degrees = Scale.minor.degrees ++ [12];
var root = 'C1'.namemidi;
var step = 7;
~data = degrees.collect({|degree|
    var val = root + degree + (step * (0..7));
    val.nearestInScale(degrees);
})
)

(
var buttons = Array.fill(128, {0});
var synths = Order.new;
OSCdef(\testosc, {|msg|

    var x = msg[1];
    var y = msg[2];
    var val = msg[3];

    if (val == 1) {
        var num = 128 - ((16-x) + (16 * y));
        var state;
        var note;
        buttons[num] = (1-buttons[num]);
        ~m.levset(x, y, buttons[num] * 15);//~buttons[num].debug(\here);
        note = ~data.wrapAt(7-y).wrapAt(x);

        if (buttons[num] > 0) {
            if (synths[note].isNil) {
                synths[note] = Synth(\squine, [\freq, note.midicps, \gate, 1, \amp, 0.1, \rel, 2]);
            }
        }{
            synths[note].set(\gate, 0);
            synths.removeAt(note);
        };

        [x, 7-y, note].postln;
    };

}, '/monome/grid/key')
.permanent_(true);
)



(
var m = ~m;
var osckey = "m_kb".asSymbol;
var width = 5;
var bottom = 7;
var top = 3;

~func = {|offset=0|
    var hilight = Scale.dorian.degrees;
    var stepsperoctave = 12;
    var osckey = "m_%_kb".format(offset).asSymbol;
    for(bottom, top, {|y|
        for(offset, offset+width-1, {|x|
            var num = x + ( (7-y) * width) - offset;
            if (hilight.includes(num.mod(stepsperoctave))) {
                if (num.mod(stepsperoctave) == 0) {
                    m.levset(x, y, 15);
                }{
                    m.levset(x, y, 6);
                }
            }
        })
    });
};

// would tdef be better here?
Pdef(osckey,
    Ppar(
        3.collect({|val|
            var x = val * width;
            Pbind(\foo, Pfunc({|evt|
                thisThread.clock.sched(1, {
                    {
                        m.levset(x, 2, 15);
                        {
                            m.levset(x, 2, 0)
                        }.defer(0.1)
                    }.defer(s.latency)

                });
                Rest(1)
            }))
        })
    )
).play(argClock:W.clock, quant:1);

// reset button
3.do({|i|
    var width = 5;
    var x = i * width;
    m.levset(x, 1, 2);
});

OSCdef(osckey, {|msg|
    var width = 5;
    var x = msg[1];
    var y = msg[2];
    var val = msg[3];
    var size = 5;
    3.do({|i|
        var offset = i * width;
        if (x >= offset
            and: {x < (offset + width)}
            and: {y < 8}
            and: {y > 2}) {
            var evt = "m_%".format(i).asSymbol;
            var num = (x-offset) + ( (7-y) * width);
            Evt.trigger(evt, (kb:i, num:num, val:val))
        };
        if (x == offset and: {y == 1} and: {val == 1}) {
            var evt = "m_clear_%".format(i).asSymbol;
            Evt.trigger(evt, (kb:i));
        }
    })
}, '/monome/grid/key')
.permanent_(true);

[0, 5, 10].do({|val|
    ~func.(val);
})
)

(
var m = ~m;
Pdef(\ploopr,
    Pspawner({|sp|
        inf.do({|i|
            var note, pattern;
            var new = ~notes.pop;
            var size = ~loopbuf.indices.size;
            var div = ~div ?? {0.125};
            while ({new.notNil}) {
                var num = i.mod(size);
                ~loopbuf[num].add(new);
                new = ~notes.pop;
            };
            note = ~loopbuf.wrapAt(i);
            if (note.size > 0) {
                var notes = note.asArray;
                pattern = Pbind(\midinote, notes)
            }{
                pattern = Pn(Event.silent);
            };
            sp.seq(pattern.finDur(div))
        })
    })
)
)

Order.newFromIndices(16.collect({List.new}), (0..15))

/////////////////////////////////////////////
//
(
~defs = [
    (
        instrument: \modal,
        div: 0.5,
        ctrls: [\harm, \morph, \bright, \rel],
        root: 48,
        notes: List.new,
        buffer: Order.newFromIndices(16.collect({List.new}), (0..15))
    ),
    (
        instrument: \frame_drum,
        div: 0.6,
        ctrls: [\decCoef, \position, \thumpAmp, \thumpDec],
        root: 48,
        notes: List.new,
        buffer: Order.newFromIndices(16.collect({List.new}), (0..15))
    )
];
)


(
~func2 = {

    var defs = ~defs;

    defs.do({|def, i|

        var frames = def.buffer.indices;
        var root = def.root;
        var instrument = def.instrument;
        var ctrls = def.ctrls;
        var div = def.div;
        var buffer, notes, synth, meta, cc;
        var ccoffset;
        var evtkey;
        var ndefkey;
        var cckey;
        var clearkey;

        notes = def.notes;
        buffer = def.buffer;
        evtkey = "m_%".format(i).asSymbol;
        Evt.on(evtkey, \a, {|data|
            var note = data.num + root;
            if (data.val == 1) {
                notes.add(note);
            }
        });

        clearkey = "m_clear_%".format(i).asSymbol;
        Evt.on(clearkey, \a, {|data|
            frames.do({|i| buffer[i] = List.new;});
        });

        ndefkey = "m_%".format(i).asSymbol;
        //Ndef(ndefkey).play(out: D.defaultout + (i * 2));
        Ndef(ndefkey).play();
        Ndef(ndefkey).clock = W.clock;
        Ndef(ndefkey).quant = 4.0;
        Ndef(ndefkey)[1] = Pbind(\instrument, instrument)
        <> Penvir((notes:notes, loopbuf:buffer, div:div), Pdef(\ploopr));

        synth = SynthDescLib.all[\global].synthDescs[instrument];
        meta = synth.metadata;
        if (meta.notNil and: {meta[\specs].notNil} ) {
            var specs = meta[\specs];
            specs.keys.do({|key|
                Spec.add(key, specs[key])
            });
        };

        synth
        .controls.reject({|cn|
            [\freq, \out, \trig, \in].includes(cn.name.asSymbol)
        }).do({|cn|
            Ndef(ndefkey).set(cn.name.asSymbol, cn.defaultValue);
        });

        ccoffset = i * 16;
        cc = Order.newFromIndices(ctrls, (ccoffset..(ccoffset+ctrls.size-1)));

        cckey = "m_cc_%".format(i).asSymbol;
        MIDIdef.cc(cckey, {|val, num|
            var ctrl = cc[num];
            var spec = if (Ndef(ndefkey).getSpec(ctrl).notNil) {
                Ndef(ndefkey).getSpec(ctrl)
            }{
                [0, 1].asSpec;
            };
            var mapped = spec.map(val/127);
            Ndef(ndefkey).set(ctrl, mapped);

        }, ccNum:cc.indices.debug(\indices), chan:Twister.ccChan);

    });
};
~func2.();
)



(
Evt.on(\m_0, \a, {|data|
    var note = data.num + 48;
    if (data.val == 1) {
        ~notes1.add(note);
    }
});
Evt.on(\m_1, \a, {|data|
    var note = data.num + 48;
    if (data.val == 1) {
        ~notes2.add(note);
    }
});
Evt.on(\m_clear_0, \a, {|data|
    \clear0.postln;
    //~num1.do({|i| ~buffer1[i] = List.new;});

});
Evt.on(\m_clear_1, \a, {|data|
    \clear1.postln;
    ~num2.do({|i| ~buffer2[i] = List.new;});

});
)

/////////////////////////////////////////////
//

m = NdefMixer(s, 25);
ProxyMeter.addMixer(m)

/////////////////////////////////////////////
//

/////////////////////////////////////////////
//
Ndef(\m).clear
Ndef(\m).play(out:4)
Ndef(\m).prime(\modal)
Ndef(\m).gui
Ndef(\m).stop(fadeTime:8)
Ndef(\m).free(fadeTime:8)
Ndef(\m).clock = W.clock
Ndef(\m).quant = 4.0


~notes1 = List.new
~buffer1 = Order.new;
~num1 = 8;
~num1.do({|i| ~buffer1[i] = List.new;});

(
var num = ~num;
Ndef(\m)[1] = Pbind(\instrument, \modal)
<> Pbind(\foo, Pfunc({ if (0.8.coin) {1}{ Rest(1) } }))
<> Penvir((notes:~notes1, loopbuf:~buffer1, div:(num/4).reciprocal), Pdef(\ploopr), false)
)

// fx
(
Ndef(\m).filter(200, {|in|
    var fx = PitchShift.ar(in, 4, 2, 0.01, 0.01);
    fx
}).set(\wet200, 0.3)
)


/////////////////////////////////////////////
//
Ndef(\n).prime(\fm7_algo6)
Ndef(\n).play(out:6)
Ndef(\n).removeAt(0)
Ndef(\n).objects[0].set(\gate, 0)
Ndef(\n).gui
Ndef(\n).gui
Ndef(\n).set(\rel, 4, \fb, 1)
Ndef(\n).free(fadeTime:8)
Ndef(\n).quant = 4.0
Ndef(\n).clock = W.clock


~notes2 = List.new
~buffer2 = Order.new;
~num2 = 8;
~num2.do({|i| ~buffer2[i] = List.new;});

(
var num = ~num2;
Ndef(\n)[0] = Pbind(\instrument, \fm7_algo6, \vel, 0.3)
<> Penvir((notes:~notes2, loopbuf:~buffer2, div:(num/4).reciprocal), Pdef(\ploopr), false)
)



(
var synth = SynthDescLib.all[\global].synthDescs[\modal];
var meta = synth.metadata;
if (meta.notNil and: {meta[\specs].notNil} ) {
    var specs = meta[\specs];
    specs.keys.do({|key|
        Spec.add(key, specs[key])
    });
};

synth
.controls.reject({|cn|
    [\freq, \out, \trig, \in].includes(cn.name.asSymbol)
}).do({|cn|
    Ndef(\m).set(cn.name.asSymbol, cn.defaultValue);
});
)

(
var ctrls = [
    \harm,
    \morph,
    \bright,
    \rel,
    \atk
];
~cc1 = Order.newFromIndices(ctrls, (0..ctrls.size-1));
)

(
MIDIdef.cc(\m_cc, {|val, num|
    var ctrl = ~cc1[num];
    var mapped = Ndef(\m).getSpec(ctrl).map(val/127);
    Ndef(\m).set(ctrl, mapped);
}, ccNum:~cc1.indices, chan:Twister.ccChan);
)

[
    (
        instrument: \modal,
        frames: 64,
        div: 0.25,
        ctrls: [\harm, \morph, \bright, \rel]
    )
]


