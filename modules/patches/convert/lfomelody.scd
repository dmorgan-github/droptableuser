~p = ProxySpace.new(s);

(~p[\lfomel] = {

	var lfo1 = LFPulse.kr(1/16).range(1/4,1);
	var lfo = min(LFTri.kr([lfo1/4, lfo1/5], mul: 3).tanh, LFDNoise1.kr(lfo1));

	var in = lfo.range(0, 11).round;
	// Kumoi scale
	var scale = [
		\s0.kr(1),
		\s1.kr(0),
		\s2.kr(1),
		\s3.kr(1),
		\s4.kr(0),
		\s5.kr(1),
		\s6.kr(0),
		\s7.kr(1),
		\s8.kr(0),
		\s9.kr(1),
		\s10.kr(0),
		\s11.kr(0)
	];

	var inscale = Select.kr(in, scale);
	var semi = in * inscale;

	var trig = Changed.kr(semi);
	var trig2 = PulseDivider.kr(trig, 3);
	var midi = TChoose.kr(trig2, \root.kr(60) + [0, 12, 24]) + (semi) * (inscale > 0);

	var env = Decay2.kr(in:trig * (inscale > 0), decayTime:lfo1);
	var freq = midi.midicps;
	var sig = SinOscFB.ar(freq.lag(0.01) * [1, 1.01], feedback: SinOsc.kr(0.1).range(0.3,0.7)) * env;

	//sig = RLPF.ar(sig, env.range(880, 2200), 0.3);
	//sig = XFade2.ar(sig, JPverb.ar(HPF.ar(sig, 100), t60:1, size:3), 0);
	//sig = XFade2.ar(sig, WaveLoss.ar(sig), -0.1);
	//sig = XFade2.ar(sig, Greyhole.ar(sig), -0.75);

	sig;
})

~p[\lfomel].play
~p[\lfomel].stop

~p[\lfomel_rlpf] = ~rlpf.(chans:~p[\lfomel].numChannels);
~p[\lfomel_rlpf] <<> ~p[\lfomel];
//~p[\lfomel_rlpf]

~p[\lfomel_revdel] = ~reversedelay.(chans:~p[\lfomel].numChannels);
~p[\lfomel_revdel] <<> ~p[\lfomel];
~p[\lfomel_revdel].set(\wet, 0.3, \delay, 4, \crossfade, 2000)
~p[\lfomel_revdel].play
~p[\lfomel_revdel].stop
~p[\lfomel_revdel].vol = 0.1;
~p[\lfomel_revdel].gui

~p[\lfomel_verb] = ~jpverb.(chans:~p[\lfomel_revdel].numChannels);
~p[\lfomel_verb] <<> ~p[\lfomel_revdel];
~p[\lfomel_verb].set(\t60, 1, \size, 3, \wet, 0.4);
~p[\lfomel_verb].play;
~p[\lfomel_verb].stop

~p[\lfomel_waveloss] = ~waveloss.(chans:~p[\lfomel_verb].numChannels);
~p[\lfomel_waveloss] <<> ~p[\lfomel_verb];
~p[\lfomel_waveloss].set(\wet, 0.4);
~p[\lfomel_waveloss].play;
~p[\lfomel_waveloss].stop;

~p[\lfomel_greyhole] = ~greyhole.(chans:~p[\lfomel_waveloss].numChannels);
~p[\lfomel_greyhole] <<> ~p[\lfomel_waveloss];
~p[\lfomel_greyhole].set(\wet, 0.2)
~p[\lfomel_greyhole].play(fadeTime:5);
~p[\lfomel_greyhole].stop(fadeTime:5);
~p[\lfomel_greyhole].vol = 0.04


App.recordVersion

