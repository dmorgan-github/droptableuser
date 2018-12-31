(
Ndef(\s1, {
	var trig = Impulse.kr(0.5);
	var freq = Demand.kr(trig, 0, Dseq( (150 * [0, -2, -5].midiratio ), inf));
	var sig = VarSaw.ar(freq * [1, 1.01], 0, SinOsc.kr(1/8).range(0.1, 0.9)) * Env.linen(2, 1).kr(gate:trig);
	var fb = DelayC.ar(LocalIn.ar(2), 1, 1) * SinOsc.kr(1/32).range(0.2, 0.9) + sig;
	fb = PitchShift.ar(fb, 0.5, 7.midiratio, 0.01, 0.01);
	LocalOut.ar((fb + WaveLoss.ar(fb * 0.55)).tanh);
	sig = JPverb.ar(sig + fb, 10, 0, 5) * 0.4 + fb;
	Splay.ar(sig) * -6.dbamp;
}).play
)


// storm sounds by Nathan Ho
(
Ndef(\storm, {
    var rain, wind, thunder, snd;
    thunder = {
        var trig, snd;
        snd = WhiteNoise.ar;
        snd = Latch.ar(snd, Dust.ar(XLine.kr(8000, 16000, 3)));
        snd = LPF.ar(snd, LFNoise2.kr(8).linexp(-1, 1, 300, 600));
        snd = (snd * 30.dbamp * Env.perc(0.1, 5.0).kr).tanh;
        snd = LPF.ar(snd, 3000);
        snd = snd * Env([0, 1, 0.5, 1, 0], [0.01, 0.25, 0.05, 5], 4).ar;
        snd = snd ! 2;
        snd;
    }.();

    wind = {
        var snd;
        snd = { WhiteNoise.ar } ! 2;
        snd = RLPF.ar(snd, LFNoise2.kr(1).exprange(500, 1000), LFNoise2.kr(2).range(0.5, 0.8));
        snd;
    }.();

    rain = {
        snd = { TRand.ar(-1, 1, Dust.ar(10e3)) } ! 2;
        snd = BPF.ar(snd, 500, 0.6);
        snd;
    };

    snd = (wind * -23.dbamp) + (thunder * -23.dbamp);
    snd = snd + JPverb.ar(snd, 1);
    snd = snd + (rain * -15.dbamp);

    snd;
}).play;
)

Ndef(\storm).vol = 0.5