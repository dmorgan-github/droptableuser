~wn = ProxySpace.new(s, \wn);

~wn[\s1] = ~noise.(\wn, amp:0.1);
~wn[\s1].play
~wn[\s1].stop;

~wn[\lfo1] = ~lfo.(wave:\sin);
~wn[\lfo1].set(\freq, 1/16, \min, 0.0005, \max, 0.0009);

~wn[\lfo2] = ~lfo.(wave:\sin);
~wn[\lfo2].set(\freq, 1/8, \min, 0.0001, \max, 0.0009);

~wn[\lfo3] = ~lfo.(wave:\sin);
~wn[\lfo3].set(\freq, 1/64, \min, 0.0005, \max, 0.0009);

~wn[\lfo4] = ~lfo.(wave:\sin);
~wn[\lfo4].set(\freq, 1/64, \min, 0, \max, 20);

~wn[\lfo5] = ~lfo.(wave:\sin);
~wn[\lfo5].set(\freq, 1/32, \min, 0, \max, 20);

~wn[\s1].play
~wn[\s1].stop

~ratios = Scale.minorPentatonic.ratios;
~wn[\bpf] = ~bpf_ratios.(1, base:432, ratios:~ratios)
~wn[\bpf] <<> ~wn[\s1];
(
~wn[\bpf].set(\amp_0, 20, \amp_1, 20, \amp_2, 20, \amp_3, 20, \amp_4, ~wn[\lfo5],
	\rq_0, ~wn[\lfo3],
	\rq_1, 0.0005,
	\rq_2, ~wn[\lfo2],
	\rq_3, 0.0005,
	\rq_4, ~wn[\lfo1]
);
);
~wn[\bpf].set(\base, 'D3'.namecps)
~wn[\bpf].play;
~wn[\bpf].stop;
~wn[\bpf].mold

~wn[\stereo] = ~splay.(chans:~wn[\bpf].numChannels);
~wn[\stereo] <<> ~wn[\bpf];
~wn[\stereo].play
~wn[\stereo].stop;
~wn[\stereo].vol = 1


~wn[\grey] = ~greyhole.(chans:2);
~wn[\grey] <<> ~wn[\stereo];
~wn[\grey].play
~wn[\grey].stop;


~wn[\rotate] <<> ~wn[\grey];
~wn[\rotate].play;
~wn[\rotate].stop;

App.record
s.stopRecording
