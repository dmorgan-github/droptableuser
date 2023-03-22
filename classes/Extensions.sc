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
        UiModule('bufinfo').gui(this)
    }
}

+ SequenceableCollection {

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

    |> { |f| ^f.(this) }

    <| { |f|
        ^if(f.isKindOf(Function),
            { {|i| this.( f.(i) )} },
            { this.(f) })
    }
}


+ Pattern {

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

+ Array {
    nums { ^this.asInteger.join("").collectAs({|chr| chr.asString.asInteger }, Array) }
}

+ String {

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

    getSettings {
        ^this.getKeysValues.flatten
    }
}

+ EventPatternProxy {

    << {|pattern|
        if (pattern.isArray) {
            pattern = pattern.p;
        };
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
    // consider instead: https://github.com/scztt/Deferred.quark/blob/master/Deferred.sc
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



