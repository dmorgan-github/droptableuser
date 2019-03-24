/////////////////////////////////////////
// synth
~p[\synth].clear;
~p[\synth].mold;
(~p[\synth][0] = {

    var trig = \trig.tr;
	var freq = Vibrato.kr(\freq.kr(432).lag(\lag.kr(0)), \vrate.kr(6), \vdepth.kr(0.0));

	var susLevel = \susLevel.kr(0.5);
	var curve = \curve.kr(4);
	var env = Env(
		[0,\peakLevel.kr(1),susLevel,susLevel,0],
		[\atk.kr(0.001), \decay.kr(0.3), \sus.kr(1), \rel.kr(1)],
		curve:[curve,curve.neg]
	).kr(gate:trig);

	var sig = [
		{
			// noise source
			var sig = PinkNoise.ar;
			sig = RLPF.ar(sig, [60, 80], 0.001) * 2;
			sig = FbC({arg fb; fb * SinOsc.kr(1/32).range(0.7, 1) + sig}, LFNoise2.kr(1/32).range(1/8, 1/2)).tanh;
			sig = PitchShift.ar(sig, 0.5, [12, 7, 19].midiratio) + sig;
			sig = BLowPass4.ar(sig, SinOsc.kr(1/64).range(880, 4400), SinOsc.kr(SinOsc.kr(1/128).range(1/4,4)).range(0.3, 0.6));
			sig = SoftClipAmp8.ar(PitchShift.ar(sig, 0.5, 15.midiratio), SinOsc.kr(1/64).range(1,2)) * 0.3 + sig;
			sig = JPverb.ar(sig, 2, 0, 2) * 0.5 + sig;

			Splay.ar(sig);
		}
	].collect(_.value) * [1].normalizeSum;

	sig = sig * AmpCompA.kr(freq) * \amp.kr(-25.dbamp);
	sig = Splay.ar(sig, spread:\spread.kr(1), level:1, center:\center.kr(0));
	sig;
};
//~p[\synth].addSpec(\param, [0.0, 1.0, \lin, 0.0, 0.4]);
);
~p[\synth].play;
~p[\synth].stop;
~synth_win = App.guiHelper(~p[\synth], "synth");
~synth_win.front;