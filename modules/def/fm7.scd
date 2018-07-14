({
	var trig = \trig.tr(0);

	var freq = Vibrato.ar(K2A.ar(\freq.kr(432)),
		\vrate.kr(6),
		\vdepth.kr(0.0),
		\vdelay.kr(0),
		\vonset.kr(0),
		\vrateVar.kr(0.04),
		\vdepthVar.kr(0.1)
	);

	var curve = \curve.kr(-4);
	var atk = \atk.kr(0.001);
	var decay = \decay.kr(0);
	var sus = \sus.kr(0);
	var rel = \rel.kr(1);

	var fenv = Env([0,1,0.7,0.7,0],[atk,decay,sus,rel], curve);

	var ctrls = Array.fill(6, {arg i;
		[freq * ('f' ++ i).asSymbol.kr(1), 0, EnvGen.kr(fenv, gate:trig) * ('f' ++ i ++ 'amp').asSymbol.kr(1)]
	});

	var mods = Array.fill2D(6, 6, {arg r, c;
		var key = ('mod' ++ r ++ '_' ++ c);
		key.asSymbol.kr(0)
	});

	var sig = FM7.ar(ctrls, mods) * (0..5).collect({arg i; ('chan' ++ i).asSymbol.kr(0.1)});

	sig = sig * AmpCompA.kr(freq);

	Splay.ar(sig)
})





