(
SynthDef(\elements, {

	var gate = 1;//\gate.kr(1);
	var freq = \freq.kr(220);

	var osc = {

		var blow_in = \blowin.kr(0);
		var strike_in = LPF.ar(Impulse.ar(0), 10000);//\strikein.kr(0);
		var pit = freq.cpsmidi;
		var strength = \strength.kr(0.5);
		var contour = \contour.kr(0.2);
		var bow_level = \bowlevel.kr(0);
		var blow_level = \blowlevel.kr(0);
		var strike_level = \strikelevel.kr(0);
		var flow = \flow.kr(0.5);
		var mallet = \mallet.kr(0.5);
		var bow_timb = \bowtimb.kr(0.5);
		var blow_timb = \blowtimb.kr(0.5);
		var strike_timb = \striketimb.kr(0.5);
		var geom = \geom.kr(0.5);
		var bright = \bright.kr(0.5);
		var damp = \damp.kr(0.7);
		var pos = \pos.kr(0.2);
		var space = \space.kr(0.3);
		var model = \model.kr(0);

		MiElements.ar(
			blow_in, strike_in, gate, pit, strength, contour,
			bow_level, blow_level, strike_level,
			flow, mallet,
			bow_timb, blow_timb, strike_timb,
			geom, bright, damp, pos, space, model
		);
	};

	var aeg = Env.perc.kr(doneAction:Done.freeSelf, gate:gate);
	var sig = osc.();
	sig = sig * aeg * \amp.kr(0.3) * AmpCompA.kr(freq) * \vel.kr(1);
	Out.ar(\out.kr(0), sig);

}).add
)