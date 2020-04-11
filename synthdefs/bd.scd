/////////////////////////////////////////
// bd
(
~bd = S(\bd, {arg freq, gate;

	var osc1 = {arg freq;
		var peak = \fpeak.kr(2) * [0.99, 1.3];// * Rand(0.99, 1.01);
		var freqmul = XLine.ar(peak, 1, 0.01);// Env.perc(0.001, 0.01).ar(gate:1).linlin(0, 1, 1, peak);
		var wn = HPF.ar(WhiteNoise.ar, 100) * XLine.ar(1, 0.001, 0.01) * \noise.kr(0.2);
		var sub = FSinOsc.ar(freq, 0.5) * \sub.kr(0.01);
		var sig = FSinOsc.ar(freq * freqmul, 0.5) + wn + sub;
		sig = sig * Env.perc(0.001, \rel2.kr(0.4)).ar(gate:1);
		sig = BLowShelf.ar(sig, 18, 1, -30);
		sig = BPeakEQ.ar(sig, 40, 1, 2);
		sig = BPeakEQ.ar(sig, 80, 1, 5);
		sig = BPeakEQ.ar(sig, 880, 1, 18);
		sig = BHiShelf.ar(sig, 2000, 1, -10);
		Splay.ar(sig.asArray.sum);
	};
	var mix = osc1.('B0'.namecps);
	mix;
})
);

~bd.dur = Pbjorklund2(5,8) * 0.5;
~bd.play;
~bd.stop;
~bd.vel = 1;
~bd.amp = 1;



