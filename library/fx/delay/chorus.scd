(
// adapted from: https://github.com/madskjeldgaard/Sleet/blob/master/modules/delay.scd
synth: {|in|

	var numchans = 2;
	var chpredelay = \chpredelay.kr(0.08);
	var chrate = \chrate.kr(0.05);
	var chdepth = \chdepth.kr(0.1);
	var chphasediff = \chphasediff.kr(0.5);

	var sig, numDelays = 4;

	sig = Array.fill(numchans, {|cNum|
		var input = in[cNum] * numDelays.reciprocal;
		var modulators = Array.fill(numDelays, { arg i;
			LFPar.kr(chrate.linexp(0.0,1.0,0.001,10.0) * {rrand(0.94, 1.06)}, chphasediff * i, chdepth, chpredelay)
		});
		DelayC.ar(input, 0.2, modulators).sum;
	});

	sig
}
)