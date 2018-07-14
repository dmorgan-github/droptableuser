~p = ProxySpace.new(s);
~p.quant = 1.0;

(~p[\bass_seq][0] = {
	var trig = \trig.tr;
	var freq = \freq.kr;
	[trig, freq];
});
(~p[\bass_seq][4] = \set -> Pbind(
	\delta, 1,
	\trig, 1,
	\scale, Scale.kumoi,
	\freq, Pseq(['C1', 'C1', 'C1', 'C1', 'F1', 'F1', 'F1', 'Eb1'].namecps, inf)
))

~p[\basstrig] = {~p[\bass_seq].kr[0]};
~p[\bassfreq] = {~p[\bass_seq].kr[1]};

~p[\bassenv] = ~tlinen.();
~p[\bassenv].set(\trig, ~p[\basstrig], \atk, 1, \sus, 8, \rel, 6)
~p[\bassenv].set(\trig, ~p[\basstrig], \sus, 0.5, \rel, 0.5)

//~p[\bass].clear;

~varsaw.def.sourceCode

~p[\basswidthlfo] = ~lfo.(wave:\sin, freq:1/8, min: 1/16, max: 1/8);
~p[\basswidth] = ~lfo.(wave:\tri, freq:1/16, min:0.3, max:0.7);
~p[\basswidth].set(\freq, ~p[\basswidthlfo]);

~p[\bass][0] = ~varsaw.(freq:[432]);
~p[\bass][1] = {~pulse.(freq:[432]) * 0.0};
~p[\bass].set(\freq, ~p[\bassfreq], \amp, ~p[\bassenv], \vdepth, 0.002, \width, ~p[\basswidth]);
~p[\bass].play
~p[\bass].stop
~p[\bass].vol = 0.5

~p[\bassdist] = ~waveloss.(chans:~p[\bass].numChannels);
~p[\bassdist] <<> ~p[\bass];
~p[\bassdist].set(\set, 0.2)
~p[\bassdist].play
~p[\bassdist].stop

~dfm1.def.sourceCode
~p[\bassffreq] = {~p[\bassfreq].kr * 2}
~p[\bassffreq] = {DC.kr(2200)}
//~p[\bassdfm1].clear;

~lfo.def.sourceCode
~p[\basslfo] = ~lfo.(wave:\sin, freq:1/8, min:220, max:990);
~p[\bassdfm1] = ~dfm1.(chans:~p[\bassdist].numChannels);
~p[\bassdfm1] <<> ~p[\bassdist];
~p[\bassdfm1].set(\freq, ~p[\basslfo], \res, 0.2, \noiselevel, 0.001);
~p[\bassdfm1].play
~p[\bassdfm1].stop
~p[\bassdfm1].gui
~p[\bassdfm1].vol = 1

~chorus.def.sourceCode
~p[\basschorus].clear;
~p[\basschorus] = ~chorus.(chans:~p[\bassdfm1].numChannels);
~p[\basschorus] <<> ~p[\bassdfm1];
~p[\basschorus].play
~p[\basschorus].stop
~p[\basschorus].gui
~p[\basschorus].set(\wet, 0.3, \t, 10, \width, 1, \rate, 1.5, \fwd, 0.3, \fb, 0.1)
~p[\basschorus].vol = 1

~p[\bassverb].clear;
~p[\bassverb] = ~gverb.(chans:~p[\basschorus].numChannels, roomsize:30);
~p[\bassverb] <<> ~p[\basschorus];
~p[\bassverb].set(\revtime, 3, \damping, 0.5, \inputbw, 0.5, \drylevel, 0, \earlyreflevel, 0.7, \taillevel, 0.2);
~p[\bassverb].set(\wet, 0.4);
~p[\bassverb].play
~p[\bassverb].vol = 0.2

App.recordVersion
s.stopRecording
