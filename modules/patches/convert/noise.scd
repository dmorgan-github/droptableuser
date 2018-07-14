
~noise_buf = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/windows-system-samples/clbcatq.wav");
~p[\oneshot] = ~oneshot.(buf:~noise_buf);
~p[\oneshot].set(\trig, 1, \rate, 0.08, \start, 0.1, \end, 0.1241);
~p[\oneshot].play;

~p[\oneshot_verb] = ~jpverb.(chans:~p[\oneshot].numChannels);
~p[\oneshot_verb] <<> ~p[\oneshot]
~p[\oneshot_verb].set(\wet, 0.6);
~p[\oneshot_verb].play
~p[\oneshot_verb].vol = 0.2