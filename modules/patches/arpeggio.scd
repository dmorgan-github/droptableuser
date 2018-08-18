/////////////////////////////////////////
// proxy space
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(60/60);


/////////////////////////////////////////
// sq
~p[\sq].clear;
~p[\sq].mold;
(~p[\sq][0] = {

	var trig = \trig.tr;
	var freq = Vibrato.kr(\freq.kr(432), 6, 0.007);
	var sig = {
		var sig = VarSaw.ar(freq.lag(0), width:SinOsc.kr(1/32).range(0.4, 0.7));//.fold2(1);
		sig = sig + (Pulse.ar(freq.lag(0.1) * 2) * 0.2);
		sig;
	}.();
	var env = Env.perc.kr(gate:trig);
	sig = sig * env * AmpCompA.kr(freq);
	sig = Pan2.ar(sig, \pan.kr(0));
	sig;
});
~p[\sq].play;
~p[\sq].stop;
~p[\sq].gui;

(
var circle = Library.at(\circle);
~p[\sq][2] = \set -> Pbind(
    \trig, 1,
	\scale, Scale.dorian,
	\detune, Pwhite(-3, 3),
	\degree, Pseq([
		Pseq(circle[\fifth].reverse, 2),
		Pseq(circle[\second], 2),
		Pseq(circle[\seventh].reverse, 2),
		Pseq(circle[\first], 2)
	], inf),
	\dur, Pseq([1,1,2], inf) * 0.5
));

/////////////////////////////////////////
// seq
~p[\seq].mold;
(~p[\seq][0] = {
    var freq = \freq.kr;
	var trig = \trig.tr;
	[freq, trig];
});
(~p[\seq][1] = \set -> Pbind(
	\trig, 1,
	\delta, 1,
	\degree, 0
))


~p[\s1].clear;
~p[\s1].mold;
(~p[\s1][0] = {

	var seq = ~p[\seq].kr;
	var freq = seq[0];
	var trig = seq[1];
	var freq_ratio = 1;
	var index = freq * freq_ratio * 3;
	var mods = ~p[\s1].ar + ~p[\s2].ar;
	var sig = Saw.ar(freq + mods * index);
	sig;

});
~p[\s1].play;
~p[\s1].stop;
~p[\s1].gui;


~p[\s2].clear;
~p[\s2].play
~p[\s2].stop;
~p[\s2].mold;
(~p[\s2][0] = {

	var seq = ~p[\seq].kr;
	var freq = seq[0];
	var trig = seq[1];
	var freq_ratio = 1;
	var index = freq * freq_ratio * 3;
	var mods = ~p[\s1].ar + ~p[\s2].ar;
	var sig = Saw.ar(freq + mods * index);
	sig;

});
~p[\s2].play;
~p[\s2].stop;
~p[\s2].gui;

(
var circle = Library.at(\circle);
~p[\s1][2] = \set -> Pbind(
    \trig, 1,
	\scale, Scale.dorian,
	\detune, Pwhite(-3, 3),
	\degree, Pseq([
		Pseq(circle[\fifth].reverse, 2),
		Pseq(circle[\second], 2),
		Pseq(circle[\seventh].reverse, 2),
		Pseq(circle[\first], 2)
	], inf),
	\dur, Pseq([1,1,2], inf) * 0.5
));



/////////////////////////////////////////
// fx1
(~p[\fx1][0] = {
	var in = ~p[\fx2].ar;
	var fx = FbC({arg fb; fb * 0.4 + in.tanh}, [3/8, 5/8]);
	in + fx;
});
~p[\fx1].play(vol:0.8);
~p[\fx1].stop;
~p[\fx1].gui;

/////////////////////////////////////////
// fx2
(~p[\fx2][0] = {
	var in = ~p[\sq].ar;
	var fx = RLPF.ar(in, SinOsc.kr(1/64).range(770, 3200), 0.6);
	fx;
});
~p[\fx2].play;
~p[\fx2].stop;
~p[\fx2].gui;


/////////////////////////////////////////
// sn
~p[\sn].clear;
~p[\sn].mold;
(~p[\sn][0] = {

	var trig = \trig.tr;
	var sig = {
		var sig = WhiteNoise.ar();
		sig = RLPF.ar(sig, 'G6'.namecps, 0.01);
		sig;
	}.();
	var env = Env.perc(releaseTime:0.2).kr(gate:trig);
	Pan2.ar(sig, \pan.kr(0)) * env * \amp.kr(-10.dbamp);
});
~p[\sn].play;
~p[\sn].stop;
~p[\sn].gui;

(~p[\sn][2] = \set -> Pbind(
    \trig, 1,
	\dur, Pseq([
		Pseq([Rest(1), 1], 1),
		//Pseq([Rest(1.75), 0.25], 1),
	], inf),
	\amp, -20.dbamp
));

~p[\fx1].play(vol:0.8);
~p[\fx2].play;
~p[\sn].play;

~p[\fx1].stop;
~p[\fx2].stop;
~p[\sn].stop;




s.meter(2,2).window.alwaysOnTop_(true);
App.recordWorkspace("ws8");
s.stopRecording
