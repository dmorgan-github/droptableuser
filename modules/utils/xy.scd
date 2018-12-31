~p.push


(
~seq = {
	var clock = \clock.tr;
	var xtrig = \xtrig.tr;
	var ytrig = \ytrig.tr;
	var trig = \trig.tr;
	var freq = \freq.kr;
	[trig, freq, clock, xtrig, ytrig];
};
~trig = {~seq.kr[0]};
~freq = {~seq.kr[1]};
~trig2 = { PulseDivider.kr(~trig.kr, 8) * 2};
~freq2 = { Latch.kr((~freq.kr/4), ~trig2.kr) };
)


(
~ringz = {

	var trig = \trig.tr;
	var freq = \freq.kr;
	var sig = Latch.ar(BrownNoise.ar, trig);
	sig = Formlet.ar(sig, freq, 0.001, 1) * AmpCompA.kr(freq) * -20.dbamp;
	sig = Limiter.ar(sig, 0.7);
	Pan2.ar(sig, LFNoise2.kr(1)) * \amp.kr(-6.dbamp);
}
)

~ringz.set(\trig, ~trig, \freq, ~freq);
~ringz.play;




(
Tdef(\xy, {

	var vals = ((60 + Scale.dorian.semitones) ++ (72 + Scale.dorian.semitones).reverse) .midicps;
	var xdivs = [5];
	var ydivs = [3];

	var xincr = 0;
	var yincr = 0;

	inf.do({arg i;

		var xfound = false;
		var yfound = false;

		xdivs.do({arg div;

			if ( ((i % div) == 0) && xfound.not) {
				xfound = true;
				xincr = xincr + 1;
			};
		});

		ydivs.do({arg div;
			if ( ((i % div) == 0) && yfound.not) {
				yfound = true;
				yincr = yincr + 1;
				xincr = xincr + (yincr % 4).asInt;
			};
		});

		if (xfound || yfound) {
			var val = vals.wrapAt(xincr);
			if (xfound){
				~seq.set(\xtrig, 1)
			};
			if (yfound) {
				~seq.set(\ytrig, 1);
			};
			~seq.set(\trig, 1, \freq, val);
		};

		~seq.set(\clock, 1);
		0.25.wait;
	});

}).play;
)