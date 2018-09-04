(
Ndef(\rec_buf,{

	var in = \in.ar([0,0]);
	var buf = \buf.kr();
	RecordBuf.ar(in,
		buf,
		recLevel:\rlvl.kr(1),
		preLevel:\plvl.kr(0),
		loop:\loop.kr(0),
		trigger:\trig.kr(0)
	);
});

//rlvl = EnvGen.kr(Env.asr(0.05, 1.0, 0.05), PulseCount.kr(t_trig, t_reset) % 2);
Ndef(\rec_buf_m,{

	var in = \in.ar([0]);
	var buf = \buf.kr();
	RecordBuf.ar(in,
		buf,
		recLevel:\rlvl.kr(1),
		preLevel:\plvl.kr(0),
		loop:\loop.kr(0),
		trigger:\trig.kr(0),
		doneAction:Done.none
	);
});
)

Ndef(\rec_buf_m) <<> Ndef(\soundin_m);
Ndef(\rec_buf_m).set(\preLevel, 1);

(
Fdef(\button_on, {
	Ndef(\rec_buf_m).set(\trig, 1)
});
Fdef(\button_off, {
	Ndef(\rec_buf_m).set(\trig, 0)
})
)

Mixer

///////////////////////////////////
// UI
(
var view = View().layout_(VLayout().margins_(5));
view.layout.add(Button()
	.states_([
		["start", Color.black, Color.red],
		["stop", Color.white, Color.black]
	])
	.action_({arg ctrl;
		if (ctrl.value == 1) {
			Fdef(\button_on).value;
		} {
			Fdef(\button_off).value;
		};
		ctrl.value.postln;
	})
);
view.front;
)