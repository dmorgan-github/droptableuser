// degree, dur
Dd {
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
							// this allows use to chords
							// and multi-channel expansion
							myval = myval.value;
						};
					};
					[myval, div].yield;
				}
			};

			var pseq = Pseq(list, repeats).asStream;
			inf.do({
				var val = pseq.next;
				parse.(val);
			});
		})
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
					//nextValueEvent = valueStream.next(inevent);
					nextValueEvent = valueStream.next(cumulativeEvent.copy);

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
