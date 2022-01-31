+ Symbol {

    kr { | val, lag, fixedLag = false, spec |
        var name = "%%".format(this, ~num ?? {""});
        if (currentEnvironment[this].notNil ) {
            ^currentEnvironment[this]
        } {
            ^NamedControl.kr(name, val, lag, fixedLag, spec)
        }
	}

	ir { | val, spec |
        var name = "%%".format(this, ~num ?? {""});
		if (currentEnvironment[this].notNil ) {
            ^currentEnvironment[this]
        } {
            ^NamedControl.ir(name, val, spec:spec)
        }
	}

	tr { | val, spec |
        var name = "%%".format(this, ~num ?? {""});
		if (currentEnvironment[this].notNil ) {
            ^currentEnvironment[this]
        } {
            ^NamedControl.tr(name, val, spec:spec)
        }
	}

	ar {| val, lag, spec |
        var name = "%%".format(this, ~num ?? {""});
		if (currentEnvironment[this].notNil ) {
            \fuckoffa.postln;
            ^currentEnvironment[this]
        } {
            ^NamedControl.ar(name, val, lags:lag, spec:spec)
        }
	}
}

+ Buffer {

    view {
        U(\bufinfo, this)
    }

    loopr {
        var buffer = this;
        var numchannels = buffer.numChannels;
        var bufname = if (buffer.path.notNil) {
            PathName(buffer.path).fileNameWithoutExtension;
        }{
            "buffer_%".format(buffer.bufnum);
        };

        var func = SynthLib('synths/loopr').func;
        var node = D(bufname.asSymbol).put(0,
            {
                ~numchannels = numchannels;
                ~bufnum = buffer.bufnum;
                func
            }.()
        );

        node.set(\buf, buffer.bufnum);
        node.specs
        .keysValuesDo({|key, value|
            node.addSpec(key, value)
        });

        ^node
    }

    grainr {
        var buffer = this;
        var bufname = if (buffer.path.notNil) {
            PathName(buffer.path).fileNameWithoutExtension;
        }{
            "buffer_%".format(buffer.bufnum);
        };
        var synth = SynthLib('synths/grainr');
        var node = D("%_grainr".format(bufname.replace(" ", "_").toLower).asSymbol).put(0, synth.func);
        node.set(\buf, buffer.bufnum);
        node.addSpec(*synth.specs);
        ^node
    }
}

+ AbstractFunction {
    pchoose {|iftrue, iffalse|
        ^Pif(Pfunc(this), iftrue, iffalse)
    }
    pfunc { ^Pfunc(this) }

    plazy { ^Plazy(this) }

    s {|key| ^S(key).source_(this.plazy) }

    addSynthDef {|key, template='adsr'|
        SynthLib.def(key, this, template)
    }
}

+ SequenceableCollection {
    pseq {arg repeats=inf, offset=0; ^Pseq(this, repeats, offset) }
    prand {arg repeats=inf; ^Prand(this, repeats) }
    pxrand {arg repeats=inf; ^Pxrand(this, repeats) }
    pwrand {arg weights, repeats=inf; ^Pwrand(this, weights.normalizeSum, repeats)}
    pshuf {arg repeats=inf; ^Pshuf(this, repeats) }
    step {|durs, repeats=inf| ^Pstep(this, durs, repeats)}
    pdv {|repeats=inf, key=\val| ^Pdv(this, key).repeat(repeats) }

    pa {
        var a;
        this.pairsDo { |k,v|
            a = a.add(k);
            a = a.add(v.isKindOf(Function).if { Pfunc { |e| e.use { v.() } } }{ v });
        };
        ^a
    }

    p { ^Pbind(*this.pa)}
    pm { |sym| ^Pmono(sym, *this.pa)}
    pma { |sym| ^PmonoArtic(sym, *this.pa)}
    pbf { |sym| ^Pbindef(sym, *this.pa)}
    pdef {|key| ^Pdef(key, *this.p)}
    ppar {|repeats=inf| ^Ppar(this, repeats)}
    ptpar {|repeats=inf| ^Ptpar(this, repeats)}

    playTimeline {|clock=(TempoClock.default)|
        this.collect({|assoc|
            var beat = assoc.key;
            var func = assoc.value;
            clock.sched(beat, { beat.debug(\beat); func.value; nil } );
        });
    }

    loop {|dur=8, len|
        var iteration = -1;
        if (len.isNil) {len = dur};
        ^Plazy({
            iteration = iteration + 1;
            Psync(this.p.finDur(len), dur, dur) <> (iter:iteration);
        }).repeat
    }
}

