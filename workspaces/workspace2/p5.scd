
TempoClock.default.tempo_(220/60)


~p4 = ProxySpace.new(s);
~p4.quant = 1.0;

~p4[\s1] = ~saw.();
~p4[\s1][2] = \set -> Pbind(\degree, Prand([0,1,2,3], inf), \delta, 0.5);
~p4[\s1].play
~p4[\s1].stop;

~p4[\fenv] = ~tline.();
~p4[\fenv][2] = \set -> Pbind(\trig, 1, \start, 1000, \end, Pseq([220, 6600, 4400, 440], inf), \dur, 0.5);


(
~p4[\varlag] = {
	var val = \val.kr;
	VarLag.kr(val, \dur.kr(0.1), \curve.kr(0), \warp.kr(5));
};
)
~p4[\varlag][2] = \set -> Pbind(\val, Pseq([220, 6600, 4400, 840], inf), \delta, 0.5, \dur, 0.1, \curve, -4);


~p4[\f1] = ~rlpf.();
~p4[\f1] <<> ~p4[\s1];
~p4[\f1].set(\freq, ~p4[\varlag], \rq, 0.5)
~p4[\f1].play;
~p4[\f1].stop


//~feedback.def.argNames

~p4[\fb] = ~feedback.(chans:~p4[\f1].numChannels, decay:0.4);
~p4[\fb] <<> ~p4[\f1];
~p4[\fb].set (\wet, 0.4, \tempo, 1, \decay, 0.7 )
~p4[\fb].play;
~p4[\fb].stop

~p4[\stereo] = ~splay.(chans:~p4[\fb].numChannels);
~p4[\stereo] <<> ~p4[\fb];
~p4[\stereo].play


App.record


