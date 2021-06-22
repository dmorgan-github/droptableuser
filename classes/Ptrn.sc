Pmatrix : Pattern {

    var <>key, <>src, <>matrix, <>fx, <>pattern;

    *new {|key, src, matrix, fx, srcvol=1|

        var ptrn;
        var m = M(key);
        var srcNode = Ndef(src);
        if (srcNode.monitor.isNil) {
            "playing node to init for audio".debug(\pmatrix);
            srcNode.play(vol:srcvol);
        };
        srcNode.vol = srcvol;

        m.addSrc(srcNode);
        fx.do({|pfilter|
            m.addSrc(Ndef(pfilter.key));
        });

        m.map.do({|src, row|
            m.map.do({|dest, col|
                if (matrix[row].isNil.not) {
                    if (matrix[row].size > col) {
                        var mix = matrix[row][col];
                        if (mix > 0) {
                            [dest.key, src.key, mix].debug(\pmatrix);
                            dest.mix(row, src, mix);
                        } {
                            dest.set(src.key, 0);
                        }
                    }
                }
            });
        });

        ptrn = Pbind(
            \out, Pfunc({srcNode.bus.index}),
            \group, Pfunc({srcNode.group})
        ) <> Pchain(*fx);

        ^super.new.key_(key).src_(src).matrix_(matrix).fx_(fx).pattern_(ptrn)
    }

    storeArgs { ^[ key, src, matrix, fx ] }

    embedInStream {|inval|
        ^this.pattern.embedInStream(inval);
    }
}

Pnodeset : Pattern {

    var <>key, <>pattern;

    *new {|key ...pairs|
        var ptrn, node;
        node = Ndef(key);
        ptrn = Pchain(
            Pbind(
                "%_func".format(key).asSymbol, Pfunc({|evt|
                    var keys = pairs.select({|val, i| i.even}).flatten;
                    var mypairs = List.new;

                    keys.do({|k|
                        if (evt[k].isNil.not) {
                            mypairs.add(k);
                            mypairs.add(evt[k]);
                        };
                    });
                    //mypairs.asArray.postln;
                    if (mypairs.size > 0) {
                        node.set(*mypairs.asArray);
                    };
                    1
                })
            ),
            Pbind(*pairs)
        );
        ^super.new.key_(key).pattern_(ptrn);
    }

    storeArgs { ^[ key ] }

    embedInStream {|inval|
        ^this.pattern.embedInStream(inval);
    }
}

Pfilter : Pattern {

    var <>key, <>pattern, <>fx, <>vol;

    *new {|key, fx, vol ...pairs|
        var ptrn, node;
        if (fx.isFunction) {
            node = Ndef(key);
            node.play(vol:vol);
            node.filter(100, fx);
        }{
            node = N(key).fx_(fx);
        };

        node.vol = vol;
        ptrn = Pchain(
            Pbind(
                "%_func".format(key).asSymbol, Pfunc({|evt|
                    node.getKeysValues.do({|pair|
                        var name = pair[0];
                        if (evt[name].isNil.not) {
                            //[name, evt[name]].postln;
                            node.set(name, evt[name]);
                        }
                    });
                    1
                })
            ),
            Pbind(*pairs)
        );
        ^super.new.key_(key).pattern_(ptrn).fx_(fx).vol_(vol)
    }

    storeArgs { ^[ key, fx, vol ] }

    embedInStream {|inval|
        ^this.pattern.embedInStream(inval);
    }
}

Pchannel {
    *new {|key, vol=1|
        var node = Ndef(key);
        node.play(vol:vol);
        ^Plazy({
            Pbind(
                \out, Pfunc({node.bus.index}),
                \group, Pfunc({node.group})
            )
        });
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

/*
+Pattern {
timeClutch {
|delta=0.0|
^PtimeClutch(this, delta)
}
}
*/

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

// Pdurval
Pdv : Pbind {

    *new {|list, key=\val|
        ^super.new(
            [key, \dur], Prout({|inval|
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
                        inval = [myval, div].embedInStream(inval);
                    }
                };

                var pseq = CollStream(list.asArray);
                var item;
                var val = pseq.next;
                while({val.isNil.not}, {
                    parse.(val);
                    val = pseq.next;
                });
                inval;
            })
        );
    }
}


