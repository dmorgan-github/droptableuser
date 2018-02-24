
~noise_buf = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/windows-system-samples/clbcatq.wav");
~p[\oneshot] = ~oneshot.(buf:~noise_buf);
~p[\oneshot].set(\trig, 1, \rate, 0.07, \start, 0.1, \end, 0.10241);
~p[\oneshot].play;

~p[\oneshot_verb] = ~jpverb.(chans:~p[\oneshot].numChannels);
~p[\oneshot_verb] <<> ~p[\oneshot]
~p[\oneshot_verb].set(\wet, 0.6);
~p[\oneshot_verb].play
~p[\oneshot_verb].vol = 0.3

(
~p[\phase] = {
	LFNoise1.ar(0.05) * BufFrames.ir(~noise_buf);
};
)


~p[\bufrd] = ~bufrd.(buf:~noise_buf);
~p[\bufrd].set(\phase, ~p[\phase]);
~p[\bufrd].play
~p[\bufrd].stop(fadeTime:10)
~p[\bufrd].vol = 0.3

~p[\bufrd_verb] = ~jpverb.(chans:~p[\bufrd].numChannels);
~p[\bufrd_verb] <<> ~p[\bufrd]
~p[\bufrd_verb].set(\wet, 0.3);
~p[\bufrd_verb].play(fadeTime:5);
~p[\bufrd_verb].stop(fadeTime:10);
~p[\bufrd_verb].vol = 0.05


