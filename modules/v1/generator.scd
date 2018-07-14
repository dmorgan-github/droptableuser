(
~glitch1 = {

	{
		// adapted from "http://sccode.org/1-58a"
		var a = {SinOsc.ar([22.5, 23], mul: ChaosGen.allSubclasses.choose.ar(rrand(1, 30))* 0.3)};
		var b = {SinOsc.ar([22.5, 23], mul: 0.3)};
		var c = {SinOsc.ar([22.5, 23]*400, mul: ChaosGen.allSubclasses.choose.ar(rrand(1, 30))* 0.03)};
		var d = {SinOsc.ar([22.5, 23]*400, mul: 0.03)};
		a + b + c + d;
	};
};
Library.put(\modules, \generator, \glitch1, ~glitch1);

~ikeda = {

	{
		{
			var clock, freq, shift, gate, env;
			freq = 60;
			clock = Impulse.ar(8);
			shift = 12 * TIRand.ar(-1, 1, clock);
			// randomly switch between 0 and 1, but with 60% chance of 1s
			gate = Latch.ar(CoinGate.ar(0.6, clock), clock);
			// use the gate to control an ASR envelope
			env = Env.asr(0.01, 1.0, 0.01).ar(0, gate);
			RLPF.ar(LFTri.ar(freq + shift), 100) * env
		}!2;
	}
};
Library.put(\modules, \generator, \ikeda, ~ikeda);

~drone1 = {

	{
		var freq = \freq.kr(50);
		var source = SinOsc.ar(freq * { LFDNoise3.kr(0.1).range(0.98, 1.02) } ! 2);
		SmoothFoldS.ar(source, -0.1, 0.1, SinOsc.kr(0.05, [0, pi]).range(0.1, 1))
	}
};
Library.put(\modules, \generator, \drone1, ~drone1);

)