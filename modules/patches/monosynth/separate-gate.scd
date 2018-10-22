TempoClock.default.tempo_(45/60)

/////////////////////////////////////////
// arp
~p[\arp].clear;
~p[\arp].mold;
(~p[\arp][0] = {

    var trig = \trig.tr;
	var freq = Vibrato.kr(\freq.kr(432).lag(\lag.kr(0)), \vrate.kr(6), \vdepth.kr(0.0));

	var susLevel = \susLevel.kr(0.5);
	var curve = \curve.kr(4);
	//var env = Env.adsr(releaseTime:2).kr(gate:trig);
	var env = Env.linen(releaseTime:2).kr(gate:trig);

	var sig = {
		[
			{
				var sig = VarSaw.ar(freq, width: SinOsc.kr(1/8).exprange(0.4,0.6));
				sig = DFM1.ar(sig, 880, 0.1);
				sig
			},
			{
				var sig = SinOsc.ar(freq.lag(0.02) * [1, 1.01], 0).tanh;
				sig.sum;
			},
			{
				var sig = PinkNoise.ar;
				sig
			}
		] * [0.7, 0.5, 0.05].normalizeSum

	}.();

	sig = RLPF.ar(sig, env.exprange(440, 3300), 0.3);
	sig = sig * env * AmpCompA.kr(freq) * \amp.kr(-12.dbamp);
	sig = LPF.ar(sig, 880);
	sig = Splay.ar(sig.sum);
	sig = FbC({arg fb; HPF.ar(fb * 0.5 + sig, 220)}, [3/8, 5/8] * 0.75.reciprocal + 1) * 0.7 + sig;
	sig = BPeakEQ.ar(sig, 200, 1, 3) + (JPverb.ar(sig, 10, 0, 5) * 0.5) + sig;
	//sig = JPverb.ar(sig, 5, 0, 5, modDepth:0.5) * 0.5 + sig;
	sig;
};
//~p[\arp].addSpec(\param, [0.0, 1.0, \lin, 0.0, 0.4]);
);

~p[\arp].play(fadeTime:4);
~p[\arp].stop(fadeTime:10);
~arp_win = App.guiHelper(~p[\arp], "arp");
~arp_win.front;

(
Pbindef(\arp,
	\type, \set,
	\id, Pfunc({~p[\arp].nodeID}),
	\args, #[\amp, \freq, \vdepth, \trig],
	\trig, 1,
	\root, 2,
	\degree, Pseq(Scale.zhi.degrees.scramble.pyramid(2), inf),
	\octave, Pbjorklund(3, 8, inf).collect({arg val; if (val == 0){3}{5}}),
	\vdepth, 0.008,
	\dur, 0.5,
	\amp, -30.dbamp
)
)

(
~p[\arp][2] = nil\set -> Pbind(
	\args, #[\amp, \freq, \vdepth, \trig],
	\trig, 1,
	\root, 2,
	\degree, Pseq(Scale.zhi.degrees.scramble.pyramid(2), inf),
	\octave, Pbjorklund(3, 8, inf).collect({arg val; if (val == 0){3}{5}}),
	\vdepth, 0.008,
	\dur, 0.5,
	\amp, -30.dbamp//Pwhite(-6.dbamp, -3.dbamp)
);
)


~bufs[\arp] = Buffer.alloc(s, 44100 * 4, 2);
(
~p[\rec][0] = {
	var in = ~p[\arp].ar;
	RecordBuf.ar(in, ~bufs[\arp]);
	0;
}
)