/*
from: https://scsynth.org/t/time-aware-merging-of-two-event-pattern-streams/1482/10
var a = Pbind(\degree, Pseq(degs, 1), \dur, noteDur);
var b = Pbind(\instrument, Pseq([\a,\b,\c], inf), \dur, 3.reciprocal);
var c = Pbind(\pan, Pseq([-1, 1], inf), \dur, 2.reciprocal);
// Can also be written (a << b << c)
var results = PtimeChain(a, b, c).asStream.nextN(degs.size+1, ());
*/
PtimeChain : Pattern {
    var <>patterns;

    *new { arg ... patterns;
        ^super.newCopyArgs(patterns);
    }

    << { arg aPattern;
        var list;
        list = patterns.copy.add(aPattern);
        ^this.class.new(*list)
    }
    embedInStream { arg inval;
        var structureStream = patterns[0].asStream;
        // Store the value streams, their current time and latest Events
        var valueStreams = patterns[1..].collect{ |p| [p.asStream, 0, ()] };
        var inevent, cleanup = EventStreamCleanup.new;
        var structureTime = 0;
        var timeEpsilon = 0.0001;
        loop {
            var structureEvent;
            var cumulativeEvent = inevent = inval.copy;
            // inevent.debug("inevent at start of loop");
            valueStreams.reverseDo { |strData, i|
                var valueStream, nextValueTime, nextValueEvent;
                #valueStream, nextValueTime, nextValueEvent = strData;
                // [i, nextValueTime, nextValueEvent].debug("next time/Event");
                while {
                    nextValueTime <= (structureTime + timeEpsilon);
                } {
                    var delta;
                    nextValueEvent = valueStream.next(inevent);

                    // nextValueEvent.debug("nextValueEvent");
                    // Q: Should we exit for value streams that end, or just the structure stream?
                    // A: Will have to look at concrete examples, for now: yes, we exit when
                    //    any of the streams ends...
                    if (nextValueEvent.isNil) { ^cleanup.exit(inval) };
                    delta = nextValueEvent.delta.value;
                    if (delta.notNil) {
                        nextValueTime = nextValueTime + delta;
                    } {
                        // There is no time information, just use our next value
                        // for the next structure Event (as regular Pchain would do)
                        nextValueTime = structureTime + (timeEpsilon * 2);
                    };
                    // nextValueTime.debug("nextValueTime updated");
                    // Store the values for our next iteration
                    strData[1] = nextValueTime;
                    // inevent feeds from one into the next, gathering/replacing values
                    strData[2] = nextValueEvent;
                };

                // Combine the contributions of all the "current" value events
                // that came before the main structure event.
                cumulativeEvent = cumulativeEvent.composeEvents(nextValueEvent);
                // cumulativeEvent.debug("updated cumulativeEvent");
            };

            structureEvent = structureStream.next(cumulativeEvent);
            if (structureEvent.isNil) { ^cleanup.exit(inval) };
            cleanup.update(structureEvent);
            // structureEvent.debug("yielded structureEvent");
            inval = yield(structureEvent);
            structureTime = structureTime + structureEvent.delta.value;
            // structureTime.debug("structureTime");
        };
    }

    storeOn { arg stream;
        stream << "(";
        patterns.do { |item,i|  if(i != 0) { stream << " <> " }; stream <<< item; };
        stream << ")"
    }
}

+Pattern {

    << { arg aPattern;
        // time-based pattern key merging
        ^PtimeChain(this, aPattern)
    }

}
