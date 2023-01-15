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

/**
+Pattern {

    << { arg aPattern;
        // time-based pattern key merging
        ^PtimeChain(this, aPattern)
    }

}
*/

/*
https://gist.github.com/scztt/87bf6542e3cd60844113fd201258a82a
Play many patterns according to their own delta's', composing the events from bottom to top.
Deltas of first pattern are responsible for timing of output events

(
 Pdef(\ptchain).clear;
 Pdef(\ptchain, PTChain(
 	Pbind(
 		\dur, Pseg([1/32, 1/2, 1/32], [16, 16], \exponential, inf),
 		\velocity, Pwhite(40, 127),
 		\strum, Pkey(\dur) / 2
 	),
 	Pbind(
 		\degree, Ptuple([Pkey(\degreeA), Pkey(\degreeB)])
 	),
 	Pbind(
 		\dur, 1/3,
 		\degreeA, Ptuple([
 			Pseq([0, 2, 6, 8, 5], inf),
 		])
 	),
 	Pbind(
 		\dur, 2,
 		\degreeB, Ptuple([
 			12 + Pseq([0, -6], inf),
 		])
 	),
 )).play
)
*/
PTChain : Pattern {
	var <>patterns;

	*new { arg ... patterns;
		^super.newCopyArgs(patterns);
	}

	*durs { arg durs ... patterns;
		^super.newCopyArgs(
			[Pbind(\dur, durs)] ++ patterns
		);
	}

	<< { arg aPattern;
		var list;
		list = patterns.copy.add(aPattern);
		^this.class.new(*list)
	}

	embedInStream { arg inval;
		var structureStream = patterns[0].asStream;
		var startTime = thisThread.beats;
		// Store the value streams, their current time and latest Events
		var valueStreams = patterns[1..].collect{ |p| [p.asStream, (), ThreadStateScope() ] };
		var inevent, cleanup = EventStreamCleanup.new;
		var timeEpsilon = 0.0001;
		loop {
			var structureEvent;
			var cumulativeEvent = inevent = inval.copy;
			// inevent.debug("inevent at start of loop");

			valueStreams.reverseDo { |strData, i|
				var valueStream, nextValueEvent, threadState;
				#valueStream, nextValueEvent, threadState = strData;
				while {
					// "stream: %    current time: %     stream time: %    timeToCheck: %".format(
					// 	valueStream,
					// 	thisThread.beats - startTime,
					// 	threadState.beats - startTime,
					// 	(thisThread.beats - startTime) + timeEpsilon
					// ).debug;
					threadState.beats <= (thisThread.beats + timeEpsilon);
				} {
					var delta;

					threadState.use {
						if (inevent !== cumulativeEvent) {
							inevent.parent_(cumulativeEvent);
						};
						nextValueEvent = valueStream.next(inevent);
						// "\tpulled new value: %".format(nextValueEvent).postln;
					};
					// nextValueEvent.debug("nextValueEvent");
					// Q: Should we exit for value streams that end, or just the structure stream?
					// A: Will have to look at concrete examples, for now: yes, we exit when
					//    any of the streams ends...
					if (nextValueEvent.isNil) { ^cleanup.exit(inval) };
					delta = nextValueEvent.delta.value;

					if (delta.notNil) {
						threadState.beats = threadState.beats + delta;
					} {
						// There is no time information, just use our next value
						// for the next structure Event (as regular Pchain would do)
						threadState.beats = threadState.beats + (timeEpsilon * 2);
					};

					// nextValueTime.debug("nextValueTime updated");
					// inevent feeds from one into the next, gathering/replacing values
					strData[1] = nextValueEvent;
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
			// structureTime.debug("structureTime");
		};
	}

	storeOn { arg stream;
		stream << "(";
		patterns.do { |item,i|  if(i != 0) { stream << " <> " }; stream <<< item; };
		stream << ")"
	}
}

ThreadStateScope {
	var beats, endBeat;

	*new {
		^super.newCopyArgs(thisThread.beats, thisThread.endBeat);
	}

	use {
		|function|
		var oldValues;

		if (beats.isNil) { beats = thisThread.beats };
		if (endBeat.isNil) { endBeat = thisThread.endBeat };

		protect {
			oldValues = [thisThread.beats, thisThread.endBeat];
			thisThread.beats = beats;
			thisThread.endBeat = endBeat;

			function.()
		} {
			this.beats = thisThread.beats;
			endBeat = thisThread.endBeat;

			thisThread.beats = oldValues[0];
			thisThread.endBeat = oldValues[1];
		}
	}

	beats_{
		|value|
		if (value.isNil) {
			"setting beats to nil... weird".postln;
		};
		beats = value;
	}

	beats {
		^(beats ?? { 0 })
	}

	endBeat {
		^(endBeat ?? { 0 })
	}
}
