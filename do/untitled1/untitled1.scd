
NdefMixer(s)
~hf.()

~samplesLib.ls();


(
e = ();
e.u = Buffer.sendCollection(s, Env.linen(1,0.5,0.5,curve:-4).discretize, 1);
e.z = Buffer.sendCollection(s, Env.linen.discretize, 1);
)

//s.prepareForRecord("/Users/dmorgan/supercollider/do/untitled1/linear-faith-4.aiff");
(
s.record();
//s.stopRecording();

/************************************
1
*************************************/
q = q ? (
	gran1: ~grainin.("grain1")
);
q.gran1.setTrig({
	Impulse.ar(SinOsc.ar(0.06).range(0.01, 8));
});
q.gran1.setDur({ LFNoise1.ar(1).range(0.01, 0.3) });
q.gran1.setIn({
	var m = [1, 1.1224620483089, 1.2599210498937, 1.3348398541685, 1.4983070768743, 1.6817928305039, 1.8877486253586 ];
	var root = 220;
	var seq = Dseq(root * [1/2, 3/4, Drand(m, 2)], inf);
	var trig = Impulse.ar(0.5);
	var freq = Demand.ar(trig, 0, seq);
	(
		SinOsc.ar(freq*Array.geom(6, 1, 1.5)*Array.fill(6, { LFNoise2.kr(Rand(1,3),0.01,1) }),
			mul:AmpCompA.ar(freq * 4, root) )
		+ VarSaw.ar(freq/2, mul:0.3)
		+ VarSaw.ar(freq/3, mul:0.1)
	).mean * 0.7;
});
q.gran1.setPan({ LFNoise1.ar(1).range(-0.5, 0.5) });
q.gran1.setEnvbuf({
	Select.ar( SinOsc.kr(5).range(0, 2).round, [DC.ar(e.u.bufnum), DC.ar(e.z.bufnum), DC.ar(-1)])
});

Ndef(\line, { Line.kr(0.1, 0.7, 180); });

//q.gran1.proxy.play;
q.gran1.proxy[1] = \filter -> ~reverb1.();
q.gran1.proxy[2] = \filter -> ~echo.(decay:3);
q.gran1.proxy[3] = \filter -> {arg in;
	Disintegrator.ar(in, Line.ar(0, 0.9, 175), -1);
};
q.gran1.proxy[4] = \filter -> ~threeChan.(lov:0.4, ratio:3, threshdb:45);

q.gran1.proxy.fadeTime = 0;
q.gran1.proxy.set(\wet1, 0);
q.gran1.proxy.set(\wet2, 0);
q.gran1.proxy.set(\wet3, 0);
q.gran1.proxy.set(\wet4, 1);
q.gran1.proxy.set(\amp, 0.2);

q.gran1.proxy.map(\wet1, Ndef(\line) );
q.gran1.proxy.map(\wet2, Ndef(\line) );
q.gran1.proxy.map(\wet3, Ndef(\line) );

/************************************
2
*************************************/
~samples.load("goldenmean.mono");
t = ( gran1: ~grainbuf.("grainbuf1", ~samples['goldenmean.mono']) );
t.gran1.setTrig({
	Dust.ar(3);
});
t.gran1.setStart({
	LFNoise1.ar(1).range(0.1, 0.5);
});
t.gran1.setDur({
	LFNoise1.ar(2).range(0.4, 0.8);
});
//t.gran1.stop();
t.gran1.proxy.fadeTime = 0;
t.gran1.proxy.set(\amp, 0.3);
t.gran1.proxy[1] = \filter -> {arg in;
	FreeVerb.ar(in, 0.5, 0.7, 0.7);
};

/************************************
*************************************/
fork({
	t.gran1.proxy.play(fadeTime:1.5);
	12.wait;
	q.gran1.proxy.play(fadeTime:2.5);
	180.wait;
	"stopping".postln;
	q.gran1.proxy.stop(30);
	t.gran1.proxy.stop(20);
});

)

FreqScope.new(width:350)