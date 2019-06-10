(
/*
noteOn:  #{ arg chan=0, midinote=60, amp=0.1;
noteOff: #{ arg chan=0, midinote=60, amp=0.1;
polyTouch: #{ arg chan=0, midinote=60, polyTouch=125;
control: #{ arg chan=0, ctlNum, control=125;
program:  #{ arg chan=0, progNum=1; [ chan, progNum ] },
touch:  #{ arg chan=0, val=125; [ chan, val ] },
bend:  #{ arg chan=0, val=125; [ chan, val ] },
allNotesOff: #{ arg chan=0; [chan] },
smpte:	#{ arg frames=0, seconds=0, minutes=0, hours=0, frameRate=25;
songPtr: #{ arg songPtr; [songPtr] },
sysex: #{ arg uid, array; [array] } // Int8Array
*/
Pdef(\midi, {arg cmd=\noteOn;
	Pbind(
		\type, \midi,
		\midicmd, cmd,
		\midiout, MIDIOut(0)
	)
});

Pdef(\status,
	Pbind(
		\count, Pseries(0, 1, inf),
		\beatdur, Pfunc({thisThread.clock.beatDur;}),
		\bar, Pfunc({thisThread.clock.beatDur;}),
		\beat, Pfunc({thisThread.clock.beatInBar;}),
		\beatint, Pfunc({thisThread.clock.beatInBar.floor.asInt;})
	)
);
Pdef(\nbind, {arg node, out=0;

	if (node.rate == \audio) {
		if (node.isMonitoring.not) {
			node.play(fadeTime:node.fadeTime, out:out)
		};
	};
	Pbind(
		\type, \set,
		\id, Pfunc({arg evt; node.nodeID;}),
		\args, node.controlNames.collect({arg ctrl; ctrl.name}),
		\trig, 1,
		\beat_dur, Pfunc({thisThread.clock.beatDur}),
		//\amp, Pkey(\amp) * 1,
	)
});

Fdef(\nbind, {arg ndef;
	Pdef(\nbind)
	<> (node:Ndef(ndef))
	<> Pbind(*Ndef(ndef)
		.controlNames
		.reject({arg ctrl; (ctrl.name == \freq) || (ctrl.name == \trig) || (ctrl.name == \buf)})
		.collect({arg ctrl; [ctrl.name, ctrl.defaultValue]}).flatten)
});

Fdef(\stop, {arg key;
	Pdef.all.do({arg item;
		if (item.key.asString.beginsWith(key.asString)) {
			item.stop;
		}
	})
});

{
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
}.();


)