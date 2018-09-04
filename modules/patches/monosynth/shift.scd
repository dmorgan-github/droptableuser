

TempoClock.default.start;

t = TempoClock.new
t.play

p = Pbind().play(clock:t).play;



~p = ProxySpace.new(s);
~p.quant = 1.0;

(~p[\seq2] = {
	var trig = PulseDivider.kr(~p[\trig1].kr, 3);
	var freq = Latch.kr(~p[\freq].kr * TChoose.kr(trig, [1, 2]), trig);
	[trig, freq];
});

~p[\freq2] = {~p[\seq2].kr[1]};
~p[\trig2] = {~p[\seq2].kr[0]};

~p[\sr] = ~shift_register.();
~p[\sr] <<> ~p[\freq2];
~p[\sr].set(\trig, ~p[\trig2]);

~p[\freqa] = {~p[\sr].kr[0]};
~p[\freqb] = {~p[\sr].kr[1]};
~p[\freqc] = {~p[\sr].kr[2]};
~p[\freqd] = {~p[\sr].kr[3]};
~p[\freqe] = {~p[\sr].kr[4]};

~p[\sin1] = ~sinosc.(func:{arg sig;sig.distort});
~p[\sin1].set(\freq, ~p[\freqa], \amp, 0.1, \lag, 0.1);
~p[\sin1].play
~p[\sin1].stop

~p[\sin2] = ~varsaw.(func:{arg sig;sig.sin;});
~p[\sin2].set(\freq, ~p[\freqb], \amp, 0.1, \lag, 0.1);
~p[\sin2].play
~p[\sin2].stop

~p[\sin3] = ~varsaw.(func:{arg sig; LeakDC.ar(sig.abs);});
~p[\sin3].set(\freq, ~p[\freqc], \amp, 0.1, \lag, 0.1);
~p[\sin3].play
~p[\sin3].stop

~p[\sin4] = ~varsaw.(func:{arg sig; sig.softclip});
~p[\sin4].set(\freq, ~p[\freqd], \amp, 0.1, \lag, 0.1);
~p[\sin4].play
~p[\sin4].stop

~p[\sin5] = ~varsaw.(func:{arg sig; sig.tanh});
~p[\sin5].set(\freq, ~p[\freqe], \amp, 0.1, \lag, 0.1);
~p[\sin5].play
~p[\sin5].stop

~p[\mix1].clear;
~p[\mix1][0] = ~p[\sin1];
~p[\mix1][1] = ~p[\sin2];
~p[\mix1][2] = ~p[\sin3];
~p[\mix1][3] = ~p[\sin4];
~p[\mix1][4] = ~p[\sin5];
~p[\mix1].play
~p[\mix1].stop

~p[\splay3] = ~splay.(chans:~p[\mix1].numChannels);
~p[\splay3] <<> ~p[\mix1];
~p[\splay3].play
~p[\splay3].stop;

~p[\delay].stop
~p[\verb].play;
~p[\verb].vol = 0.1
~p[\verb].stop;

~p[\comb_long] = ~comb_long.(chans:~p[\splay3].numChannels);
~p[\comb_long] <<> ~p[\splay3];
~p[\comb_long].play;
~p[\comb_long].set(\wet, 0.4)

~p[\gh] = ~greyhole.(chans:~p[\comb_long].numChannels);
~p[\gh] <<> ~p[\comb_long];
~p[\gh].play
~p[\gh].set(\wet, 0.4)