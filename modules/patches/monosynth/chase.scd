(
~p[\chase][0] = {

	var trig = \trig.tr;

	var freq = \freq.kr('Eb2'.namecps);

	var sig = [

		{
			var sig = Saw.ar(freq * [1, 1.01]);
			sig;
		},
		{
			var trig = Trig1.kr(Impulse.kr(2), LFNoise1.kr(1/4).range(0.1,0.5));
			var octave = Demand.kr(trig, 0, Drand([12,24,7].midiratio, inf));
			var sig = SinOsc.ar(freq * octave, 0);
			var env = Env.linen(releaseTime:0.1).kr(gate:trig);
			sig = sig * env;
			sig = DelayC.ar(sig, 1.0, LFNoise0.ar([4,6]).range(0.0, 1.0));
			sig * 1.1;
		}

	].collect(_.value) * [1, 1].normalizeSum;

	var env = Env([0,1,0.7,0.7,0],[2,0.3,2,2], curve:-4).kr(gate:trig);
	//Env.circle([0,1,0.7,0.7,0],[2,0.3,2,2],-4).kr();

	sig = Splay.ar(sig.sum) * env * \amp.kr(-6.dbamp);

	sig = JPverb.ar(sig, 5, 0, 5) * 0.6 + sig;

	sig;
}
)

~p[\chase].play(vol:0.5);
~p[\chase].stop;


(
var node = ~p[\chase];//.quant_(0);
Pdef(\chase, {arg out = 0, amp = 0.dbamp;
	node.play(out:out);
	Pbind(\type, \set,
		\id, Pfunc({node.nodeID}),
		\args, #[\trig, \amp, \freq],
		\trig, 1,
		\dur, 9,
		\freq, Pstutter(4, Pseq(['Eb2', 'Bb2', 'C2'].namecps, inf)),
		\amp, amp
	)
})
)

~p[\chase].play();
Pdef(\chase).play;
Pdef(\chase).stop;