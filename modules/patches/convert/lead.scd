
~p = ProxySpace.new(s);
~p.quant = 1.0;

(~p[\leadseq][0] = {
	var trig = \trig.tr;
	var freq = \freq.kr;
	var dur = \dur.kr;
	[trig, freq, dur];
});
(~p[\leadseq][4] = \set -> Pbind(

	\trig, 1,
	\delta, 0.25,
	\beatDur, Pfunc({thisThread.clock.beatDur;}),
	\dur, Pkey(\delta) * Pkey(\beatDur) * 0.5,
	\midinote, Pseq([ 60, 58, 60, 58, 65, 58, 55 ], inf)
))

~p[\leadfreq] = {~p[\leadseq].kr[1]};
~p[\leadtrig] = {~p[\leadseq].kr[0]};

~p[\leadenv] = ~tperc.();
~p[\leadenv].set(\trig, ~p[\leadtrig])

~p[\lead][0] = ~sawdpw.();
~p[\lead][1] = ~sinosc.();
~p[\lead].set(\freq, ~p[\leadfreq], \amp, ~p[\leadenv], \lag, 0.02);
~p[\lead].play
~p[\lead].stop

~p[\leadlfo] = ~lfo.(wave:\sin, freq:0.05, min:'D4'.namecps, max:'G5'.namecps);
~p[\leadmoogf] = ~moogff.(chans:~p[\lead].numChannels);
~p[\leadmoogf].set(\freq, ~p[\leadlfo], \rq, 0.08)
~p[\leadmoogf] <<> ~p[\lead];
~p[\leadmoogf].play
~p[\leadmoogf].stop

~p[\leadlpf] = ~lpf4.(chans:~p[\leadmoogf].numChannels);
~p[\leadlpf] <<> ~p[\leadmoogf];
~p[\leadlpf].set(\freq, 'C6'.namecps);
~p[\leadlpf].play
~p[\leadlpf].stop

~p[\leadverb] = ~gverb.(chans: ~p[\leadlpf].numChannels, roomsize:75);
~p[\leadverb].set(\revtime, 20, \drylevel, 0.4, \earlyreflevel, 0.5, \taillevel, 0.4);
~p[\leadverb] <<> ~p[\leadlpf];
~p[\leadverb].set(\wet, 0.3)
~p[\leadverb].play

