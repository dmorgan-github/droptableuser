(
func: {

	var trig = \trig.tr;
	var freq = \freq.kr(432);
	var sig = VarSaw.ar(
		Vibrato.kr(freq, rate:\vrate.kr(6), depth:\vdepth.kr(0.005), delay:\vdelay.kr(0.01)),
		0,
		width:\width.kr(0.5)
	);
	var susLevel = \susLevel.kr(0.5);
	var bw = \bw.kr(3.14153);
	var env = Env(
		[0,1,susLevel,susLevel,0],
		[\atk.kr(0.01),\decay.kr(0.1),\sus.kr(0),\rel.kr(1)], curve:\curve.kr(-4)
	).kr(gate:trig, timeScale:\ts.kr(1));

	sig = BBandPass.ar(sig,
		env.range(\bplo.kr(440), \bphi.kr(1550)),
		bw,
		mul:bw.reciprocal.sqrt
	);
	sig = sig * env * \amp.kr(0.1) * AmpCompA.kr(freq);
	sig = Pan2.ar(sig, \pan.kr(0));
},

specs: (
	trig: \set,
	width: [0,1,\lin,0,0.5],
	freq: [20,18000, \exp, 0, 432],
	vrate: [0,6,\lin,0,0.001],
	vdepth: [0,1,\lin,0,0.02],
	vdelay: [0,1,\lin,0,0],
	susLevel: [0,1,\lin,0,0.5],
	atk: [0,1,\lin,0,0.01],
	decay: [0,1,\lin,0,0.1],
	sus: [0,1,\lin,0,0],
	rel: [0,1,\lin,0,1],
	curve: [-24,24,\lin,0,-4],
	ts: [0,10,\lin,0,1],
	bplo: [20,18000,\exp,0,440],
	bphi: [20,18000,\exp,0,1550],
	bw:[0,5,\lin,0,3.14153],
	amp: [0,1,\lin,0,0.1],
	pan: [-1,1,\lin,0,0]
)
)

