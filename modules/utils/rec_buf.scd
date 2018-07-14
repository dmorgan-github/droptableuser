(
Ndef(\soundin, {
	SoundIn.ar([0,1]);
});
Ndef(\soundin_m, {
	SoundIn.ar([0]);
})
)

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
Ndef(\rec_buf_m,{

	var in = \in.ar([0]);
	var buf = \buf.kr();
	RecordBuf.ar(in,
		buf,
		recLevel:\rlvl.kr(1),
		preLevel:\plvl.kr(0),
		loop:\loop.kr(0),
		trigger:\trig.kr(0)
	);
})
)

(
~rec_buf_ui = {
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
}
)