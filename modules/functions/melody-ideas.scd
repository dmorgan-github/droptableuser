(
SynthDef(\varsaw1, {

	var freq = Vibrato.kr(\freq.kr(432), 6, 0.001);
	var env = Env.adsr(releaseTime:\rel.kr(1), curve:-4).kr(gate:\gate.kr(1), doneAction:Done.freeSelf);
	//var sig = SinOscFB.ar(freq * [1, 1.01], \fb.kr(0.075));
	var sig = VarSaw.ar(freq, 0, SinOsc.kr(4).range(0.3,0.7));
	{sig = MoogFF.ar(sig, XLine.kr(2000, 1000, rrand(0.2, 0.5)), 1.5, mul: 2).tanh}.dup(3);
	sig = Splay.ar(sig) * env * AmpCompA.kr(freq) * \amp.kr(-3.dbamp);
	//sig = Latch.ar(sig, Impulse.ar(LFNoise0.kr(5).lag(0.1).exprange(1000, 16000))) * 0.5 + sig;
	Out.ar(\out.kr(0), sig);

}).add;
)

(
// use this to generate melodic ideas
// 310414, 304544
var foo = {
	thisThread.randSeed_(1000000.rand.debug("rand seed"));
	//thisThread.randSeed_(304544);
	//thisThread.randSeed_(637056);
}.();

var durs = Pconst(4, Pwrand([0.25, 0.125, 0.5], [3,2,1].scramble.normalizeSum, inf)).asStream.nextN(16).reject(_.isNil);
var degrees = Prand([-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7], inf).asStream.nextN(4);

[durs, degrees].debug;

Pdef(\mel, Pbind(\instrument, \varsaw1,
	//\scale, Scale.aeolian,
	\root, 2,
	\degree, Pseq(degrees, inf),
	\octave, Pbjorklund(7,durs.size,inf).collect({arg val; if (val == 0) { 5 }{ 6 }}),
	\dur, Pseq(durs, inf) * 2,
	\legato, 0.5,
	\rel, 1,
	\amp, -25.dbamp,
	\timingOffset, 0.375
	//\out, Ndef(\send1).bus.index
	//\foo, Pseq([], inf)
)).play;

)

Pdef(\mel).play;
Pdef(\mel).stop;
Pdef(\mel).clear;

s.record;
s.stopRecording