~buf = Buffer.alloc(s, 44100 * 4.0, 1);

(
~bufs = Array.fill(5, { Buffer.alloc(s, 1024, 1, {arg buf;
var stut = [1,2,3].choose;
var num = [12, 16, 19].choose;
var num2 = [2,3,4].choose;
buf.chebyMsg([1] ++ Array.fill(num, {arg i; if ( i%num2 == 0, {rrand(0.01, 0.1)}, {0} ); }).stutter(stut), true, true, true) }) ;
});
)


~shaper = NodeProxy.new.quant_(1.0);
(~shaper[0] = {arg freq = 440, buf,
	atk = 0.01, dur = 1, rel = 1, curve = -4;

	var trig = \trig.tr;
	var env = EnvGen.ar(Env([0, 1, 0], [atk, dur-atk, rel], curve), gate: trig, levelScale: AmpComp.kr(freq) );
	var chorus = LFNoise2.ar(3.dup(2)).range(0.99, 1.01);
	var sig = Shaper.ar(buf, FSinOsc.ar(freq * chorus));
	Splay.ar(sig) * env;
});
(~shaper[1] = \set -> PbindProxy.new(
	\args, [\buf, \freq, \dur, \amp, \trig],
	\trig, 1,
	\delta, 1,
	\buf, Prand(~bufs, inf),
	\scale, Scale.major,
	\degree, Pseq([1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 3, 1, 1, 2, 1, 2, 3, 1, 1, 2, 1, 2, 3, 1, 1, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 3, 1, 1, 2, 1, 2, 3, 1, 1, 2, 1, 2, 3, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 1, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 3, 1, 1, 2, 1, 2, 3, 1, 1, 2, 1, 2, 3, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 2, 3, 4, 5, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 2, 3, 4, 5, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 2, 3, 4, 5, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 2, 3, 4, 5, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 2, 3, 4, 5, 1, 1, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 3, 1, 1, 2, 1, 2, 3, 1, 1, 2, 1, 2, 3, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 2, 3, 4, 5, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 2, 3, 4, 5, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 2, 3, 4, 5, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 2, 3, 4, 5, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 2, 3, 4, 5, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 2, 3, 4, 5, 1, 2, 3, 4, 5, 6, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 2, 3, 4, 5, 1, 2, 3, 4, 5, 6, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 2, 3, 4, 5, 1, 2, 3, 4, 5, 6, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 2, 3, 4, 5, 1, 2, 3, 4, 5, 6, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 2, 3, 4, 5, 1, 2, 3, 4, 5, 6, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 2, 3, 4, 5, 1, 2, 3, 4, 5, 6], 1),
	\dur, Prand([4, 6], inf),
	\amp, 0.02
));

//~shaper.play;
//~shaper.stop;


(
Ndef(\s1).play;
Ndef(\s1, {

	var sig;
	var buf = ~buf;
	var del;
	var bw;

	sig = Mono(~shaper.ar);
	bw = BufWr.ar(sig, buf, Phasor.ar(0, BufRateScale.kr(0) * 1, 0, BufFrames.kr(0) ) );
	del = GrainBuf.ar(1, Dust.kr(5),
		LFNoise1.kr(0.05).range(0.1, 0.2),
		buf,
		1,
		LFNoise1.kr([0.05, 0.1]).range(0.1, 0.8));
	del = AllpassC.ar(del, 0.2, 0.2, [3, 5]);
	(sig * 0.5) + del;
});
)

(
Ndef(\s2).play;
Ndef(\s2, {

	var sig = Ndef(\s1).ar;
	sig = Mix.arFill(20, {
		var snd = BPF.ar(sig, rrand(880.0, 4000.0), rrand(0.1, 0.5) );
		var delay = rrand(0.1, 0.3);
		CombC.ar(snd, delay, delay);
	});

	BLowPass4.ar(sig, 880, mul: 6)
});
)


