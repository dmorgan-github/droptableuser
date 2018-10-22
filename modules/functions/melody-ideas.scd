(
SynthDef(\varsaw1, {

	var freq = Vibrato.kr(\freq.kr(432), 6, 0.01);
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
	//thisThread.randSeed_(1000000.rand.debug("rand seed"));
	//thisThread.randSeed_(304544);
	thisThread.randSeed_(705725);
}.();

var durs = Pconst(2, Pwrand([0.25, 0.125, 0.5], [3,2,1].normalizeSum, inf)).asStream.nextN(16).reject(_.isNil);
var degrees = Prand([-2,0,1,2,3], inf).asStream.nextN(4);

[durs, degrees].debug;

Pdef(\mel, Pbind(\instrument, \varsaw1,
	\scale, Scale.locrian,
	\root, 2,
	\degree, Pseq(degrees, inf),
	\octave, 6,//Pbjorklund(7,durs.size,inf).collect({arg val; if (val == 0) {5}{4}}),
	\dur, Pseq(durs, inf),
	\legato, 0.1,
	\rel, 0.5,
	\amp, -25.dbamp,
	\out, Ndef(\send1).bus.index
	//\foo, Pseq([], inf)
)).play;

)

Pdef(\mel).play;
Pdef(\mel).stop;
Pdef(\mel).clear;