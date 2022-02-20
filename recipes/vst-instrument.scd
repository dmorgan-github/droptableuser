SynthDef(\vsti, { |out| Out.ar(out, VSTPlugin.ar(Silent.ar(2), 2)) }).add;
~synthdef = SynthDef(\vsti, { |out| Out.ar(out, VSTPlugin.ar(Silent.ar(2), 2)) });

////////////////////////////////////////
Ndef(\vst).play
Ndef(\vst).filter(100, {|in| FbC({|fb| fb * 0.3 + in}, 1, [3/4, 5/8]) })
Ndef(\vst).set(\wet100, 0.3)

~synth = Synth(\vsti, args: [\out, Ndef(\vst).bus.index], target: Ndef(\vst).group.nodeID)
~vstplugin = VSTPluginController(~synth, synthDef:~synthdef)
~vstplugin.open("Surge XT.vst3", editor: true);
~vstplugin.editor
~vstplugin.gui
// friendly 2
// piano remains 1

(
Pdef(\vstmidi,
    Pbind(
        \type, \vst_midi,
        \vst, ~vstplugin, // the VSTPluginController instance
        \degree, [0, 1, 2, 3, -1].pseq,
        \scale, Scale.zhi,
        \octave, Pmap(3, 8, 4, 5),
        \mtranspose, [0, 0, 0, 1, 2, 0].pseq,
        //\harmonic, [1, 1.5],
        \dur, 0.25,
        \amp, Pexprand(0.5, 1.0, inf)
    )
    .cycle(8)
)
)

Pdef(\vstmidi).play
Pdef(\vstmidi).stop