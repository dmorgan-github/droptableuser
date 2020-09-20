(
SynthDef(\rings, {

	var gate = \gate.kr(1);
	var freq = \freq.kr(220) * ([1, Rand(1.0001, 1.01)] ** Rand(-1.0, 1.0));
	var pitch = freq.cpsmidi;

	var struct = \struct.kr(0.5);
	var bright = \bright.kr(0.5);
	var damp = \damp.kr(0.7);
	var pos = \pos.kr(0.25);
	var model = \model.kr(0);
	var poly = \poly.kr(1);

	var sig = MiRings.ar(
		in: 0,
		trig: Impulse.ar(0),
		pit: pitch,
		struct: struct,
		bright: bright,
		damp: damp,
		pos: pos,
		model: model,
		poly: poly
	);

	var aeg = Env.asr(
		\atk.kr(0.01),
		\suslevel.kr(1),
		\rel.kr(1),
		curve: \curve.kr(-4)
	).ar(doneAction:Done.freeSelf, gate:gate);

	/*
	[EVEN, ODD] - In monophonic mode, these two outputs carry two complementary components of the signal
	(odd and even numbered partials with the modal resonator, dephased components due to picking position
	and pickup placement with the string resonators). In polyphonic mode, splits the signal into odd
	and even numbered strings/plates.
	*/
	var which = \evenodd.kr(0);
	var focus = \focus.kr(0);
	sig = SelectXFocus.ar(which, sig, focus);
	sig = sig * aeg * AmpCompA.kr(freq) * \amp.kr(-3.dbamp) * \vel.kr(1);
	sig = Splay.ar(sig, \spread.kr(1), center:\pan.kr(0));
	Out.ar(\out.kr(0), sig);

}, metadata: (
	specs: (
		evenodd: ControlSpec(0, 1, \lin, 1, 0, "timbre" ),
		focus: ControlSpec(0.0, 1.0, \lin, 0, 0, "timbre")
	)
)).add;
)