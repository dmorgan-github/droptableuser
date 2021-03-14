//from
//https://gist.github.com/scztt/536ecc746d4afbfc4094d7e99f7e1c71
+ Bus {
    debugScope {
        | title, names |
        var w, ms, listArray, size=380, sliderLoc=0, routine, bus,
        min=1000.0, max=(-1000.0), minBox, maxBox, val=0, valBox, synth, m, n, bottom,
        playSynthFunction, cmdPeriodFunction;

        cmdPeriodFunction = {};

        title = title ? "bus %".format( index );

        m = 0.0; n=0.0;
        w = Window( title, Rect( 0, 0, 510, 510 ), scroll:true);
        w.view.hasHorizontalScroller = false;

        listArray = Array.fill(200,0.0) ! numChannels;

        // playSynthFunction = {
        // 	{ Out.kr( this.index, this.kr ) }.play(target: server.defaultGroup);
        // };
        // synth = playSynthFunction.();

        ms = Array.newClear( numChannels );
        maxBox = Array.newClear( numChannels );
        minBox = Array.newClear( numChannels );
        valBox = Array.newClear( numChannels );

        min = 0 ! numChannels;
        max = 0 ! numChannels;

        numChannels.do({
            | i |
            var comp;
            var margin = 5;
            var y = (i*121);
            comp = CompositeView( w, Rect( 0, y, 500, 120) )
            .resize_(2)
            .background_(Color.grey);
            StaticText( comp, Rect( 20, 40, 350, 40 ))
            .font_( Font("M+ 1c", 34) )
            .stringColor_( Color.grey(0.8) )
            .string_( names.notNil.if({ names[i] }, { i + index }) );
            ms[i] = MultiSliderView( comp, Rect( 0, 0, 400, 120).insetBy(margin,margin) )
            .value_(listArray[i])
            .elasticMode_(true)
            .editable_(false)
            .background_(Color.clear)
            .xOffset_(2)
            .drawLines_(true)
            .thumbSize_(1)
            .drawRects_(false)
            .resize_(2);
            maxBox[i] = DragSink( comp, Rect(400, 0, 100, 24).insetBy(margin,margin))
            .font_( Font("M+ 1c", 12) )
            .mouseDownAction_({ |obj| max[i]=(-1000.0) })
            .string_(" " + 0.asString)
            .resize_(3);

            minBox[i] = DragSink( comp, Rect(400, 120-24, 100, 24).insetBy(margin,margin))
            .font_( Font("M+ 1c", 12) )
            .mouseDownAction_({ |obj| min[i]=(1000.0) })
            .string_(" " + 0.asString)
            .resize_(3);

            valBox[i] = DragSink( comp, Rect(400, 60-7, 100, 24).insetBy(margin,margin))
            .font_( Font("M+ 1c", 12) )
            .string_(" " + 0.asString)
            .stringColor_(Color.green)
            .resize_(3);

            bottom = comp.bounds.top + comp.bounds.height;
        });
        w.bounds = w.bounds.height_( max( min( bottom+10, 510 ), 60 ) );

        routine =  SkipJack({
            var vals = this.getnSynchronous(this.numChannels).asArray;
            vals.do({
                | val, i |
                var aMin, aMax;
                if( val > max[i], {max[i] = val});
                if( val < min[i], {min[i] = val});
                minBox[i].string_( " " + min[i].asString[0..7] );
                maxBox[i].string_( " " + max[i].asString[0..7] );
                valBox[i].string_(" " + val.asString[0..7] );
                listArray[i] = listArray[i].copyRange(1, 198) ++ [val];
                ms[i].value_( (listArray[i]-min[i])/(max[i]-min[i]) );
            })
        },
        dt: 0.1,
        name: "debugScope",
        clock: AppClock
        );
        routine.start;

        CmdPeriod.add(cmdPeriodFunction);


        w.onClose = {
            routine.stop;
            synth.free;
            CmdPeriod.remove(cmdPeriodFunction);
        };

        w.front;
    }
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
    pdv {|repeats=inf, key='val'| ^Pdv(this, key).repeat(repeats) }

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
    f {|...args| ^Pbindf(this, *args)}
    c {|...args| ^Pchain(this, *args) }
    every {|beats, maxdur, lag=0, repeats=inf|
        ^Pseq([
            Psync(Plag(lag, this.finDur(maxdur)), beats)
        ], repeats)
    }
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

    addFx {|fx, wet=1, index|
        var idx = if (index.isNil) { (this.objects.indices.last ?? 0) + 10}{index};
        var obj = N.loadFx(fx);
        var func = obj[\synth];
        var specs = obj[\specs];
        this.filter(idx, func).set("wet%".format(idx).asSymbol, wet);
        if (specs.isNil.not) {
            specs.do({|assoc|
                this.addSpec(assoc.key, assoc.value);
            })
        };
        this.addSpec("wet%".format(idx).asSymbol, [0, 1, \lin, 0, 1].asSpec);
        "added % at index %".format(fx, idx).debug(this.key);
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
                    this.put(index, {obj.ar * Control.names([key]).kr(vol) });
                };
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

    preset {
        var key = this.key;
        NdefPreset(key); // make a preset instance
        ProxyPresetGui(NdefPreset(key)); // and it's GUI. stores preset as text file
    }
}

+ S {
    kb {
        ^U(\kb, this);
    }
    view {
        ^U(\sgui, this);
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
}
