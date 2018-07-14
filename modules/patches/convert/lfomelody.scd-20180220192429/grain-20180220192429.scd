/////////////////////////////
c = Buffer.read(s, "/Users/david/projects/droptableuser/workspaces/workspace1/audio.aiff");

/////////////////////////////////////////
TempoClock.default.tempo_(1.5);

(
SynthDef(\grain, {

	var tempo = 1.5;

	var sig1 = {

		var pos = \pos.kr(0.5);
		var buf = \buf.kr(a);
		var dur = \dur.kr(2);
		var jitter = \jitter.kr(2);
		var speed = [\speed1.kr(10), \speed2.kr(20)];

		var sig = GrainBufJ.ar(1,
			Impulse.kr(speed),
			dur: speed.reciprocal * dur,
			sndbuf: buf,
			rate: [1, 1.01],
			pos: pos + LFNoise1.kr(jitter).range(-0.01, 0.01),
			grainAmp: LFNoise2.kr(speed).range(0.1, 1),
			pan: LFNoise2.kr(tempo)
		);

		sig = AllpassC.ar(sig, decaytime: [3, 5]);

	}.value;

	var trig = Impulse.kr( [tempo, tempo * LFPulse.kr(tempo * 0.5).range(4,8) ] ) * LFPulse.kr(tempo * 0.25);

	var env = Env([0,0,1,0], [0, 0.01, 1 ].normalizeSum, [ -24 ]).kr(gate: trig, timeScale: tempo.reciprocal );

	var sig = sig1 * env;

	sig = (sig1 * 0.35) + RLPF.ar(sig, LFTri.kr(tempo * 1/16).range(1000, 4000), 0.25);

	sig = LPF.ar(sig, 4000);

	sig = Splay.ar(Limiter.ar(sig, 0.7));

	OffsetOut.ar(\out.kr(0), sig * 0.5);

}).add;
)

(
Pdef(\grain, Pmono(\grain,
	\pos, Pseq([0.501, 0.401, 0.301, 0.201], inf),
	\delta, 32,
	\buf, c,
	\dur, 4,
	\speed2, 5,
	\speed1, 10,
	\jitter, 0.5))
)
)

~reaper.record();
Pdef(\grain).play;
Pdef(\grain).stop;


b = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/perc2/cy/cymbal-ride-bell.wav");
//////////////////////////////////////
(
SynthDef(\grain_mono, {

	var tempo = 1.5;

	var sig1 = {

		var pos = \pos.kr(0.5);
		var buf = \buf.kr(0);
		var dur = \dur.kr(2);
		var jitter = \jitter.kr(2);
		var speed = \speed.kr(10);
		var rate = \rate.kr(1);
		var spread = \spread.kr(0.1);

		var sig = GrainBufJ.ar(1,
			Impulse.ar(speed),
			dur: speed.reciprocal * dur,
			sndbuf: buf,
			rate: rate,
			pos: pos + LFNoise1.kr(jitter).range(spread.neg, spread),
			grainAmp: LFNoise2.kr(speed).range(0.1, 1),
			pan: LFNoise2.kr(tempo)
		);

		sig;

	}.value;

	var sig = sig1;

	sig = Splay.ar(sig) * \amp.kr(0.1);

	Out.ar(\out.kr(0), sig);

}).add;
)

(
Pdef(\grain, Pmono(\grain_mono,
	\pos, Pseq([0.501, 0.401, 0.301, 0.201], inf),
	\delta, 32,
	\buf, b,
	\dur, 4,
	\speed2, 5,
	\speed1, 10,
	\jitter, 0.5, \amp, 0.5))
)
)

Pdef(\grain).play


(
// use shift-click to keep a node selected
w = Window("envelope", Rect(150 , Window.screenBounds.height - 250, 250, 100)).front;
w.view.decorator = FlowLayout(w.view.bounds);

b = EnvelopeView(w, Rect(0, 0, 230, 80))
    .drawLines_(true)
    .selectionColor_(Color.red)
    .drawRects_(true)
    .resize_(5)
    .step_(0.05)
    .action_({arg b; [b.index, b.value, b.curves].postln})
    .thumbSize_(5)
    .value_([[0.0, 0.1, 0.5, 1.0],[0.1,1.0,0.8,0.0]]);
w.front;
)

b.setFillColor(2,[Color.yellow, Color.white, Color.green].choose)
b.setEnv(Env([0,1,0.7,0.6,0],[0.01,1,1,1],[-4,-4, 4, -20]));