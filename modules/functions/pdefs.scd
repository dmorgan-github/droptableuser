(
Pdef(\nbind, {arg node;

	if (node.rate == \audio) {
		if (node.isMonitoring.not) {
			node.play;
		};
	};
	Pbind(
		\type, \set,
		\id, Pfunc({arg evt; node.nodeID;}),
		\args, node.controlNames.collect({arg ctrl;ctrl.name}),
		\trig, 1,
		\beat_dur, Pfunc({thisThread.clock.beatDur}),
		\amp, Pkey(\amp) * 1,
	)
});
)

(
var toMerge = List();
var mergeFunc = {arg events;
		//events.detect({arg e; e[\foo] == 1})
	var event = events.detect({arg e; e[\foo] == 1});
	if (event.isNil.not) {
		event;
	} {
		event = events.detect({arg e; e[\foo] == 2});
		if (event.isNil.not) {
			event;
		}{
			events.choose;
		}
	}
};

Pdef(\t1_filter, Pfunc({arg event;

	// collect parallel events
	if (event[\delta] < 0.000001) {
		toMerge.add(event);
		// replace current event with silence
		event = Event.silent(event[\delta], event);
	} {
		// last parallel event will have non-zero delta
		if (toMerge.size > 0) {
			// add event to accumulation
			toMerge.add(event);
			// call logic to create merged event
			event = mergeFunc.(toMerge).put(\delta, event[\delta]);
			// start all over
			toMerge.clear();
		}
	};
	event;
}));
)