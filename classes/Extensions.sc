+ Symbol {

    kr { | val, lag, fixedLag = false, spec |
        var name = "%%".format(this, ~num ?? {""});
        if (currentEnvironment[this].notNil ) {
            "replacing namedcontrol".debug(this);
            ^currentEnvironment[this].value
        } {
            ^NamedControl.kr(name, val, lag, fixedLag, spec)
        }
	}

	ir { | val, spec |
        var name = "%%".format(this, ~num ?? {""});
		if (currentEnvironment[this].notNil ) {
            "replacing namedcontrol".debug(this);
            ^currentEnvironment[this].value
        } {
            ^NamedControl.ir(name, val, spec:spec)
        }
	}

	tr { | val, spec |
        var name = "%%".format(this, ~num ?? {""});
		if (currentEnvironment[this].notNil ) {
            "replacing namedcontrol".debug(this);
            ^currentEnvironment[this].value
        } {
            ^NamedControl.tr(name, val, spec:spec)
        }
	}

	ar {| val, lag, spec |
        var name = "%%".format(this, ~num ?? {""});
		if (currentEnvironment[this].notNil ) {
            "replacing namedcontrol".debug(this);
            ^currentEnvironment[this].value
        } {
            ^NamedControl.ar(name, val, lags:lag, spec:spec)
        }
	}
}

+ Buffer {

    view {
        U(\bufinfo, this)
    }
}

+ AbstractFunction {

    pchoose {|iftrue, iffalse|
        ^Pif(Pfunc(this), iftrue, iffalse)
    }
    pfunc { ^Pfunc(this) }

    plazy { ^Plazy(this) }

    cc {|ccNum, ccChan=0, spec|
        var cckey = "cc_%_%".format(ccNum, ccChan).asSymbol.debug("mididef");
        if (spec.notNil) {
            spec = spec.asSpec;
        };
        MIDIdef.cc(cckey, {|val, num, chan|
            if (spec.notNil) {
                val = spec.map(val/127);
            };
            this.value(val, num, chan);
        }, ccNum:ccNum, chan:ccChan)
        .fix;

        // TODO: fix this
        if (spec.notNil) {
            MIDIClient.destinations.do({|dest, i|
                var val = spec.default;
                var ccval = val.linlin(spec.minval, spec.maxval, 0, 127);
                try {
                    MIDIOut(i).control(ccChan, ccNum, ccval);
                } {|err|
                    "midi out: %".format(err).warn;
                }

            })
        }
    }
}

+ SequenceableCollection {

    pseq {arg repeats=inf, offset=0; ^Pseq(this, repeats, offset) }
    prand {arg repeats=inf; ^Prand(this, repeats) }
    pxrand {arg repeats=inf; ^Pxrand(this, repeats) }
    pwrand {arg weights, repeats=inf; ^Pwrand(this, weights.normalizeSum, repeats)}
    pshuf {arg repeats=inf; ^Pshuf(this, repeats) }
    pstep {|durs, repeats=inf| ^Pstep(this, durs, repeats)}

    pa {
        var a;
        this.pairsDo { |k,v|
            a = a.add(k);
            a = a.add(v.isKindOf(Function).if { Pfunc { |e| e.use { v.() } } }{ v });
        };
        ^a
    }

    p { ^Pbind(*this.pa)}

    playTimeline {|clock=(TempoClock.default)|
        this.collect({|assoc|
            var beat = assoc.key;
            var func = assoc.value;
            clock.sched(beat, { beat.debug(\beat); func.value; nil } );
        });
    }

    cycle {|dur=8, len, repeats=inf|
        ^this.p.cycle(dur, len, repeats);
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
}

+ Pattern {

    limit {arg num; ^Pfin(num, this.iter) }
    step {arg dur, repeats=inf; ^Pstep(this, dur, repeats)}
    latchprob {arg prob=0.5; ^Pclutch(this, Pfunc({ if (prob.coin){0}{1} }))}

    // not sure how best to use pfilter vs pchain
    // or if it really matters
    // pattern is probably too general of a base class
    // for this
    doesNotUnderstand {|selector ... args|
        if (selector.isSetter) {
            selector = selector.asGetter;
        };
        ^Pbindf(this, selector.asSymbol, args[0])
    }

    pfilter {|...args| ^Pbindf(this, *args)}

    inval {|...args|
        if (args[0].isKindOf(Symbol)) {
            args = Pbind(*args)
        };
        ^Pchain(this, *args)
    }

    // don't advance pattern on rests
    //clutch {|connected| ^Pclutch(this, connected) }
    //norest { ^Pclutch(this, Pfunc({|evt| evt.isRest.not })) }
    latch {|key|
        ^Pclutch(
            this,
            Pfunc({|evt|
                var connected = true;
                if (evt.isRest) {
                    connected = false
                }{
                    if (key.notNil) {
                        connected = evt[key].asBoolean
                    }
                };
                connected
            })
        )
    }

    cycle {|dur=8, len, repeats=inf|
        var iteration = -1;
        if (len.isNil) {len = dur};
        ^Plazy({
            iteration = iteration + 1;
            Psync(this.finDur(len), dur, dur) <> (cycle:iteration);
        }).repeat(repeats)
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

    seed {|val| ^Pseed(val, this)}

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

    // don't think this is necessary
    /*
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
        MIDIdef.cc(cckey, {|val, num, chan|
            var mapped;
            var ctrl = order[num];
            var spec = this.getSpec(ctrl).ifnil([0, 1].asSpec);
            var filter = Fdef("%_ccFilter_%_%".format(this.key, num, chan).asSymbol);
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
    */

    cc {|ctrl, ccNum, ccChan=0|
        var order = Order.newFromIndices(ctrl.asArray, ccNum.asArray);
        var cckey = "%_cc_%".format(this.key, ccChan).asSymbol.debug("mididef");
        MIDIdef.cc(cckey, {|val, num, chan|
            var mapped, ctrl, spec, filter;
            ctrl = order[num];
            spec = this.getSpec(ctrl);
            filter = Fdef("%_ccFilter_%_%".format(this.key, num, chan).asSymbol);
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
                if (current.notNil) {
                    ccval = current.linlin(min, max, 0, 127);
                    [\curent, current, \cc, ccval].debug(ctrl);
                    try {
                        MIDIOut(i).control(ccChan, num, ccval);
                    } {|err|
                        "midi out: %".format(err).warn;
                    }
                }
            });
        })
    }

    ccFilter {|ccNum, ccChan=0, func|
        var key = "%_ccFilter_%_%".format(this.key, ccNum, ccChan).asSymbol.debug("cc filter");
        Fdef(key, func)
    }

    noteFilter {|func, noteChan=0|
        var key = "%_noteFilter_%".format(this.key, noteChan).asSymbol.debug("note filter");
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

    // TODO: refactor
    disconnect {
        MIDIdef.noteOn("%_noteon".format(this.key).asSymbol).permanent_(false).free;
        MIDIdef.noteOff("%_noteoff".format(this.key).asSymbol).permanent_(false).free;
        MIDIdef.cc("%_cc".format(this.key).asSymbol).permanent_(false).free;
    }
}
