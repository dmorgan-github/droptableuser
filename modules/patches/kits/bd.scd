TempoClock.default.tempo_(60/60)

(
Ndef(\bd, {
	// by Nathan Ho
	// TODO: parameterize
	var trig, snd;
    //trig = Impulse.ar(2);
	trig = \trig.tr;
    snd = Trig.ar(trig, 5e-3) * 3;
    snd = snd - OnePole.ar(snd, 1 - 100e-3) + (snd * 0.04);
    snd = Select.ar(snd > 0, [0.7 * snd / (1 - snd), snd]);
    snd = Ringz.ar(snd, 60 * (1 + (OnePole.ar(Trig.ar(trig, 10e-3), 0.96)) + (snd * 0.1)), 1);
	snd = snd * \amp.kr(-40.dbamp);
	Splay.ar(snd, \spread.kr(1), center:\center.kr(0));
})
)


Ndef(\bd).play;
Pdef(\bd).clear;
(
Pdef(\bd, {

	var node = Ndef(\bd);
	if (node.isMonitoring.not) {
		node.play;
	};

	Pbind(
		\type, \set,
		\id, Pfunc({node.nodeID}),
		\args, #[\trig, \amp],
		\amp, -45.dbamp,
		\trig, 1,
		\dur, 0.5
	)
})
)

Pdef(\bd).quant_(1.0).play;
Pdef(\bd).stop;