+ Object {

    ifnil {|val|

        if (this.isNil) {
            ^val;
        }{
            ^this
        }
    }

    // pattern filtering at event level
    every {|func|

        ^Prout({|inval|
            var stream = this.asStream;
            var next = stream.next(inval.copy);
            var iteration = 0;
            while({next.notNil},{
                var val = func.(next, iteration, inval);
                inval = val.embedInStream(inval);
                iteration = iteration + 1;
                next = stream.next(inval);
            });
        })
    }

    sometimes {|val, prob=0.5|
        ^Prout({|inval|
            var stream = this.asStream;
            var next = stream.next(inval.copy);
            var valstream = val.asStream;
            var probstream = prob.asStream;
            var iteration = 0;
            while({next.notNil},{
                var new = if (probstream.next(inval).coin) {valstream.next(inval)}{next};
                inval = new.embedInStream(inval);
                iteration = iteration + 1;
                next = stream.next(inval);
            });
        })
    }

    arp {|algo=0|
        ^Prout({|inval|
            var lastchord = nil;
            var stream = this.asStream;
            var chord = stream.next(inval);
            var arpstream;
            while({chord.notNil}, {
                var val;
                if (chord != lastchord) {
                    arpstream = Pseq(chord, inf).asStream;
                    lastchord = chord;
                };
                val = arpstream.next(inval);
                inval = val.embedInStream(inval);
                chord = stream.next(inval);
            });
        })
    }

    then {|val|
        ^Prout({|inval|

            var stream = this.asStream;
            var valstream = val.asStream;

            var first = stream.next(inval);
            var second = valstream.next(inval);

            while({first.notNil and: {second.notNil} },{
                inval = first.embedInStream(inval);
                inval = second.embedInStream(inval);
                first = stream.next(inval);
                second = valstream.next(inval);
            });
            inval;
        })
    }
}

+ Pattern {
    limit {arg num; ^Pfin(num, this.iter) }
    step {arg dur, repeats=inf; ^Pstep(this, dur, repeats)}
    latchprob {arg prob=0.5; ^Pclutch(this, Pfunc({ if (prob.coin){0}{1} }))}
    //latch {arg func; ^Pclutch(this, Pfunc(func)) }
    // don't advance pattern on rests
    norest { ^Pclutch(this, Pfunc({|evt| evt.isRest.not })) }
    pfilter {|...args| ^Pbindf(this, *args)}

    pchain {|...args| ^Pchain(this, *args) }
    octave {|val| ^Pset(\octave, val, this)}
    atk {|val| ^Pset(\atk, val, this)}
    dec {|val| ^Pset(\dec, val, this)}
    rel {|val| ^Pset(\rel, val, this)}
    suslevel {|val| ^Pset(\suslevel, val, this)}
    curve {|val| ^Pset(\curve, val, this)}
    harmonic {|val| ^Pset(\harmonic, val, this)}
    amp {|val| ^Pset(\amp, val, this)}
    vel {|val| ^Pset(\vel, val, this)}
    detunehz {|val| ^Pset(\detunehz, val, this)}
    mtranspose {|val| ^Pset(\mtranspose, val, this)}
    legato {|val| ^Pset(\legato, val, this)}
    degree {|val| ^Pset(\degree, val, this)}
    strum {|val| ^Pset(\strum, val, this)}

    cycle {|dur=8, len, repeats=inf|
        var iteration = -1;
        if (len.isNil) {len = dur};
        ^Plazy({
            iteration = iteration + 1;
            Psync(this.finDur(len), dur, dur) <> (cycle:iteration);
        }).repeat(repeats)
    }

    loop {|dur=8, len, repeats=inf|
        var iteration = -1;
        if (len.isNil) {len = dur};
        ^Plazy({
            iteration = iteration + 1;
            Psync(this.finDur(len), dur, dur) <> (iter:iteration);
        }).repeat(repeats)
    }

    clutch {|connected| ^Pclutch(this, connected) }
    add {|name, val| ^Paddp(name, val, this)}
    mul {|name, val| ^Pmulp(name, val, this)}
    node {|node|
        var current = node.value;
        ^Pbindf(this, \out, Pfunc({current.bus}), \group, Pfunc({current.group}) )
    }
    skipsame {
        ^Plazy({
            var prev;
            var pattern = this.asStream;
            Prout{|inval|
                var next = pattern.next(inval);
                while({next.notNil}, {
                    if (next != prev) {
                        prev = next;
                        inval = prev.embedInStream(inval);
                    }{
                        inval = Rest(1).embedInStream(inval);
                    };
                    next = pattern.next(inval)
                })
            }
        })
    }

    // filtering at cycle level
    each {|func|
        var cycle = 0;
        ^Plazy({|evt|
            var return;
            //[\filt, cycle].postln;
            return = func.(this, cycle, evt);
            cycle = cycle + 1;
            return;
        })
    }

    spawn {|func|
        ^Pspawner({|sp|
            var pattern = this.asStream;
            var next = pattern.next(Event.default);
            var iteration = 0;
            while({next.notNil},{
                var vals = func.(next, iteration);
                var dur = next[\dur] ?? 1;
                vals.asArray.do({|val|
                    sp.par(val);
                });
                sp.wait(dur);
                next = pattern.next(Event.default);
                iteration = iteration + 1;
            })
        })
    }

    m {|name, value| ^Pmul(name, value, this)}
    a {|name, value| ^Padd(name, value, this)}
    //s {|name, value| ^Pset(name, value, this)}
    pdef {|key| ^Pdef(key, this)}

    seed {|val| ^Pseed(val, this)}

    s {|key|
        var obj = S(key);
        obj.source = this;
        ^obj;
    }
}

