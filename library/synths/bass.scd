(
SynthDef(\bass, {

	var gate = \gate.kr(1);
	var freq = \freq.ar(261);

	var adsr = {
		var atk = \atk.kr(0.01);
		var dec = \dec.kr(0.1);
		var rel = \rel.kr(0.1);
		var suslevel = \suslevel.kr(1);
		var ts = \ts.kr(1);
		var curve = \curve.kr(-4);
		var env = Env.adsr(
			attackTime:atk,
			decayTime:dec,
			sustainLevel:suslevel,
			releaseTime:rel,
			curve:curve
		);
		var aeg = env.ar(doneAction:Done.freeSelf, gate:gate, timeScale:ts);
		aeg;
	};

	var aeg = adsr.();

	var op2 = SinOscFB.ar(freq * \op2ratio.kr(0.5), \fb.kr(0.5));
	var op1 = SinOsc.ar(freq, (op2 * \m1_2.kr(0.85)).mod(2pi));
	var sig = op1;

	sig = LeakDC.ar(sig);
	sig = sig * aeg * AmpCompA.ar(freq, 32) * \vel.kr(1);
	sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
	sig = sig * \amp.kr(-6.dbamp);
	Out.ar(\out.kr(0), sig);

})
)
		