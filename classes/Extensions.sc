+ SimpleNumber {

    t {|instr ...args|
        // TODO: instantiating a new instance each time
        // doesn't make sense - just not sure what the interface should be
        var track = T();
        var num = this;
        if (instr.notNil) {
            track.put(num, instr, *args);
            //track[num].synthdefmodule.set(*args)
        };
        ^track[num];
    }

    // euclid
    e {|n, o=0|
        ^Pbjorklund2(this, n, offset:o)    
    }
}

+ Symbol {

    kr { | val, lag, fixedLag = false, spec |
        var name = "%%".format(this, ~num ?? {""});
        //[this, currentEnvironment[this]].debug("kr");
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

    // refer to https://github.com/cappelnord/BenoitLib/blob/master/patterns/Pkr.sc
    // for possible variant to work with patterns
    // Ndef(\cutoff).bus.getSynchronous
    sine {|freq, min, max|
        var val;
        if (freq.notNil) {
            val = Ndef(this, { SinOsc.kr(freq, 1.5pi).linlin(-1, 1, min, max) });
        } {
            val = Ndef(this)
        };
        val.asCompileString.postln;
        ^val;
    }

    tri {|freq, min, max|
        var val;
        if (freq.notNil) {
            val = Ndef(this, { LFTri.kr(freq, iphase:3).linlin(-1, 1, min, max) });
        } {
            val = Ndef(this)
        };
        val.asCompileString.postln;
        ^val;
    }

    rampup {|freq, min, max|
        var val;
        if (freq.notNil) {
            val = Ndef(this, { LFSaw.kr(freq, iphase:1).linlin(-1, 1, min, max) });
        } {
            val = Ndef(this)
        };
        val.asCompileString.postln;
        ^val;
    }

    rampdown {|freq, min, max|
        var val;
        if (freq.notNil) {
            val = Ndef(this, { LFSaw.kr(freq.neg, iphase:1).linlin(-1, 1, min, max) });
        } {
            val = Ndef(this)
        };
        val.asCompileString.postln;
        ^val;
    }
}

+ Buffer {

    gui {
        UiModule('bufinfo').gui(this)
    }
}

+ SequenceableCollection {

    // lace
    l {|o=0|
        ^Place2(this, inf, offset:o)
    }

    pseq {arg repeats=inf, offset=0; ^Pseq(this, repeats, offset) }
    prand {arg repeats=inf; ^Prand(this, repeats) }
    pxrand {arg repeats=inf; ^Pxrand(this, repeats) }
    pwrand {arg weights, repeats=inf; ^Pwrand(this, weights.normalizeSum, repeats)}
    pshuf {arg repeats=inf; ^Pshuf(this, repeats) }
    pstep {|durs, repeats=inf| ^Pstep(this, durs, repeats)}
    ppar {|repeats=1|
        if (this.first.isKindOf(Pattern) ) {

            ^Ppar(this.collect({|val|
                if (val.isArray) {val.p} {val}
            }), repeats)
        } {
            ^Ptrn.par(*this);
        }
    }
    
    ptpar {|times, repeats=1|

        var vals = this.collect({|v, i|
            [times.wrapAt(i), v]
        });

        ^Ptpar(vals.flatten, repeats)
    }

    pdef {|key| ^Pdef(key, this) }

    pa {
        var a;
        this.pairsDo { |k,v|
            a = a.add(k);
            a = a.add(v.isKindOf(Function).if { Pfunc { |e| e.use { v.() } } }{ v });
        };
        ^a
    }

    p {
        if (this.pa.size > 0) {
            ^Pbind(*this.pa)
        } {
            ^Pbind()
        }
    } 

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

+ Pattern {

    // euclid
    e {|n, o=0|
        ^Pbjorklund2(this, n, offset:o)    
    }

    limit {arg num; ^Pfin(num, this.iter) }
    latchprob {arg prob=0.5; ^Pclutch(this, Pfunc({ if (prob.coin){0}{1} }))}
    pstep {|durs, repeats=inf| ^Pstep(this, durs, repeats)}

    pchain {|...args|
        if (args[0].isKindOf(Symbol)) {
            args = Pbind(*args)
        };
        ^Pchain(this, *args)
    }

    timeClutch {|delta=0.0|
        ^PtimeClutch(this, delta)
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

    cycle {|dur=8, len, offset=0, repeats=inf|
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
}

+ String {

    tag {|tags|
        Tag.tag(tags, this);
        ^this;
    }

    pdv {|repeats=inf|
        ^Pdv.parse(this, repeats)
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
                if (obj.isKindOf(InstrProxy)) {
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
}


