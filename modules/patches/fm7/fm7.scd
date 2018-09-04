////////////////////////////////
// patch
~fm = ProxySpace.new(s);
~fm.quant = 1.0;
~fm.clock = TempoClock.default.tempo_(45/60)

~fm[\snd].clear;
(

~fm[\snd][0] = {

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
	var sus = \sus.kr(0);
	var rel = \rel.kr(1);

	var env = Env.linen(atk, sus, rel, curve:curve);// Env([0,1,0.7,0],[atk,sus,rel], curve);

	var ctrls = Array.fill(6, {arg i;
		[freq * ('f' ++ i).asSymbol.kr(1), 0, ('f' ++ i ++ 'amp').asSymbol.kr(1)]
	});

	var mods = Array.fill2D(6, 6, {arg r, c;
		var key = ('mod' ++ r ++ '_' ++ c);
		key.asSymbol.kr(0)
	});

	var sig = FM7.ar(ctrls, mods) * (0..5).collect({arg i; ('chan' ++ i).asSymbol.kr(0.1)});

	sig = sig * EnvGen.kr(env, gate:trig);

	sig = sig * AmpCompA.kr(freq) * \amp.kr(0.1);

	Mix.ar(sig)!2;
});

~fm7ui.(~fm[\snd]);

////////////////////////////////
//

(~fm[\snd][4] = \set -> Pbind(
	\trig, 1,
	\beatDur, Pfunc({thisThread.clock.beatDur}),
	\delta, 0.25,
	\scale, Scale.minor,
	\degree, 0,//Prand([
	//	Pseq([Pshuf([4, 6, 7].mirror, 2)], 4),
	//	Ppatlace([ Pwhite(0,4), Pbrown(2,6,1) ], 4)
	//], inf),
	\octave, 6,
	//\mtranspose, Pstutter(32, Pseq([0,-2,-5,2], inf)),
	\vdepth, 0.01,
	\vrate, 4,
	\amp, 0.02,
	\dur, Pkey(\delta) * Pkey(\beatDur),
	\atk, 0.001 * Pkey(\dur),
	\rel, 0.01999 * Pkey(\dur),
	\sus, 0.1
));


~fm[\snd].play(out:0, fadeTime:0);
~fm[\snd].stop(fadeTime:30);

~fm[\lfo1] = {SinOsc.kr(1/64).range(0, 1)}
~fm[\snd].set(\f2amp, ~fm[\lfo1] )

(~fm[\snd][12] = \filter -> {arg in;

	var sig;
	var tap1, tap2, tap3;
	var fbNode = FbNode(2, 1.304, 4);

	tap1 = BBandPass.ar( fbNode.delay(0.2), 4400, 0.5);
	tap2 = BBandPass.ar( fbNode.delay(0.27) * 0.4, 880, 1.5, (1/3.5).sqrt);
	tap3 = BBandPass.ar( fbNode.delay(1.303) * 0.2, 2200, 3.5);

	sig = [in + tap1, tap2 + tap3];

	fbNode.write(in);

	sig;
});

(~fm[\snd][14] = \filter -> {arg in;
	var sig = Shaper.ar(~wt[\1], in);
	JPverb.ar(sig);
})

~fm[\snd].set(\wet12, 1, \wet14, 0.4)





