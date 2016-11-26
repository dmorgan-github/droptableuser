(
ProxySynthDef(\s6, {

	var lag = \lag.kr(0.12);
	var freq = \freq.kr(440).varlag(lag, -4);
	var trig = \trig.tr;
	var amp = \amp.kr;
	var rel = \rel.kr(1);
	var atk = \atk.kr(0.01);

	//var env = Decay2.ar(T2A.ar(trig), attackTime: atk, decayTime: rel, mul: amp * AmpCompA.kr(freq) );
	var env = Decay2.ar(K2A.ar(trig), attackTime: atk, decayTime: rel );
	var sig = Saw.ar(freq, mul: env * 2 ).tanh;
	var fenv = Decay2.ar(T2A.ar(trig),
		attackTime:\fatk.kr(0.01),
		decayTime: \fdecay.kr(1), mul: \fmul.kr(2), add: \fratio.kr(2) );
	sig = RLPF.ar(sig, freq * fenv, \q.kr(0.21) );
	sig = LPF.ar(sig, \lpf.kr(600));
	sig = Mix(sig) * amp * AmpCompA.kr(freq);
	GVerb.ar(sig, 300, 1, drylevel:0.9);

}).add;

)
///////////////////////////////////////////
~s6 = App.monoDevice(\s6);
(
var matrix = [
	[0, [1 -> 0.7, 3 -> 0.3]],
	[2, [1 -> 0.5, 2 -> 0.5]],
	[3, [2 -> 0.6, 0 -> 0.4]],
	[5, [2 -> 0.5, 3 -> 0.5]]
];

var degrees = ~pmarkov.(matrix);
~s6.node.fadeTime = 5;
~s6.pattern.set(

	\degree, degrees,
	\scale, Pstep(Pseq([Scale.harmonicMinor, Scale.ritusen, Scale.chromatic], inf), Pseq([2], inf), inf),
	\root, 0,
	\octave, Prand([3, 4], inf),
	\delta, Pseq([1, 0.5, 1, 2.5, 1, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1, 2.5, 1,1, 0.5,
		0.5, 0.5, 0.5, 1, 2, 1.5, 1, 0.5, 0.5, 1, 1.5, 3, 1, 1, 0.5, 0.5, 0.5], inf) * 0.25,

	\dur, Pkey(\delta),

	\fratio, Pgauss(6, 1, inf),
	\fmul, Pgauss(3, 1.5, inf),
	\fdecay, 1,
	\q, Pwhite(0.09, 0.2, inf),
	\lpf, Pgauss(1100, 200, inf),

	\amp, 0.02
));
~s6.player.play;
~s6.player.stop;