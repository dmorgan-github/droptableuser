
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

Pparse : Pfunc {
	*new {|key|
		^super.newCopyArgs({|evt|

			var parse = {|val|
				var vals = val.asString.collectAs({|chr| chr.digit/35 }, Array);
				var prob = 1;
				var index = vals[0] * 35;
				if (vals.size > 1) {
					prob = vals[1];
				};
				if (prob.coin.not) {
					Rest(1)
				} {
					index.asInteger;
				}
			};

			var val = evt[key];
			if (val.isRest or: val.isNumber) {
				val
			}{
				if (val.isString) {
					parse.(val);
				} {
					if (val.isArray) {
						val.collect({|v| parse.(v) });
					}
				}
			}
		})
	}
}

// Pdurval
Pdv : Pbind {

	*new {|list, key=\degree|
		^super.new(
			[key, \dur], Prout({|inval|

				var parse = {arg seq, div=1;
					var myval = seq;
					if (myval.class != Ref) {
						// if the value is a ref don't unpack it here
						if (myval.class == Association) {
							div = div * myval.key.asFloat;
						};
						myval = myval.value;
					};

					if (myval.isString.not and: myval.isArray) {
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
							if (myval.isKindOf(Ref)) {
								// if the value is a Ref
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

				var pseq = CollStream(list);
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
Dd : Pattern {

	var list, repeats;

	*new { arg list, repeats=inf;
		^super.newCopyArgs(list, repeats)
	}

	storeArgs { ^[list, repeats] }

	embedInStream {arg inval;

		var parse = {arg seq, div=1;

			var myval = seq;
			if (myval.class != Ref) {
				// if the value is a ref don't unpack it here
				myval = myval.value;
			};

			if (myval.isArray) {
				var myseq = myval;
				var mydiv = 1/myseq.size * div;
				var stream = Pseq(myseq, 1).asStream;
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
					if (myval.isKindOf(Ref)) {
						// if the value is a Ref
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

		var pseq = if (list.isKindOf(Pattern)) {
			list.asStream;
		}{
			Pseq(list, repeats).asStream;
		};

		var item;
		var val = pseq.next;
		while({val.isNil.not}, {
			parse.(val);
			val = pseq.next;
		});
		^inval;
	}
}
*/

/*
// degree, dur
Dd2 {
	*new{arg list, repeats=inf;

		^Routine({
			var parse = {arg seq, div=1;

				var myval = seq;
				if (myval.class != Ref) {
					// if the value is a ref don't unpack it here
					myval = myval.value;
				};

				if (myval.isArray) {
					var myseq = myval;
					var mydiv = 1/myseq.size * div;
					var stream = Pseq(myseq, 1).asStream;
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
						if (myval.isKindOf(Ref)) {
							// if the value is a Ref
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
					[myval, div].yield;
				}
			};

			var pseq = if (list.isKindOf(Pattern)) {
				list.asStream;
			}{
				Pseq(list, repeats).asStream;
			};

			var val = pseq.next;
			while({val.isNil.not}, {
				parse.(val);
				val = pseq.next;
			});
		})
	}
}
*/


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
