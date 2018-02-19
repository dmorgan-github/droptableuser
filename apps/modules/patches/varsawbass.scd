

(~p[\bass_seq][0] = {
	var trig = \trig.tr;
	var freq = \freq.kr;
	[trig, freq];
});
(~p[\bass_seq][4] = \set -> Pbind(
	\trig, 1,
	\scale, Scale.kumoi,
	\freq, Pseq(['C1', 'C1', 'C1', 'C1', 'F1', 'F1', 'Eb1'].namecps, inf)
))

~p[\basstrig] = {~p[\bass_seq].kr[0]};

~p[\bassfreq].mold
~p[\bassfreq] = {~p[\bass_seq].kr[1] * [1, 1.01]};

~p[\bassenv] = ~tlinen.();
~p[\bassenv].set(\trig, ~p[\basstrig], \sus, 0.5, \rel, 0.5)

~p[\bass][0] = ~varsaw.(freq:[432,432]);
~p[\bass].set(\freq, ~p[\bassfreq], \amp, ~p[\bassenv]);
~p[\bass].play
~p[\bass].stop
~p[\bass].vol = 0.5

~dfm1.def.sourceCode
~p[\bassffreq] = {~p[\bassfreq].kr * 2}
~p[\bassdfm1] = ~dfm1.(chans:~p[\bass].numChannels);
~p[\bassdfm1] <<> ~p[\bass];
~p[\bassdfm1].set(\freq, ~p[\bassffreq], \res, 1);
~p[\bassdfm1].play
~p[\bassdfm1].stop
~p[\bassdfm1].vol = 0.2

~p[\bassverb] = ~gverb.(chans:~p[\bassdfm1].numChannels, roomsize:250);
~p[\bassverb] <<> ~p[\bassdfm1];
~p[\bassverb].set(\revetime, 20, \damping, 0.1, \inputbw, 0.1, \drylevel, 0, \earlyreflevel, 0.3, \taillevel, 0.3);
~p[\bassverb].set(\wet, 0.6);
~p[\bassverb].play
~p[\bassverb].vol = 0.3
