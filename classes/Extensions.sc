+ AbstractFunction {
    pchoose {|iftrue, iffalse|
        ^Pif(Pfunc(this), iftrue, iffalse)
    }
    pfunc { ^Pfunc(this) }
}

+ Integer {
    peuclid {arg beats, offset=0, repeats=inf; ^Pbjorklund(this, beats, repeats, offset)}
    peuclid2 {arg beats, offset=0, repeats=inf; ^Pbjorklund2(this, beats, repeats, offset)}
}

+ Number {
    incr {arg step, repeats=inf; ^Pseries(this, step, inf)}
}

+ SequenceableCollection {
    pseq {arg repeats=inf, offset=0; ^Pseq(this, repeats, offset) }
    prand {arg repeats=inf; ^Prand(this, repeats) }
    pxrand {arg repeats=inf; ^Pxrand(this, repeats) }
    pwrand {arg weights, repeats=inf; ^Pwrand(this, weights.normalizeSum, repeats)}
    pshuf {arg num=1, repeats=inf; ^Pn(Pshuf(this, num), repeats) }
    step {|durs, repeats=inf| ^Pstep(this, durs, repeats)}
    pdv {|repeats=inf, key='degree'| ^Pdv(this, key).repeat(repeats) }

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

    playTimeline {|clock|
        this.collect({|assoc|
            var beat = assoc.key;
            var func = assoc.value;
            clock.sched(beat, { beat.debug(\beat); func.value; nil } );
        });
    }
}

+ Pattern {
    limit {arg num; ^Pfin(num, this.iter) }
    step {arg dur, repeats=inf; ^Pstep(this, dur, repeats)}
    latchprob {arg prob=0.5; ^Pclutch(this, Pfunc({ if (prob.coin){0}{1} }))}
    latch {arg func; ^Pclutch(this, Pfunc(func)) }
    // don't advance pattern on rests
    norest { ^Pclutch(this, Pfunc({|evt| evt.isRest.not })) }
    s {|...args| ^Pbindf(this, *args)}
    c {|...args| ^Pchain(this, *args) }
    octave {|val| ^Pbindf(this, \octave, val)}
    atk {|val| ^Pbindf(this, \atk, val)}
    dec {|val| ^Pbindf(this, \dec, val)}
    rel {|val| ^Pbindf(this, \rel, val)}
    suslevel {|val| ^Pbindf(this, \suslevel, val)}
    curve {|val| ^Pbindf(this, \curve, val)}
    harmonic {|val| ^Pbindf(this, \harmonic, val)}
    amp {|val| ^Pbindf(this, \amp, val)}
    vel {|val| ^Pbindf(this, \vel, val)}
    detunehz {|val| ^Pbindf(this, \detunehz, val)}
    mtranspose {|val| ^Pbindf(this, \mtranspose, val)}
    legato {|val| ^Pbindf(this, \legato, val)}
    degree {|val| ^Pbindf(this, \degree, val)}
    strum {|val| ^Pbindf(this, \strum, val)}
    every {|beats, maxdur, lag=0, repeats=inf|
        ^Pseq([
            Psync(Plag(lag, this.finDur(maxdur)), beats, beats)
        ], repeats)
    }
    m {|name, value| ^Pmul(name, value, this)}
    a {|name, value| ^Padd(name, value, this)}
    //s {|name, value| ^Pset(name, value, this)}
    pdef {|key| ^Pdef(key, this)}
}

+ String {

    /*
    (
    Pdef(\kit, "
    9.9.....9....9..
    ..9..99.1273365.
    ....7.4.....9..3
    .......4
    ".hits(
    [instrument: \smplr_1chan, buf: B.bd, dur: 1, stretch: 0.125, amp: 1].p,
    [instrument: \smplr_1chan, buf: B.ch, dur: 1, stretch: 0.125, vel: 0.6].p,
    [instrument: \smplr_1chan, buf: B.sd, dur: 1, stretch: 0.125].p,
    [instrument: \smplr_1chan, buf: B.oh, dur: 1, stretch: 0.125].p
    ))
    )
    */
    hits {|...args|

        var pattern = this.stripWhiteSpace.split(Char.nl);
        var seq = pattern.collect({|val, i|
            Pbind(\hit, Prout({
                inf.do({
                    var stream = CollStream(val);
                    var next = stream.next;
                    while({next.isNil.not}, {
                        if (next == $.){
                            Rest(1).yield;
                        }{
                            var prob = next.digit/9;
                            if (prob.coin) { 1.yield }{ Rest(1).yield; };
                        };
                        next = stream.next;
                    });
                });
            })
            )
        });

        args = args.flatten;
        ^Ppar(
            seq.collect({|seq, i|
                args.wrapAt(i) <> seq
            });
        )
    }

    probs {
        var val = this;
        ^Pbind(\hits,
            Prout({|evt|
                inf.do({
                    var stream = CollStream(val);
                    var next = stream.next;
                    while({next.isNil.not}, {
                        if (next == $.){
                            Rest(1).yield;
                        }{
                            var prob = next.digit/9;
                            if (prob.coin) { 1.yield }{ Rest(1).yield; };
                        };
                        next = stream.next;
                    });
                });
            })
        );
    }
}

