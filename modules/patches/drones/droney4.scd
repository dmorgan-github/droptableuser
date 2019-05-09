
// allocate contiguous buffers
b = Buffer.allocConsecutive(3, Server.default, 1024, 1);

(
// create arbitrary waves
~wt0 = Env(
	[0]++
	{
		var levs, peak;
		levs = {rrand(-1.0,1.0)}!10;
		peak = levs.abs.maxItem;
		levs = levs * peak.reciprocal;
	}.value ++
	[0],
	{exprand(0.01,1)}!11,
	{exprand(0.1,4)}!11
).asSignal(512);

~wt1 = Env(
	[0]++
	{
		var levs, peak;
		levs = {rrand(-1.0,1.0)}!10;
		peak = levs.abs.maxItem;
		levs = levs * peak.reciprocal;
	}.value ++
	[0],
	{exprand(0.01,1)}!11,
	{exprand(0.1,4)}!11
).asSignal(512);

~wt2 = Env(
	[0]++
	{
		var levs, peak;
		levs = {rrand(-1.0,1.0)}!10;
		peak = levs.abs.maxItem;
		levs = levs * peak.reciprocal;
	}.value ++
	[0],
	{exprand(0.01,1)}!11,
	{exprand(0.1,4)}!11
).asSignal(512);

// load them as wave tables
b[0].setn(0, ~wt0.asWavetable);
b[1].setn(0, ~wt1.asWavetable);
b[2].setn(0, ~wt2.asWavetable);

)


(
Ndef(\droney, {

	/*
	detune=0 makes a much more boring sound, but also
	makes the wavetable interpolation more
	observable (evaluate s.scope and adjust the
	horizontal slider to watch the waveform)
	*/
	var freq = \freq.kr(40);
	var amp = \amp.kr(0.1);
	var buf = \buf.kr(0);

	var detune = LFNoise1.kr({Rand(0.08, 0.15)}!3).bipolar(0.15).midiratio;
	var x = LFNoise2.kr(0.1).range(0, 2);
	var sig = VOsc3.ar(b[0].bufnum + x,
		freq * detune[0],
		freq * detune[1],
		freq * detune[2]
	);

	//spread 8-channel detuned Osc texture across two channels
	sig = Splay.ar(sig);

	//avoid funky DC bias
	sig = LeakDC.ar(sig);

	sig = sig * amp;
});
)

Ndef(\droney).copy(\droney2);

Ndef(\droney).set(\freq, 'c1'.namecps);
Ndef(\droney).play(vol:0.3);

Ndef(\droney2).set(\freq, 'g1'.namecps);
Ndef(\droney2).play(vol:0.3)

Ndef(\droney2).stop(fadeTime:20);
Ndef(\droney).play(fadeTime:20);


App.saveWorkspace("droney2", rec:true);
s.stopRecording