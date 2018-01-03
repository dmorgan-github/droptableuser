
~p5 = ProxySpace.new(s);

~p5_buf = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/163485__erh__free-piano-acs-1.aiff");

~p5[\smpl] = ~playbuf.(buf:~p5_buf, trig:1, loop:1);
~p5[\smpl].set(\rate, 0.5);
~p5[\smpl].play;
~p5[\smpl].stop
~p5[\smpl].mold

~p5[\dist] = ~barrys.(chans:~p5[\smpl].numChannels);
~p5[\dist] <<> ~p5[\smpl];
~p5[\dist].play;
~p5[\dist].stop;
~p5[\dist].set(\wet, 0.05)

~p5[\grey] = ~greyhole.(chans:~p5[\dist].numChannels);
~p5[\grey] <<> ~p5[\dist];

~p5[\bpf] = ~bpf_ratios.(chans:~p5[\grey].numChannels, base:432, ratios:Scale.minorPentatonic.ratios);
~p5[\bpf] <<> ~p5[\grey];
~p5[\bpf].unset(\base)
~p5[\bpf][2] = \set -> Pbind(\base, Pseq(['C3', 'D3'].namecps, inf), \delta, 16).trace


~p5[\lfo1] = ~lfo.(wave:\sin);
~p5[\lfo1].set(\freq, 1/16, \min, 0, \max, 30)

~p5[\lfo2] = ~lfo.(wave:\sin);
~p5[\lfo2].set(\freq, 1/16, \min, 0.005, \max, 0.01)


(
~p5[\bpf].set(\amp_0, 20, \amp_1, 20, \amp_2, 30, \amp_3, 30, \amp_4, ~p5[\lfo1],
	\rq_0, 0.01,
	\rq_1, 0.003,
	\rq_2, 0.05,
	\rq_3, 0.005,
	\rq_4, ~p5[\lfo2]
);
);
~p5[\bpf].set(\wet, 0.5)

~p5[\stereo] = ~splay.(chans:~p5[\bpf].numChannels);
~p5[\stereo] <<> ~p5[\bpf]
~p5[\stereo].play


~rnd_delay.def.argNames
~p4[\rnd] = ~rnd_delay.(chans:~p5[\stereo].numChannels)
~p4[\rnd] <<> ~p5[\stereo];
~p4[\rnd].set(\rateL, 2, \rateR, 7)
~p4[\rnd].vol = 0.3
~p4[\rnd].play

App.record
s.stopRecording