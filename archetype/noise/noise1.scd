(
ProxySynthDef(\noise1, {

	var sig = {
		var sig = LinCongN.ar(
			LFNoise2.kr(0.05).range(880, SampleRate.ir/2),
			LFNoise2.kr(1, 1.5, 1.5),
			LFNoise2.kr(2, 1.5, 1.5),
			LFNoise2.kr(1, 0.5, 1.5),
            LFNoise2.kr(1, 0.5, 1.5)
		) !2;
		sig = BLowPass4.ar(sig, 3000, 0.7);
		sig;
	};

	sig = FreeVerb.ar(sig);
	sig * \amp.kr(0.1);

}).add;
)

///////////////////////////////////////////
~noise1 = App.monoDevice(\noise1);
~noise1.pattern.set(\amp, 0.02)
~noise1.node[10] = \filter -> {arg in; GVerb.ar(in, 300);}
~noise1.player.play;
~noise1.player.stop;
