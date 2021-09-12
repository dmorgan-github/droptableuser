(
synth: {|freq, gate, aeg|

	var harm = \harm.kr(0);
	var k = (1..8);
	var ratio = {
		var val = k * (1 + ((k-1) * harm));
		val/val[0];
	}.();

	var bright = \bright.kr(0.5).linlin(0, 1, 80, 8000);
	var exciter = LPF.ar(Impulse.ar(0), bright);
	var morph = \morph.kr(0.0).linlin(0, 1, 1, 100);

	var sig = DynKlank.ar(`[
		ratio,
		(k * -3).dbamp,
		ratio.squared.reciprocal * 5;
	], exciter, freq, decayscale: morph);

    sig
},
specs: [
    harm: ControlSpec(-0.06, 2, \lin, 0, 0),
	bright: ControlSpec(0.0, 1.0, \lin, 0, 0.5),
    morph: ControlSpec(0.0, 1.0, \lin, 0, 0)
], 
credit: "adapted from formula by Nathan Ho"
)



