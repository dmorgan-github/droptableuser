https://scsynth.org/t/short-impulse-with-frequency-possible/799/5
a = {
	var pulse = Impulse.ar(4),
	// note, the decaying-sine grains will overlap "for free"
	decay = LFTri.kr(0.05).exprange(0.01, 0.5);
	Ringz.ar(pulse, 440, decay).dup
}.play;


a.free;