+ Array {
    nums { ^this.asInteger.join("").collectAs({|chr| chr.asString.asInteger }, Array) }
}

+ NodeProxy {

    view {
        ^U(\ngui, this);
    }

    mix {arg index=0, obj, vol=1;

        if (obj.isKindOf(Function)) {
            this.put(index, \mix -> obj);
        } {
            if (obj.isNil) {
                this.put(index, obj);
            }{
                var key = obj.key;
                // not using \mix role so that we can show
                // helpful names in gui instead of \mix0, \mix1, etc
                if (obj.class == S) {
                    //var l = (key ++ 'L').asSymbol;
                    //var r = (key ++ 'R').asSymbol;
                    this.put(index, { obj.node.ar * Control.names([key]).kr(vol) });
                }{
                    //var l = (key ++ 'L').asSymbol;
                    //var r = (key ++ 'R').asSymbol;
                    //[this.key, key, vol].debug(\ext);
                    this.put(index, {obj.ar * Control.names([key]).kr(vol) });
                };
                //[\src, key, \dest, this.key, \vol, vol].debug(\ext);
                this.set(key, vol);
                this.addSpec(key, [0, 1, \lin, 0, vol]);
            }
        };
    }

    nscope {
        ^U(\scope, this);
    }

    forPattern {
        ^Pbind(
            \out, Pfunc({this.bus.index}),
            \group, Pfunc({this.group})
        )
    }

    getSettings {
        ^this.getKeysValues.flatten
    }

    cc {|ctrl, ccNum, ccChan=0|
        var order = Order.newFromIndices(ctrl.asArray, ccNum.asArray);
        var cckey = "%_cc".format(this.key).asSymbol;
        MIDIdef.cc(cckey, {|val, num|
            var mapped;
            var ctrl = order[num];
            var spec = this.getSpec(ctrl);
            if (this.getSpec(ctrl).isNil) {
                spec = [0, 1].asSpec;
            };
            mapped = spec.map(val/127);
            this.set(ctrl, mapped);
        }, ccNum:ccNum, chan:ccChan)
        .fix;
    }

    note {|noteChan, note|
        // assumes Ndef().prime(\instrument) has been called
        var noteonkey = "%_noteon".format(this.key).asSymbol;
        var noteoffkey = "%_noteoff".format(this.key).asSymbol;
        var hasGate = this.objects[0].synthDesc.hasGate;
        var instrument = this.objects[0].synthDesc.name.asSymbol;
        MIDIdef.noteOn(noteonkey, {|vel, note, chan|
            if (hasGate) {
                this.put(note, instrument, extraArgs:[\freq, note.midicps, \vel, vel/127, \gate, 1])
            } {
                this.put(note, instrument, extraArgs:[\freq, note.midicps, \vel, vel/127])
            }
        }, noteNum:note, chan:noteChan)
        .fix;

        MIDIdef.noteOff(noteoffkey, {|vel, note, chan|
            var hasGate = this.objects[0].synthDesc.hasGate;
            if (hasGate) {
                this.objects[note].set(\gate, 0);
            }
        }, noteNum:note, chan:noteChan)
        .fix;
    }

    disconnect {
        MIDIdef.noteOn("%_noteon".format(this.key).asSymbol).permanent_(false).free;
        MIDIdef.noteOn("%_noteoff".format(this.key).asSymbol).permanent_(false).free;
        MIDIdef.noteOn("%_cc".format(this.key).asSymbol).permanent_(false).free;
    }
}

