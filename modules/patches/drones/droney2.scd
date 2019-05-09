(
Ndef(\s1, {

	var root = Demand.kr(Impulse.kr(1/8), 0, Dseq([0,-2,2], inf));
	var freq = 110 * ([0, 5, 9, 14] + root).midiratio;
	var sig;

	var fb1 = FbNode(2, 1, 4);
	var sig1 = VarSaw.ar(freq[0] * [1,1.01]) * Decay.kr(Impulse.kr(1));
	var del1 = {
		var sig = fb1.delay(0.3);
		sig = sig * Env.circle([0,1,0],[2,3,2],-4).kr(gate:1);
		sig.tanh;
	}.();

	var fb2 = FbNode(2, 1, 4);
	var sig2 = SinOsc.ar(freq[1] * [1,1.01]) * Decay.kr(Impulse.kr(3));
	var del2 = {
		var sig = fb2.delay(0.45);
		sig = sig * Env.circle([0,1,0],[3,3,2],-4).kr(gate:1);
		sig.tanh;
	}.();

	var fb3 = FbNode(2, 1, 4);
	var sig3 = Pulse.ar(freq[2] * [1,1.01]) * Decay.kr(Impulse.kr(0.5));
	var del3 = {
		var sig = fb3.delay(0.45);
		sig = sig * Env.circle([0,1,1,0],[4,4,1,3],-4).kr(gate:1);
		sig;
	}.();

	var fb4 = FbNode(2, 1, 4);
	var sig4 = Saw.ar(freq[3] * [1,1.01]) * Decay.kr(Impulse.kr(2));
	var del4 = {
		var sig = fb4.delay(0.45);
		sig = sig * Env.circle([0,1,0],[5,5,4],-4).kr(gate:1);
		sig;
	}.();

	fb1.write(del1 + (del2 * 0.5) + sig1);
	fb2.write(del2 + (del3 * 0.5) + sig2);
	fb3.write(del3 + (del4 * 0.5) + sig3);
	fb4.write(del4 + (del1 * 0.5) + sig4);

	sig = [
		del1,
		del2,
		del3,
		del4
	] * [3,2,1,2].normalizeSum;

	sig = Greyhole.ar(sig, feedback:0.5) * 0.5 + sig;

	sig = BLowPass4.ar(sig, LFNoise2.kr(1/64).range(2440, 4400), 0.8);

	sig = Splay.ar(sig) * \amp.kr(-6.dbamp);

	sig = JPverb.ar(sig, 10, 0, 5) * 0.5 + sig;

	sig;
})
)

Ndef(\s1).play(vol:1);
Ndef(\s1).stop;




