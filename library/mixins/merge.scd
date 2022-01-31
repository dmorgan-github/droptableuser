(
var toMerge = List();
var mergeFunc = {arg events;
		//events.detect({arg e; e[\foo] == 1})
    /*
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
    */

    var nonrest = events.detect({|e| e.isRest.not });
    if (nonrest.isNil.not) {
        nonrest
    } {
        events.choose
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