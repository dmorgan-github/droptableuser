
~p2 = ProxySpace.new(s);
~p2_obj = ~ps_helper.(~p2);

/////////////////////////////////
// lfo1
~p2[\lfo1] = ~lfo.(wave:\sin);
~p2[\lfo1].set(\freq, 1/256, \min, 0.1, \max, 0.9)
~p2[\lfo1].scope

/////////////////////////////////
// lfo2
~p2[\lfo2] = ~lfo.(wave:\sin);
~p2[\lfo2].set(\freq, 1/128, \min, 1.01, \max, 2.01);
~p2[\lfo2].scope

/////////////////////////////////
// lfo3
~p2[\lfo3] = ~lfo.(wave:\sin);
~p2[\lfo3].set(\freq, 1/56, \min, 1.01, \max, 4.01);
~p2[\lfo3].scope


/////////////////////////////////
// lfo4
~p2[\lfo4] = ~lfo.(wave:\sin);
~p2[\lfo4].set(\freq, 1/32, \min, 0, \max, 1);
~p2[\lfo4].scope

/////////////////////
// synth
~p2[\s1] = ~fm7.(6);
(~p2[\s1].set(
	\f0, 1,
	\f1, 1,
	\f2, 2,
	\f3, 1,
	\f4, ~p2[\lfo3],
	\f5, ~p2[\lfo2],

	\f0amp, 1,
	\f1amp, 1,
	\f2amp, 1,
	\f3amp, 1,
	\f4amp, ~p2[\lfo4],
	\f5amp, 1,

	\fb, ~p2[\lfo1]
));

[ 0, 2, 4 ]
//~p1[\s1].set(\amp, 1, \freq, ~p1[\freq]);
~p2[\s1].set(\amp, 1, \freq, 'C2'.namecps);
~p2[\s1].play;
~p2[\s1].stop;

~p2_obj.route(\s1, \stereo -> \splay);
~p2_obj.route(\stereo, \jpverb -> \jpverb).set(\sizeL, 3, \sizeR, 5);
~p2[\jpverb].set(\wet, 0.5, \modFreqL, 4, \modFreqR, 4, \modDepthL, 0.5, \modDepthR, 0.1);

~p2_obj.route(\jpverb, \dis -> \disintegrator, 0.3);


~p2[\lfo5] = ~lfo.(\sin);
~p2[\lfo5].set(\freq, 1/32, \min, 0.9, \max, 1.1);

~p2_obj.route(\dis, \dfm1 -> \dfm1).set(\freq, 'C4'.namecps, \res, ~p2[\lfo5])
~p2[\dfm1].vol = 0.1

~p2[\dfm1].play

~p2_obj.route(\dfm1, \rnd -> \rnd_delay).set(\rateL, 5, \rateR, 10);
~p2[\rnd].vol = 0.1;

App.record;
~p2[\rnd].play(fadeTime:5);

~p2_obj.stop_all(5);
s.stopRecording;

~p2_obj.ls_monitor

~p2_obj.edit_all();


s.stopRecording
