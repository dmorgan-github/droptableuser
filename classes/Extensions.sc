+ Fdef {
    update {|obj, what ... args| this.value(obj, what, *args) }
}

+ M {

    // shortcuts
    *def {|func|
        ^Module(func)    
    }

    // synths
    *squine { ^Module('synth/squine') }
    *sampler { ^Module('synth/sampler') }
    *grainr { ^Module('synth/grainr') }
    *rings { ^Module('synth/rings') }
    *elements { ^Module('synth/elements') }
    *analog { ^Module('synth/pulsesaw') }
    *kick { ^Module('synth/kick2') }
    *wt { ^Module('synth/oscos') }

    // filters
    *moogff { ^Module('filter/moogff') }
    *lpf12db { ^Module('filter/lpf12db') }
    *lpf24db { ^Module('filter/lpf24db') }
    *lpg { ^Module('filter/lpg') }

    // fx
    *rev { ^Module('fx/reverb/miverb') }
    *del { ^Module('fx/delay/fb') }
    *longdel { ^Module('fx/delay/fb_long') }
    *crush { ^Module('fx/distortion/crush') }
    *softclip { ^Module('fx/distortion/softclip') }
    *distortion { ^M('fx/distortion/analogtape')}
    *eq { ^Module('fx/eq/beq') }
    //*eq { ^M.vst('MEqualizer.vst3') }
    *compress { ^M('fx/dynamics/compress') }

    *pitchshift { ^Module('fx/granular/pitchshift') }
    *vst {|id| ^"vst:%".format(id).asSymbol }

    // aeg
    *adsr { ^Module('env/adsr') }
    *asr { ^Module('env/asr') }
    *perc { ^Module('env/perc') }
    *linen { ^Module('env/linen') }
    *none { ^Module('env/none') }

    // pitch
    *unison { ^Module('pitch/unison') }
}

+ SimpleNumber {

    t {|instr ...args|
        // TODO: instantiating a new instance each time
        // doesn't make sense - just not sure what the interface should be
        var track = T();
        var num = this;
        track.put(num, instr, *args);
        //track[num].synthdefmodule.set(*args)
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
    c {|...vals|
        ^Routine({
            inf.do({
                var myvals = [this] ++ vals;
                myvals.choose.value.yield
            })
        })  
    }

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

    // https://monome.org/docs/norns/reference/lib/lfo
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

    saw {|freq, min, max|
        var val;
        if (freq.notNil) {
            val = Ndef(this, { LFSaw.kr(freq, iphase:1).linlin(-1, 1, min, max) });
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

    play {|loop = false, mul = 1|
        //if(bufnum.isNil) { Error("Cannot play a % that has been freed".format(this.class.name)).throw };
        //var numChannels = buf.numChannels.debug("numChannels");
        var outbus = 4; Server.default.options.numInputBusChannels.debug("wtf");
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


