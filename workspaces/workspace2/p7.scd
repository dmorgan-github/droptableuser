~p6 = ProxySpace.new(s);
~p6_buf = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/angels.d.mono.aiff");
~p6[\smpl] = ~bufloop.(buf:~p6_buf);
~p6[\smpl].set(\start, 0.5, \end, 0.8, \rate, 0.3, \lag, 0.01);
~p6[\smpl].play;
~p6[\smpl].stop;

~p6[\stereo] = ~splay.(chans:~p6[\smpl].numChannels);
~p6[\stereo] <<> ~p6[\smpl];
~p6[\stereo].play;
~p6[\stereo].stop;

~p6[\del1] = ~comb_long.(chans:~p6[\stereo].numChannels);
~p6[\del1] <<> ~p6[\stereo];
~p6[\del1].set(\wet, 0.5);
~p6[\del1].play;
~p6[\del1].stop;

~p6[\stereo2] = ~splay.(chans:~p6[\del1].numChannels);
~p6[\stereo2] <<> ~p6[\del1];
~p6[\stereo2].play;
~p6[\stereo2].stop;

~p6[\pitchshift] = ~pitchshift.(chans:~p6[\stereo2].numChannels, windowSize:0.5);
~p6[\pitchshift] <<> ~p6[\stereo2];
~p6[\pitchshift].set(\wet, 0.5, \pitchRatio, 4, \timeDispersion, 0.01)
~p6[\pitchshift].play
~p6[\pitchshift].stop

~p6[\rotate] = ~rotate.(chans:~p6[\pitchshift].numChannels);
~p6[\rotate] <<> ~p6[\pitchshift];
~p6[\rotate].play;

~p6_helper = ~ps_helper.(~p6);
~p6_helper.ls_monitor();

rotate
stereo
stereo2

App.record
s.stopRecording