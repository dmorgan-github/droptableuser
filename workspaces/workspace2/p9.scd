
/////////////////////////////////
// trigger
~p9[\trig] = { Impulse.kr(4); };

////////////////////////////////
// pos
~p9[\lfo1] = ~lfo.(wave:\saw)
~p9[\lfo1].set(\freq, 0.1, \min, 0, \max, 1);

////////////////////////////////
// dur
~p9[\lfo2] = ~lfo.(wave:\noise);
~p9[\lfo2].set(\freq, 0.1, \min, 0.1, 0.5)

~p9[\lfo3] = ~lfo.(wave:\noise);
~p9[\lfo3].set(\freq, 0.5, \min, 0.1, 0.5)


~p9 = ProxySpace.new(s);
~p9_buf = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/cellos.mono.aiff");
~p9[\grain1] = ~grain_buf.(buf:~p9_buf);
(
~p9[\grain1].set(
	\trig, ~p9[\trig],

	\posL, ~p9[\lfo1],
	\posR, ~p9[\lfo1],

	\durL, ~p9[\lfo2],
	\durR, ~p9[\lfo3]
)
)

~p9[\stereo1] = ~splay.(chans:~p9[\grain1].numChannels);
~p9[\stereo1] <<> ~p9[\grain1];
~p9[\stereo1].play
~p9[\stereo1].stop

~p9[\grey] = ~greyhole.(chans:~p9[\stereo1].numChannels);
~p9[\grey] <<> ~p9[\stereo1];
~p9[\grey].play
~p9[\grey].stop
~p9[\grey].vol = 0.15


~p9_helper = ~ps_helper.(~p9);
~p9_helper.ls_monitor();
grey

App.record
s.stopRecording;