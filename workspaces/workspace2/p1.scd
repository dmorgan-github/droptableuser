TempoClock.default.tempo_(70/60);

~p1 = ProxySpace.new;
~p1.quant = 1.0;
~p1_obj = ~ps_helper.(~p1);

(
~p1[\seq] = {
	var trig = \trig.tr;
	var freq = \freq.kr;
	[trig,freq];
};
)
(~p1[\seq][2] = \set -> Pbind(
	\trig, 1,
	\delta, Pseq([0.25, 0.25, 0.25, 7.25], inf),
	\degree, Pseq([0,1,3,2], inf),
	\scale, Scale.minorPentatonic,
	\octave, 4,
	\mtranspose, 0
));
~p1[\trig] = {~p1[\seq].kr[0]};
~p1[\freq] = {~p1[\seq].kr[1]};

//////////////////////
// amp
~p1[\env] = ~tperc.();
~p1[\env].set(\trig, ~p1[\trig]);

~p1[\e2] = ~tline.();
~p1[\e2].set(\trig, ~p1[\trig], \start, 1, \end, 0, \dur, 0.01);

~p1[\e3] = ~tline.();
~p1[\e3].set(\trig, ~p1[\trig], \start, 1, \end, 0, \dur, 0.1);

~p1[\e3b] = ~tline.();
~p1[\e3b].set(\trig, ~p1[\trig], \start, 1, \end, 0, \dur, 0.5);

~p1[\e4] = ~tline.();
~p1[\e4].set(\trig, ~p1[\trig], \start, 2.01, \end, 4.011, \dur, 0.15);

///////////////////////
~p1[\lfo2] = ~lfo.(wave:\sin);
~p1[\lfo2].set(\freq, 1/128, \min, 2.1, \max, 5.1);

///////////////////////
~p1[\lfo3] = ~lfo.(wave:\sin);
~p1[\lfo3].set(\freq, 1/256, \min, 2.1, \max, 5.1);

///////////////////////
~p1[\lfo4] = ~lfo.(wave:\sin);
~p1[\lfo4].set(\freq, 1/512, \min, 0.1, \max, 1);

/////////////////////
// synth
~p1[\s1] = ~fm7.(2);
(~p1[\s1].set(
	\f0, 1,
	\f1, 1,
	\f2, 3,
	\f3, 2.01,
	\f4, ~p1[\lfo3],
	\f5, ~p1[\lfo2],

	\f0amp, ~p1[\e3],
	\f1amp, ~p1[\e3],
	\f2amp, ~p1[\e3],
	\f3amp, ~p1[\e3b],
	\f4amp, ~p1[\e3],
	\f5amp, ~p1[\e3b],

	\fb, ~p1[\lfo4],//~p1[\e2]
));
//~p1[\s1].set(\amp, 1, \freq, ~p1[\freq]);
~p1[\s1].set(\amp, 1, \freq, ~p1[\freq]);
~p1[\s1].play;
~p1[\s1].stop;
~p1[\s1].gui;
~p1[\s1].mold;

// to stereo
~p1_obj.route(\s1, \stereo -> \splay);

// lfo
~p1[\e5] = ~lfo.(\sin);
~p1[\e5].set(\freq, 0.05, \min, 880, \max, 22000)

//////////////////////////
// path 1
// stereo to rlpf
~p1_obj.route(\stereo, \rlpf -> \rlpf)
~p1[\rlpf].set(\freq, ~p1[\e5], \rq, 0.1);

// rlpf to reverb
~p1_obj.route(\rlpf, \verb -> \jpverb, 0.5);

// reverb to delay
~p1_obj.route(\verb, \delay -> \delayorama, 0.5);
~p1[\verb].stop;

~p1.arProxyNames.do({arg name; ~p1[name].stop(fadeTime:8)})

~p1.arProxyNames.do({arg name; ~p1[name].isMonitoring.if({name.postln});})


/////////////////////////
// path 2
// stereo to reverb
~p1_obj.route(\stereo, \gverb -> \gverb, 0.3);
~p1[\gverb] = ~gverb.(roomsize:50);
~p1[\gverb].set(\revtimeL, 10, \revtimeR, 20, \taillevelL, 0.7, \taillevelR, 0.8);

~p1[\gverb].isMonitoring

// reverb to waveloss
~p1_obj.route(\gverb, \waveloss -> \waveloss);

////////////////////////
// path 2a
// waveloss to dfm1
~p1_obj.route(\waveloss, \dfm1 -> \dfm1).set(\freq, 2200, \res, 0.5);

///////////////////////
// path 2b
// waveloss to dfm1
~p1_obj.route(\waveloss, \dfm1_2 -> \dfm1).set(\freq, 4200, \res, 0.8);

// dfm1 to reverb
~p1_obj.route(\dfm1_2, \jpverb -> \jpverb).set(\sizeL, 5, \sizeR, 3);

~p1[\jpverb].play
~p1[\dfm1].play



App.record
s.stopRecording