+ Pdef {

    << {|pattern|
        this.source = pattern;
    }

    getSettings {
        if (this.envir.notNil) {
            ^this.envir.getPairs
        } {
            ^[]
        }
    }

    ccMap {|ctrl, ccNum, ccChan=0|
        var order = Order.newFromIndices(ctrl.asArray, ccNum.asArray);
        var cckey = "%_cc".format(this.key).asSymbol;
        ctrl.asArray.do({|c|
            var nodekey = "%_%".format(cckey, c).asSymbol;
            var spec = this.getSpec(c).ifnil([0, 1].asSpec);
            // TODO: how does this get cleaned up?
            var node = Ndef(nodekey, { \val.kr(spec.default) });
            this.set(c, node);
        });
        MIDIdef.cc(cckey, {|val, num|
            var mapped;
            var ctrl = order[num];
            var spec = this.getSpec(ctrl).ifnil([0, 1].asSpec);
            var filter = Fdef("%_ccFilter_%".format(this.key, num).asSymbol);
            var nodekey = "%_%".format(cckey, ctrl).asSymbol;
            mapped = spec.map(val/127);
            if (filter.source.notNil) {
              mapped = filter.(mapped);
              mapped;
            };
            Ndef(nodekey).set(\val, mapped);
        }, ccNum:ccNum, chan:ccChan)
        .fix;
    }

    cc {|ctrl, ccNum, ccChan=0|
        var order = Order.newFromIndices(ctrl.asArray, ccNum.asArray);
        var cckey = "%_cc".format(this.key).asSymbol;
        MIDIdef.cc(cckey, {|val, num|
            var mapped;
            var ctrl = order[num];
            var spec = this.getSpec(ctrl);
            var filter = Fdef("%_ccFilter_%".format(this.key, num).asSymbol);
            if (spec.isNil) {
                spec = [0, 1].asSpec;
            };
            mapped = spec.map(val/127);
            if (filter.source.notNil) {
              mapped = filter.(mapped);
              mapped;
            };
            this.set(ctrl, mapped);
        }, ccNum:ccNum, chan:ccChan)
        .fix;

        // initialize midi cc value
        // not sure how to find the correct midiout
        // so trying all of them
        MIDIClient.destinations.do({|dest, i|
            order.indices.do({|num|
                var ctrl = order[num];
                var spec = this.getSpec(ctrl);
                var min, max, current, ccval;
                if (spec.isNil) {
                    spec = [0, 1].asSpec;
                };
                min = spec.minval;
                max = spec.maxval;
                current = this.get(ctrl);
                ccval = current.linlin(min, max, 0, 127);
                MIDIOut(i).control(ccChan, num, ccval);
            });
        })
    }

    ccFilter {|ccNum, func|
        var key = "%_ccFilter_%".format(this.key, ccNum).asSymbol;
        Fdef(key, func)
    }

    noteFilter {|func|
        var key = "%_noteFilter".format(this.key).asSymbol;
        Fdef(key, func);
    }

    note {|noteChan, note|

        var noteonkey = "%_noteon".format(this.key).asSymbol;
        var noteoffkey = "%_noteoff".format(this.key).asSymbol;
        var pattern = this.asStream.next(Event.default);
        var out = this.node.bus.index;//pattern[\out] ?? 0;
        var target = this.node.group;
        var instrument = pattern[\instrument] ?? \default;
        var synthdef = SynthDescLib.global.at(instrument);
        var hasGate = synthdef.hasGate;
        var synths = Order.new;
        Halo.put(this.key, \synths, synths);

        /*
        if (MIDIClient.initialized.not) {
            MidiCtrl.connect;
        };
        */

        if (note.isNil) {
            note = (0..110);
        };

        MIDIdef.noteOn(noteonkey, {|vel, note, chan|

            var evt = this.envir ?? {()};
            var args;
            var filter = Fdef("%_noteFilter".format(this.key).asSymbol);

            if (filter.source.notNil) {
                #note, vel = filter.(note, vel);
            };
            // TODO set evt properties on group if we have an nkey
            args = [\out, out, \gate, 1, \freq, note.midicps, \vel, vel/127]
            ++ evt
            .reject({|v, k|
                (v.isNumber.not and: v.isArray.not and: {v.isKindOf(BusPlug).not})
            })
            .asPairs();

            if (hasGate) {
                if (synths[note].isNil) {
                    synths[note] = Synth(instrument, args, target:target, addAction:\addToHead);
                }
            } {
                Synth(instrument, args, target:target);
            }
        }, noteNum:note, chan:noteChan)
        .fix;

        MIDIdef.noteOff(noteoffkey, {|vel, note, chan|
            var filter = Fdef("%_noteFilter".format(this.key).asSymbol);
            if (filter.source.notNil) {
                #note, vel = filter.(note, vel);
            };
            if (hasGate) {
                var synth = synths[note];
                synths.removeAt(note);
                synth.set(\gate, 0);
            }
        }, noteNum:note, chan:noteChan)
        .fix;
    }

    disconnect {
        MIDIdef.noteOn("%_noteon".format(this.key).asSymbol).permanent_(false).free;
        MIDIdef.noteOff("%_noteoff".format(this.key).asSymbol).permanent_(false).free;
        MIDIdef.cc("%_cc".format(this.key).asSymbol).permanent_(false).free;
    }
}
