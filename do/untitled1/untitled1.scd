
NdefMixer(s)

~hf.()

(
e = ();
e.u = Buffer.sendCollection(s, Env.linen(1,0.5,0.5,curve:-4).discretize, 1);
e.z = Buffer.sendCollection(s, Env.linen.discretize, 1);

q = ();
q.gran1 = ~grainin.("grain1");
q.gran1.setTrig({
	Impulse.ar(SinOsc.ar(0.06).range(0.01, 25));
});
q.gran1.setDur({ LFNoise1.ar(1).range(0.01, 0.3) });
q.gran1.setIn({
	var m = [1, 1.1224620483089, 1.2599210498937, 1.3348398541685, 1.4983070768743, 1.6817928305039, 1.8877486253586 ];
	var root = 220;
	var seq = Dseq(root * [1/2, 3/4, Drand(m, 2)], inf);
	var trig = Impulse.ar(0.5);
	var freq = Demand.ar(trig, 0, seq);
	(
		SinOsc.ar(freq*Array.geom(6, 1, 1.5)*Array.fill(6, { LFNoise2.kr(Rand(1,3),0.01,1) }), mul:AmpCompA.ar(freq * 2, root) )
		+ VarSaw.ar(freq/2, mul:0.3)
		+ VarSaw.ar(freq/3, mul:0.1)
	).mean;
});
q.gran1.setPan({ LFNoise1.ar(1).range(-0.5, 0.5) });
q.gran1.setEnvbuf({
	Select.ar( SinOsc.kr(5).range(0, 2).round, [DC.ar(e.u.bufnum), DC.ar(e.z.bufnum), DC.ar(-1)])
});


q.gran1.proxy.fadeTime = 2;
q.gran1.proxy.play;
Ndef(\line, { Line.kr(0.1, 0.7, 300) });
q.gran1.proxy[1] = \filter -> ~reverb1.();
q.gran1.proxy[2] = \filter -> ~echo.(decay:3);
q.gran1.proxy[3] = \filter -> {arg in;
	Disintegrator.ar(in, Line.ar(0, 0.9, 300), -1);
	//Select.ar( LFNoise1.ar(1).range(0, 2).round.poll, [in.fold(-1,1), in.abs, in.softclip] ).lag(0.01);
};
q.gran1.proxy[4] = \filter -> ~threeChan.(lov:0.7);
q.gran1.proxy.set(\wet1, 1);
q.gran1.proxy.set(\wet2, 0.5);
q.gran1.proxy.map(\wet3, Ndef(\line) );
//q.gran1.proxy.set(\wet3, 1 );
q.gran1.proxy.set(\wet4, 1);
q.gran1.proxy.set(\amp, 1);


(
~x={loop     // routine
{~y={PanB2.ar(0.1*ClipNoise.ar*LFNoise1.kr(10.0.rand,1.0.rand,0),-1.0.rrand(1.0),1.0.rand)}.play;    // synth part
1.0.rrand(10.0).wait;
~y.release(2.0.rrand(10.0))}}.fork       // randomised synth release
)

);