Ptrn {

    *wrapAt {|vals, index|
        index = index.asStream;
        vals = vals.asStream;
        ^Pfunc({|evt|
            var i = index.next(evt);
            var v = vals.next(evt);
            if (i.isNumber) {
                v.wrapAt(i)
            }{
                Rest(1)
            }
        })
    }

    *env {|key, dur=16|
        ^Prout({|inval|
            inf.do({
                var env, vals, size;
                var startTime;
                startTime = thisThread.endBeat ? thisThread.beats;
                thisThread.endBeat = dur + startTime;
                while ({ thisThread.beats < thisThread.endBeat }, {
                    vals = inval[key];
                    size = vals.size;
                    env = Env(vals, dur/size, 0);
                    inval = env.at(thisThread.beats - startTime).embedInStream(inval)
                });
            });
            inval
        })
    }

    *par {|...args|

        var keys = List.new;
        var vals = List.new;
        args.pairsDo({|k, v| keys.add(k); vals.add(v) });

        ^Ppar(
            vals
            .flop
            .collect({|v, i|
               keys.collect({|k, i| [k, v[i]] }).flatten.p
            })
        )
    }
}


Ppub : EventPatternProxy {

    var <spawner;

    *new {|topic, pattern|
        var res;
        res = Pdef.all[topic];
        if (res.isNil) {
            res = super.new(nil);
            Pdef.all.put(topic, res);
        };
        if (pattern.isNil.not) {
            res.prInit(topic, pattern)
        };
        ^res;
    }

    prInit {|argTopic, argPattern|

        this.source = Pspawner({|sp|
            var stream = argPattern.asStream;
            var ptrn = stream.next(Event.default);
            var count = 0;
            spawner = sp;
            while ({ptrn.isNil.not},{
                var dur = ptrn[\dur] ?? 1;
                var topics = (ptrn[\topic] ?? \a).asArray;
                topics.do({|topic|
                    Evt.trigger(topic, (sp:sp, evt:ptrn, dur:dur, count:count));
                });
                //Evt.trigger(argTopic, (sp:sp, evt:ptrn, dur:dur, count:count));
                sp.wait(dur);
                count = count + 1;
                ptrn = stream.next(Event.default);
            });
        });
        ^this;
    }
}

Psub : EventPatternProxy {

    var <isPlaying=false;

    *new {|key, topic, pattern, condition|
        var res;
        res = Pdef.all[key];
        if (res.isNil) {
            res = super.new(nil);
            Pdef.all.put(key, res);
        };
        if (pattern.isNil.not) {
            res.prInit(key, topic, pattern, condition)
        };
        ^res;
    }

    prInit {|key, topic, pattern, condition|

        this.source = Event.silent;

        if (condition.isKindOf(Pattern)) {
            condition = condition.asStream;
        };

        if (pattern.isNil) {
            Evt.off(topic, key);
        }{
            Evt.on(topic, key, {|dict|
                var evt = dict[\evt];
                var count = dict[\count];
                var dur = dict[\dur];
                evt[\count_] = count;
                evt[\dur] = dur;

                if (this.isPlaying) {
                    if (condition.isNil) {
                        var sp = dict[\sp];
                        sp.par(pattern.value <> evt);
                    }{
                        if (evt.use(condition.next)) {
                            var sp = dict[\sp];
                            sp.par(pattern.value <> evt);
                        }
                    }
                }
            });
        }
    }

    play {
        isPlaying = true;
    }

    stop {
        isPlaying = false;
    }

    *initClass {
        //isPlaying = false;
    }
}

Pphrase {
    *new {|key, outer, inner|
        var instrument = (key ++ '_inner').asSymbol;
        var func = if (inner.isKindOf(Function)) { inner }{ {inner} };
        Pdef(instrument, func);
        ^Pdef(key.asSymbol, Pbind(\type, \phrase, \instrument, instrument) <> outer);
    }
}


Pdur{
    *new {|k=1, n=1, div=\beat, offset=0, repeats=inf|

        switch (div,
            \euclid, {
                k = if (k.isKindOf(Array)) {k.pseq}{k};
                n = if (n.isKindOf(Array)) {n.pseq}{n};
                ^Pbjorklund2(k, n, repeats, offset)
            },
            \beat, {
                ^Pn(k/n, repeats)
            },
            \bar, {
                ^Pn(n/k, repeats)
            }
        )
    }
}


Pchance {
    *new {|prob=(0.5)|
        ^Pfunc({ if (prob.coin) {1}{0} })
    }
}


Pmap {
    *new{|k, n, lo, hi, offset=0, repeats=inf|
        ^Pbjorklund(k, n, repeats, offset).linlin(0, 1, lo, hi)
    }
}


// Only pull a value once per clock time - else, return the previous value
// https://gist.github.com/scztt/e53046e866e75e48bff1b62311da96eb
PtimeClutch : FilterPattern {
    var <>delta;

    *new {
        |pattern, delta=0.0|
        ^super.new(pattern).delta_(delta);
    }

    embedInStream {
        |input|
        var lastTime, lastVal;
        var stream = pattern.asStream;

        loop {
            var thisTime = thisThread.beats;

            if (lastTime.isNil or: { (thisTime - lastTime) > delta }) {
                lastVal = stream.next(input);
                lastTime = thisTime;
            };

            input = lastVal.copy.yield;
        }
    }
}


//https://gist.github.com/eleses/8704f7abaea8d42c22b5eca527db5f48
PfsetC : FuncFilterPattern {
    //making cleanupFunc a member var would be a mistake; stream resets would overwrite it before it calling it!
    *new { |func, pattern|
        ^super.new(func, pattern)
    }
    embedInStream { arg inevent;
        var event, cleanup = EventStreamCleanup.new;
        var cleanupFunc, envir = Event.make({ cleanupFunc = func.value() });
        var stream = pattern.asStream;
        var once = true;

        loop {
            inevent.putAll(envir);
            event = stream.next(inevent);
            if(once) {
                cleanup.addFunction(event, { |flag|
                    envir.use({ cleanupFunc.value(flag) });
                });
                once = false;
            };
            if (event.isNil) {
                ^cleanup.exit(inevent)
            } {
                cleanup.update(event);
            };
            inevent = yield(event);
            if(inevent.isNil) { ^cleanup.exit(event) }
        };
    }
}

Pwnrand : ListPattern {
    var <>weights;

    *new { arg list, weights, repeats=1;
        ^super.new(list, repeats).weights_(weights)
    }

    embedInStream {  arg inval;
        var item, weightsVal, repeatStream;
        var weightsStream = Ptuple(weights).asStream;
        repeatStream = repeats.asStream;
        repeatStream.next(inval).do({ arg i;
            weightsVal = weightsStream.next(inval);
            if(weightsVal.isNil) { ^inval };
            weightsVal = weightsVal.extend(list.size, 0);
            weightsVal = weightsVal.normalizeSum;
            item = list.at(weightsVal.windex);
            inval = item.embedInStream(inval);
        });
        ^inval
    }
    storeArgs { ^[ list, weights, repeats ] }
}

