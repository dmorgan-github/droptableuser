(
synth: {|freq|
    var pdecay = \pdecay.kr(0.135, spec: ControlSpec(0, 1, \lin, 0, 0.135, "kick"));
    var pcurve = \pcurve.kr(-4, spec: ControlSpec(-8, 8, \lin, 0, -4, "kick"));
    var freqmul = \freqmul.kr(3.99, spec:ControlSpec(1, 4, \lin, 0, 3.99, "kick"));
    var phaseoffset = \phaseoffset.kr(0.1, spec: ControlSpec(0, 1, \lin, 0, 0.1, "kick"));
    var baseq = \basseq.kr(60, spec: ControlSpec(20, 110, \lin, 0, 60, "kick"));
    var bassgain = \bassgain.kr(1, spec: ControlSpec(0, 12, \lin, 0, 0, "kick"));
    var drive = \drive.kr(1.02, spec: ControlSpec(1, 12, \lin, 0, 1.02, "kick"));

    var freqmulenv = Env.perc(0,
        releaseTime: pdecay,
        curve: pcurve
    ).ar(gate:1).linlin(0, 1, 1, freqmul);

    var sig = SinOsc.ar(freq * freqmulenv, phaseoffset);
    sig = tanh(sig * drive);
    sig = LeakDC.ar(sig);
    sig = CompanderD.ar(sig, \thresh.kr(0.1), \slopebelow.kr(0.5), \slopeabove.kr(1.3), 0.001);
    sig = BPeakEQ.ar(sig, baseq, bassgain);
    sig = sig * Line.ar(2, 1, 0.002);
    sig
}
)
/*
(
S('kick2').set(
	'bend', 0,
	'atkcurve', -4.0,
	'drive', 1.02,
	'vel', 1.0,
	'amp', 0.31622776601684,
	'pan', 0,
	'bassgain', 2.5358490566038,
	'basseq', 60.0,
	'pdecay', 0.037735849056604,
	'glis', 0.0,
	'vrate', 6.0,
	'vdepth', 0.0,
	'freqmul', 2.8905660377358,
	'instrument', 'kick',
	'rel', 0.45283018867925,
	'spread', 1,
	'detunehz', 0.0,
	'phaseoffset', 0.15471698113208,
	'atk', 0.01,
	'pcurve', -7.3962264150943,
	'relcurve', -3.0490566037736,
	'ts', 1.0,
)
)
*/