TempoClock.default.tempo_(60/60);

~p4 = ProxySpace.new(s);

~buf = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/citystreet.mono.aiff");

~p4[\smpl] = ~playbuf.(buf:~buf, trig:1, loop:1);
~p4[\smpl].play;
~p4[\smpl].stop;

~p4[\bpf] = ~bpf_ratios.(chans:1, base:432, ratios:Scale.minorPentatonic.ratios);
~p4[\bpf] <<> ~p4[\smpl];

(
~p4[\bpf].set(\amp_0, 20, \amp_1, 20, \amp_2, 30, \amp_3, 30, \amp_4, 30,
	\rq_0, 0.001,
	\rq_1, 0.003,
	\rq_2, 0.005,
	\rq_3, 0.0005,
	\rq_4, 0.0005
);
);

~p4[\bpf].set(\lag, 0.1);
~p4[\bpf][2] = \set -> Pbind(\freq, Pseq(['C3','D3','F3','Bb2'].namecps, inf), \delta, 8, \base, Pkey(\freq));
~p4[\bpf].set(\wet, 0.9)

~p4[\stereo] = ~splay.(chans:~p4[\bpf].numChannels);
~p4[\stereo] <<> ~p4[\bpf];
~p4[\stereo].play;
~p4[\stereo].stop;

~p4[\comb_long] = ~comb_long.(chans:~p4[\stereo].numChannels);
~p4[\comb_long] <<> ~p4[\stereo];
~p4[\comb_long].set(\wet, 1)

~p4[\stereo4] = ~splay.(chans:~p4[\comb_long].numChannels);
~p4[\stereo4] <<> ~p4[\comb_long];
~p4[\stereo4].play
~p4[\stereo4].stop
~p4[\stereo4].mold


~p4[\grey] = ~greyhole.(chans:~p4[\stereo4].numChannels);
~p4[\grey] <<> ~p4[\stereo4];
~p4[\grey].play(fadeTime:8);
~p4[\grey].stop;
~p4[\grey].vol = 0.3


~p4[\copy1] = ~p4[\grey].copy

~p4[\perc1] = ~tperc.();
~p4[\perc1][2] = \set -> Pbind(\trig, 1, \delta, Pseq([4,[1,1,1,[1,[1,1,1]]]].convertRhythm, inf), \rel, 0.1)

~p4[\copy1]

~p4[\snd] = { ~p4[\copy1] * ~p4[\perc1] };
~p4[\snd].play
~p4[\snd].stop

~p4[\freqshift] = {

	var in = \in.ar([0,0]);
	var fx = FreqShift.ar(in, 2);
	fx;
};

~p4[\freqshift] <<> ~p4[\snd];
~p4[\freqshift].play
~p4[\freqshift].stop

~p4[\fb] = ~feedback.(chans:~p4[\freqshift].numChannels, decay:0.4, delay:0.375)
~p4[\fb] <<> ~p4[\freqshift];
~p4[\fb].set(\wet, 0.5)
~p4[\fb].play
~p4[\fb].stop



~p4[\wtf] = {
	var in = ~p4[\comb_long].ar[2];
	var sig = in ring1: Saw.ar(LFNoise1.kr(10).range(200,600));
	WaveLoss.ar(sig!2);
};
~p4[\wtf].mold;
~p4[\wtf].play(fadeTime:8);
~p4[\wtf].stop(fadeTime:8);
~p4[\wtf].vol = 0.6


s.stopRecording

(
{
	App.record;

	~p4[\wtf].play(fadeTime:8);
	32.wait;
	~p4[\fb].play(fadeTime:16);
	~p4[\grey].play(fadeTime:16);

	16.wait;
	~p4[\wtf].stop(fadeTime:16);

	128.wait;
	~p4[\grey].stop(fadeTime:8);
	~p4[\fb].stop(fadeTime:8);

}.fork;
)
