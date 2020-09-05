b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01-44_1.aiff");

(  // basic granulation
{
    var input = PlayBuf.ar(1, b, 1, loop: 1)!2;

    var dens = LFNoise1.kr(0.3).range(0.3, 0.45);
    MiClouds.ar(input, 0, 0, 0, dens, 0.5, drywet: 1, mode: 0);

}.play
)

(  //
{
    var imp = Dust.ar([0.8,1.1]);
    var freq = Latch.ar(PinkNoise.ar(24,80), imp).midicps;
    var input = RLPF.ar(imp, freq, 0.002, 4);

    var pit = LFNoise1.kr(0.3,12);
    var pos = LFNoise2.kr(0.4,0.5,0.5);
    var size = LFNoise1.kr(0.3,0.5,0.5);
    var dens = LFNoise1.kr(0.3,0.5,0.5);
    var tex = LFNoise1.kr(0.3,0.5,0.5);

    var frez = LFClipNoise.kr(0.3);

    MiClouds.ar(input, pit, pos, size, dens, tex, drywet: 0.5, in_gain: 2, rvb:0.3, fb: 0.8,
        freeze: frez, lofi: 1, mode: 0);

}.play
)

(
Ndef(\grainin, {

	var in = {
		var imp = Dust.ar([0.8,1.1]);
		var freq = Latch.ar(PinkNoise.ar(24,80), imp).midicps;
		var sig = RLPF.ar(imp, freq, 0.002, 4);
		sig.sum;
	}.();

	var sig, rate, dur;

	var buf = LocalBuf(44100 * 5, 1).clear;
	var phase = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf));
	BufWr.ar(in, buf, phase);

	// ensure we don't jump ahead of the write head
	phase = phase - 44100 * [1, 2] * 0.5;

	dur = LFNoise1.kr(0.3).range(0.01, 1);

	rate = LFNoise1.kr(0.3, 12).midiratio!2;

	sig = GrainBuf.ar(1,
		Dust.ar(10),
		dur,
		buf,
		rate,
		phase / BufFrames.kr(buf),
		2,
		0,
		-1
	);

	Splay.ar(sig);
})
)

Ndef(\grainin).play;
Ndef(\grainin).stop;
