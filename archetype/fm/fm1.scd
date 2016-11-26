(
ProxySynthDef(\fm1, {

	var trig = \trig.tr;
	var pan = \pan.kr(0);
	var freq = \freq.kr(300);

	var ctls = { [freq * rrand(1.0, 4.0), 0, 1.0.linrand] }.dup(6);
	var mods = { Array.fill(6, { 0.3pi.linrand }) }.dup(6);
	var chans = [0, 1];
	var sig = FM7.ar(ctls, mods).slice(chans).sum;

	var env = {
		var rel = \rel.kr(1);
		var atk = \atk.kr(0.01);
		var curve = \curve.kr(-4);
		var dur = \dur.kr(1);
		EnvGen.kr(Env([0,0,1,0], [0, atk, rel], [curve]), trig, timeScale: dur)
	};

	Pan2.ar(sig, pan) * env * \amp.kr(0.1) * AmpCompA.kr(freq);

}).add;
)

///////////////////////////////////////////
~fm1 = App.monoDevice(\fm1);
(~fm1.pattern.set(
	\delta, Pseg(
		Pwhite().linexp(0, 1, 1/32, 1),
		Pbrown(0,1,0.05).linexp(0, 1, 1/8, 8),
		\sin
	),
	\dur, Pkey(\delta),
	\pan, Pbrown(-1, 1, 0.125, inf),
	\amp, 0.1
));
(~fm1.node[10] = \filter -> {arg in;
	GVerb.ar(in, 200, taillevel: 0.5);
})
~fm1.player.stop;
~fm1.player.play;