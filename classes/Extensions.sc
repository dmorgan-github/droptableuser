+ ExecuteCommandProvider {
    *commands {
        ^(
            'supercollider.internal.bootServer': {
                Server.default.boot;
            },
            'supercollider.internal.rebootServer': {
                Server.default.reboot;
            },
            'supercollider.internal.killAllServers': {
                Server.killAll();
            },
            'supercollider.internal.showServerWindow': {
                Server.default.makeWindow()
            },
            'supercollider.internal.showServerMeter': {
                Server.default.meter()
            },
            'supercollider.internal.showScope': {
                Server.default.scope()
            },
            'supercollider.internal.showFreqscope': {
                Server.default.freqscope()
            },
            'supercollider.internal.dumpNodeTree': {
                Server.default.queryAllNodes()
            },
            'supercollider.internal.dumpNodeTreeWithControls': {
                Server.default.queryAllNodes(true)
            },
            'supercollider.internal.plotTree': {
                Server.default.plotTree()
            },
            'supercollider.internal.startRecording': {
                //Server.default.record()
                T.daw.goToEnd.record
            },
            'supercollider.internal.pauseRecording': {
                Server.default.pauseRecording()
            },
            'supercollider.internal.stopRecording': {
                //Server.default.stopRecording()
                T.daw.stopRecording
            },
            'supercollider.internal.cmdPeriod': {
                CmdPeriod.run();
            },
            'supercollider.internal.media': {
                M('device/media').().ui
            },
            'supercollider.internal.mixer': {
                T.daw.mixer
            }
        )
    }    
}

+ VSTPluginController {

    discover {

        // // c.getn(0, c.numParameters, { |data| data.postln });
        var ctrl = this;
        var params = ctrl.info.parameters;
        var vals = Dictionary();
        var rout;

        rout = Routine({

            4.do({|i|
                params.do({|v|
                    var name = v['name'];
                    ctrl.get(name, action:{|f|
                        var val = vals[name];
                        if (val.isNil) {
                            vals.put(name, f);
                        } {
                            if (val != f) {
                                [name, f].postln;
                            }
                        }
                    })
                });
                4.wait;
            })
        });

        rout.play;
    }
}

+ Fdef {
    update {|obj, what ... args| this.value(obj, what, *args) }
    doOnStartUp { this.value }
	doOnCmdPeriod { this.value }
	doOnShutDown { this.value }
	doOnError { this.value }
	doOnServerBoot { arg server; this.value(server) }
	doOnServerQuit { arg server; this.value(server) }
	doOnServerTree { arg server; this.value(server) }
}

+ SimpleNumber {

    // this is maybe not a great idea ??
    /*
    doesNotUnderstand {|selector ...args|
        [selector, args].debug("SimpleNumberdoesNotUnderstand.");
        if (selector.notNil ) {
            var key = selector.asSymbol;
            var track = T(key);
            var num = this;
            var instr = nil;
            var val;
            if (args.size > 0) {
                instr = args[0];
                args = args[1..];
            };

            val = track[num];
            if (val.isNil) {
                val = track.put(num, instr, *args);
            };
            ^val
        }
    }
    */

    /*
    a {|instr ...args|
        var track = T('a');
        var num = this;
        track.put(num, instr, *args);
        ^track[num];
    }

    b {|instr ...args|
        var track = T('b');
        var num = this;
        track.put(num, instr, *args);
        ^track[num];
    }

    c {|instr ...args|
        var track = T('c');
        var num = this;
        track.put(num, instr, *args);
        ^track[num];
    }

    d {|instr ...args|
        var track = T('d');
        var num = this;
        track.put(num, instr, *args);
        ^track[num];
    }
    */

    t {|instr ...args|
        var track = T('t');
        var num = this;
        track.put(num, instr, *args);
        ^track[num];
    }
}

+ Object {

    // non embedding sequencer
    q {|...vals|
        ^Routine({
            var myvals;
            myvals = this.asArray;
            myvals = myvals ++ vals;

            inf.do({
                myvals.do({|v|
                    v.value.yield;
                })
            })
        });
    }

    // choose
    // c {|...vals|
    //     ^Routine({
    //         inf.do({
    //             var myvals = [this] ++ vals;
    //             myvals.choose.value.yield
    //         })
    //     })
    // }

    // euclid
    e {|n, o=0|
        ^Routine({
            inf.do({
                var vals = Bjorklund2(this.value, n.value);
                vals.size.do({|i|
                    vals.wrapAt(i + o).yield;
                })
            })
        })
    }

    // exprand
    x {|hi|
        ^Routine({
            inf.do({
                var lo = this;
                exprand(lo, hi).yield
            })
        })
    }

    k {|key|
        var tracknum = this;
        var node = InstrTrack()[tracknum];
        key = key.asSymbol;
        // this is less than perfect
        // can only use this for scalar values
        // calling value will advance any routine
        inf.do({
            node.get(key).yield
        })
    }

    idx {|list, index|
        ^Prout({|inval|
            var listStream = list.asStream;
            var indexStream = index.asStream;
            inf.do({|i|
                var myindex = indexStream.next(inval);
                var mylist = listStream.next(inval);
                var val = \;
                if (myindex.isRest.not) {
                    val = mylist.wrapAt(myindex)
                };
                inval = val.embedInStream(inval);
            })
        })
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
}

+ Buffer {

    gui {
        UiModule('bufinfo').gui(this)
    }

    play {|loop = false, mul = 1|
        //if(bufnum.isNil) { Error("Cannot play a % that has been freed".format(this.class.name)).throw };
        //var numChannels = buf.numChannels.debug("numChannels");
        var outbus = 4; Server.default.options.numInputBusChannels;//.debug("wtf");
        ^{|player|
            player = PlayBuf.ar(numChannels, bufnum, BufRateScale.kr(bufnum),
                loop: loop.binaryValue);
            if(loop.not, FreeSelfWhenDone.kr(player));
            player * mul;
        }.play(Server.default, outbus: outbus)
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

    /*
    playTimeline {|clock=(TempoClock.default)|
        this.collect({|assoc|
            var beat = assoc.key;
            var func = assoc.value;
            clock.sched(beat, { beat.debug(\beat); func.value; nil } );
        });
    }
    */

    cycle {|dur=8, len, repeats=inf|
        ^this.p.cycle(dur, len, repeats);
    }
}

/*
+ EventPatternProxy {

    @ {|val, adverb|
        this.set(adverb, val);
        ^this;
    }
}
*/

+ Pattern {

    limit {arg num; ^Pfin(num, this.iter) }
    latchprob {arg prob=0.5; ^Pclutch(this, Pfunc({ if (prob.coin){0}{1} }))}
    pstep {|durs, repeats=inf| ^Pstep(this, durs, repeats)}

    /*
    pchain {|pattern|
        // pattern flows right to left <-
        ^Pchain(this, pattern)
    }
    */

    // i want the interface to be left to right
    pmutate {|pattern|
        ^Pchain(pattern, this)
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
        ^Pdv2.parse(this, repeats)
    }

    dig {
        ^this
        .replace(Char.space, "")
        .collectAs({|l|
            if (l == $.) {
                \
            } {
                l.digit;
            }
        }, Array);
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


