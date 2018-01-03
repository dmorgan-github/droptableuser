~p10 = ProxySpace.new(s);
~p10_buf = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/windows-system-samples/cdosys.dll.wav");
~p10_buf2 = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/windows-system-samples/winntbbu.wav");
~p10_buf2.numChannels

~p10[\phase] = {
	LFNoise1.ar(0.5) * BufFrames.ir(~p10_buf2);
};

~p10[\bufrd] = ~bufrd.(buf:~p10_buf2);
~p10[\bufrd].set(\phase, ~p10[\phase]);
~p10[\bufrd].play;
~p10[\bufrd].stop;

~p10[\gverb] = ~gverb.(chans:~p10[\bufrd].numChannels, roomsize:50);
~p10[\gverb] <<> ~p10[\bufrd];
~p10[\gverb].set(\revtimeL,30, \revtimeR,50)
~p10[\gverb].play
~p10[\gverb].vol = 0.02