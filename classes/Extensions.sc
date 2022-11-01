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

    gui {
        Ui('bufinfo').gui(this)
    }
}

+ Float {

    pchance {
        ^Pfunc({ if (this.coin) {1}{Rest(1)} })
    }
}

+ SequenceableCollection {

    pseq {arg repeats=inf, offset=0; ^Pseq(this, repeats, offset) }
    pseq2 {|repeats=inf, offset=0| ^Pseq(this, repeats, offset).noskip }

    prand {arg repeats=inf; ^Prand(this, repeats) }
    pxrand {arg repeats=inf; ^Pxrand(this, repeats) }
    pwrand {arg weights, repeats=inf; ^Pwrand(this, weights.normalizeSum, repeats)}
    pshuf {arg repeats=inf; ^Pshuf(this, repeats) }
    pstep {|durs, repeats=inf| ^Pstep(this, durs, repeats)}
    ppar {|repeats=1| ^Ppar(this.collect({|val|
        if (val.isArray) {val.p} {val}
    }), repeats) }

    pa {
        var a;
        this.pairsDo { |k,v|
            a = a.add(k);
            a = a.add(v.isKindOf(Function).if { Pfunc { |e| e.use { v.() } } }{ v });
        };
        ^a
    }

    p { ^Pbind(*this.pa)}

    place {|repeats=inf| ^Place(this, repeats) }

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

    alt {
        ^this.pseq.asStream
    }

    /*
    pdv {

        var list = this;

        ^Plazy({

            Prout({|inval|

                var parse = {arg seq, div=1;

                    var myval = seq;
                    // if the value is a function don't unpack it here
                    if (myval.isKindOf(Function).not) {
                        if (myval.isKindOf(Association)) {
                            div = div * myval.key.asFloat;
                        };
                        myval = myval.value;
                    };

                    if (myval.isArray) {
                        var myseq = myval;
                        var mydiv = 1/myseq.size * div;
                        var stream = CollStream(myseq);
                        var val = stream.next;
                        while ({val.isNil.not},
                            {
                                parse.(val, mydiv);
                                val = stream.next
                            }
                        );
                    } {
                        if (myval.isRest) {
                            myval = Rest();
                            div = Rest(div);
                        } {
                            if (myval.isKindOf(Function)) {
                                // if the value is a Function
                                // unpack it and use as-is
                                // this allows us to configure chords
                                // and multi-channel expansion
                                myval = myval.value;
                            } {
                                if (myval.isNil) {
                                    div = nil;
                                }
                            }
                        };
                        inval['dur'] = div;
                        inval = myval.value.embedInStream(inval);
                    }
                };

                inf.do({|i|
                    list.asArray.do({|val|
                        parse.(val);
                    })
                });

                inval;
            })

        }).repeat
    }
    */

}

+ Object {

    !! {|val|
        ^Pseq(this.asArray, val)
    }

    |> { |f| ^f.(this) }

	<| { |f|
		^if(f.isKindOf(Function),
			{ {|i| this.( f.(i) )} },
			{ this.(f) })
	}

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

    pfilter {|...args| ^Pbindf(this, *args)}

    pstep {|durs, repeats=inf| ^Pstep(this, durs, repeats)}

    pchain {|...args|
        if (args[0].isKindOf(Symbol)) {
            args = Pbind(*args)
        };
        ^Pchain(this, *args)
    }

    // don't advance pattern on rests
    //clutch {|connected| ^Pclutch(this, connected) }
    //norest { ^Pclutch(this, Pfunc({|evt| evt.isRest.not })) }
    noskip {|key|
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

    doesNotUnderstand {|selector ... args|
        if (selector.isSetter) {
            selector = selector.asGetter;
        };
        ^Pbindf(this, selector.asSymbol, args[0])
    }

    spawn {|func|
        ^Pspawner({|sp|
            var pattern = this.asStream;
            var next = pattern.next(Event.default);
            var iteration = 0;
            while({next.notNil},{
                var vals = func.(next, iteration);
                var dur = next.use({ ~dur.value });
                var stretch = next.use({~stretch.value});
                vals.asArray.do({|val|
                    sp.par(val);
                });
                sp.wait(dur*stretch);
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

+ String {

    ixi {
        ^A.ixi(this)
    }

    mod {|pairs|
        ^(Pbind(*pairs) <> Pbind(\degree, this.ixi.pseq))
    }

    toGrid {
        ^this
        .stripWhiteSpace
        .split($\n)
        .collect({|str| str.parse })
    }

    tag {|tags|
        T.tag(tags, this);
        ^this;
    }

    pdv {
        ^Pdv.parse(this)
    }
}

+ NodeProxy {

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
                if (obj.isKindOf(SSynth)) {
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

    getSettings {
        ^this.getKeysValues.flatten
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

+ EventPatternProxy {

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
}


+ Function {

    // copied from: https://scsynth.org/t/proposal-function-await/6396
	await { |timeout = nil, onTimeout = nil|
		var cond = CondVar(), done = false, res = nil;

		this.value({|...results|
			res = results; done = true;
			cond.signalOne;
		});

		if (timeout.isNil) {
			cond.wait { done }
		} {
			cond.waitFor(timeout) { done }
		};

		if (done.not) {
			if (onTimeout.isFunction) {
				^onTimeout.value
			} {
				AsyncTimeoutError().throw
			}
		};
		^res.unbubble;
	}
}



