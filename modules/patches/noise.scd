
~os = ProxySpace.new(s);
~os.quant = 1.0;

~noise_buf = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/windows-system-samples/clbcatq.wav");
~os[\oneshot] = ~oneshot.(buf:~noise_buf);
~os[\oneshot].set(\trig, 1, \rate, 0.07, \start, 0.1, \end, 0.10241);
~os[\oneshot].play;

~os[\oneshot_verb] = ~jpverb.(chans:~p[\oneshot].numChannels);
~os[\oneshot_verb] <<> ~os[\oneshot]
~os[\oneshot_verb].set(\wet, 0.6);
~os[\oneshot_verb].play
~os[\oneshot_verb].vol = 0.3

(
~os[\phase] = {
	LFNoise1.ar(0.05) * BufFrames.ir(~noise_buf);
};
)


~os[\bufrd] = ~bufrd.(buf:~noise_buf);
~os[\bufrd].set(\phase, ~os[\phase]);
~os[\bufrd].play
~os[\bufrd].stop(fadeTime:10)
~os[\bufrd].vol = 0.3

~os[\bufrd_verb] = ~jpverb.(chans:~os[\bufrd].numChannels);
~os[\bufrd_verb] <<> ~os[\bufrd]
~os[\bufrd_verb].set(\wet, 0.3);
~os[\bufrd_verb].play(fadeTime:5);
~os[\bufrd_verb].stop(fadeTime:10);
~os[\bufrd_verb].vol = 0.05


