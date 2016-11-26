~sn2 = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/perc/TR808WAV/SD/SD7550.WAV");
~kik2 = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/perc/TR808WAV/BD/BD0010.WAV");


(
ProxySynthDef(\smpl1, {

	var trig = \trig.tr;
	var buf = \buf.kr(0);
	var sig = PlayBufCF.ar(1, bufnum: buf, rate:1, trigger: trig, loop: 0);

	var sig2 = {
		var sig = HenonC.ar(mul:0.5);
		var env = Env([0,0,1,0],[0,0.9,0.1],[-4]).kr(gate: trig, timeScale: 0.5);
		sig * env;
	};

	Splay.ar(sig) * \amp.kr(0.1);

}).add;

)

~drum = App.monoDevice(\smpl1);
(~drum.pattern.set(
	\buf, Pseq([~kik2, ~sn2], inf),
	\delta, 0.5,
	\amp, 0.2 * 4
));
(~drum.node[10] = \filter -> {arg in;
	FreeVerb2.ar(in, in);
})
~drum.player.play;
~drum.player.stop;