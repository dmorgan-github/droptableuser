(
ProxySynthDef(\sinpair, {

	var trig = \trig.kr(0);
	var freq1 = \freq1.kr(300);
	var freq2 = \freq2.kr(300);
	var sig = FSinOsc.ar([freq1 * [1,1.01], freq2 * [1,1.01]], mul:[1, AmpCompA.kr(freq2)]).mean;
	var env = Env([0,0,1,0.7,0],[0,\atk.kr(0.01),0.3,\rel.kr(1)],[-4], releaseNode:3).kr(gate: trig);
	Splay.ar(sig, 0.5) * env * \amp.kr(0.1).lag(3);

}).add;
)