~p2 = ProxySpace.new;
~p2.quant = 4.0;

(
~p2[\seq] = {

	var trig = \trig.tr;
	var freq = \freq.kr;

	[trig,freq];
};
)
(~p2[\seq][2] = \set -> Pbind(
	\trig, 1,
	\delta, 8,
	\degree, Pseq([0,1], inf),
	\octave, 4,
));
~p2[\trig] = {~p2[\seq].kr[0]; };
~p2[\freq] = {~p2[\seq].kr[1] * [1, 3.01]};
~p2[\freq].mold;

~p2[\freq].numChannels

~p2[\e1] = ~tlinen.();
~p2[\e1].set(\trig, ~p2[\trig], \atk, 2, \sus, 1, \rel, 1);

~p2[\e2] = ~tlinen.(func:{arg env; env.range(0.2, 0.7)});
~p2[\e2].set(\trig, ~p2[\trig], \atk, 2, \sus, 1, \rel, 1);


~p2[\s] = ~sinoscfb.(freq:[0,0], func:{arg sig;sig.distort});
~p2[\s][2] = ~varsaw.(freq:[0,0], func:{arg sig;sig.tanh});

~p2[\s].set(\freq, ~p2[\freq], \amp, ~p2[\e1], \fb, ~p2[\e2], \width, ~p2[\e2]);
~p2[\s].play;
~p2[\s].stop;
~p2[\s].vol = 0.05;
~p2[\s].mold;

~p2[\r] = ~greyhole.(~p2[\s].numChannels);
~p2[\r] <<> ~p2[\s];
~p2[\r].play;
~p2[\r].vol = 0.05;
~p2[\r].set(\wet, 0.5);