+ Array {
    nums { ^this.asInteger.join("").collectAs({|chr| chr.asString.asInteger }, Array) }
}

+ Symbol {

    def {
        var synthdef = SynthDescLib.global.at(this);
        if (synthdef.isNil.not) {
            ^synthdef.controlDict;
        }
    }

    p {|...args|

        /*
        p(\foo, 1, \bar, 2) will be converted to Pbind(\foo, 1, \bar, 2)
        p([foo: 1, bar:2]) will be converted to Pbind(\foo, 1, \bar, 2)
        p(Pbind(\foo, 1, \bar, 2)) will remain as is
        */

        var base, ptrn;//, envir;
        var vals = this.asString.split($/);

        base = {
            var instr = vals[0].asSymbol;
            Pbind(\instrument, instr);
        };

        ptrn = {
            var pattern = args[0];
            pattern = case
            {pattern.isKindOf(Array)} { pattern.p; }
            {pattern.isKindOf(Symbol)} { args.p; }
            {pattern.isKindOf(Pattern)} { pattern;}
            {pattern.isNil} {Pbind()}
            { Error("invalid argument").throw };

            pattern;
        };

        /*
        envir = {
        if (args[0].isKindOf(Symbol)) {
        () // not sure
        } {
        args[1..].asEvent
        }
        };
        */

        if (args.isEmpty) {
            if (Pdef(this).source.isNil) {
                ^Pdef(this, base.())
            }{
                ^Pdef(this)
            }
        }{
            ^Pdef(this, ptrn.() <> base.())
        }
    }

    out {
        var node = Ndef(this);
        if (node.monitor.isNil) {node.play};
        ^node.forPattern;
    }
}

+ NodeProxy {

    debugScope {
        this.bus.debugScope();
    }

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
        ^this.getKeysValues.flatten.asDict;
    }

    /*
    preset {
        var key = this.key;
        NdefPreset(key); // make a preset instance
        ProxyPresetGui(NdefPreset(key)); // and it's GUI. stores preset as text file
    }
    */

    fx {|index, fx|

        if (fx.isNil) {
            this[index] = nil;
        }{
            var obj = N.loadFx(fx);
            var func = obj[\synth];
            var specs = obj[\specs];
            this.filter(index, func);
            if (specs.isNil.not) {
                specs.do({|assoc|
                    this.addSpec(assoc.key, assoc.value);
                })
            };
            this.addSpec("wet%".format(index).asSymbol, [0, 1, \lin, 0, 1].asSpec);
            "added % at index %".format(fx, index).postln;
        }

    }

    vst {|index, vst, id, cb|

        var node = this;

        if (vst.isNil) {
            node[index] = nil;
        }{
            var mykey = node.key ?? "n%".format(node.identityHash.abs);
            var vstkey = vst.asString.select({|val| val.isAlphaNum});
            var nodekey = mykey.asString.replace("/", "_");
            var key = "%_%".format(nodekey, vstkey).toLower.asSymbol;
            var server = Server.default;
            var nodeId, ctrl;

            Routine({

                if (node.objects[index].isNil) {

                    var path = App.librarydir ++ "vst/" ++ vst.asString ++ ".scd";
                    var pathname = PathName(path.standardizePath);
                    var fullpath = pathname.fullPath;

                    if (File.exists(fullpath)) {
                        var name = pathname.fileNameWithoutExtension;
                        var obj = File.open(fullpath, "r").readAllString.interpret;
                        node.filter(index, obj[\synth]);
                    } {
                        node.filter(index, {|in|
                            if (id.isNil.not) {
                                VSTPlugin.ar(in, 2, id:id);
                            }{
                                VSTPlugin.ar(in, 2);
                            }
                        });
                    };
                    1.wait;
                };

                nodeId = node.objects[index].nodeID;
                ctrl = if (node.objects[index].class == SynthDefControl) {
                    var synthdef = node.objects[index].synthDef;
                    var synth = Synth.basicNew(synthdef.name, server, nodeId);
                    if (id.isNil.not) {
                        VSTPluginController(synth, id:id, synthDef:synthdef);
                    }{
                        VSTPluginController(synth, synthDef:synthdef);
                    }
                }{
                    var synth = Synth.basicNew(vst, server, nodeId);
                    if (id.isNil.not) {
                        VSTPluginController(synth, id:id);
                    }{
                        VSTPluginController(synth);
                    }
                };
                ctrl.open(vst, verbose: true, editor:true);
                "loaded %".format(key).postln;
                if (cb.isNil.not) {
                    cb.value(ctrl);
                }{
                    currentEnvironment[key] = ctrl;
                }

            }).play;

        }
    }
}

+ S {
    kb {
        ^U(\kb, this);
    }
    nscope {
        ^U(\scope, this.node);
    }
    microlab {
        Microlab().note(
            {|note, vel|
                vel = 127/vel;
                this.on(note, vel);
            },
            {|note|
                this.off(note);
            }
        );
    }
}

+ Pdef {
    sgui {
        ^U(\sgui, this);
    }

    << {|pattern|
        ^this.source = pattern;
    }
}
