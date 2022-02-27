~synthdef = SynthDef(\vsti, { |out| Out.ar(out, VSTPlugin.ar(Silent.ar(2), 2)) });
~synthdef.add;

////////////////////////////////////////
Ndef(\vst).play

~synth = Synth(\vsti, args: [\out, Ndef(\vst).bus.index], target: Ndef(\vst).group.nodeID)
~vstplugin = VSTPluginController(~synth, synthDef:~synthdef)
~vstplugin.open("Surge XT.vst3", editor: true);
~vstplugin.open("Kaivo", editor: true);
~vstplugin.editor
~vstplugin.gui
// friendly 2
// piano remains 1

Kaivo
V.ls
VSTPlugin.clear
VSTPlugin.search



MIDIClient.init;
m = MIDIOut(0);
m.connect
MIDIOut

(
var val;
val = [
    Y.compm(5, 3).choose,
    Y.compm(7, 4).choose
];

// [ [ 1, 3, 1 ], [ 1, 1, 4, 1 ] ]
val = [ [ 3, 1, 1 ], [ 1, 2, 2, 2 ] ];
Pdef(\vstmidi,

    Pdef('pdv')
    <>
    [
        \type, \vst_midi,
        \vst, ~vstplugin, // the VSTPluginController instance
        //'degree': [ [0, 2, 4], [1, 3, 5, 6] ],
        'degree': val.postln,
        'stretch': 1,
        //'octave': Y.chsequl(\upper, 4, 7).linlin(0, 1, 5, 6).pseq -1,
        'octave': Pmap(3, 7, 5, 6), // + [0, 1] - 1,
        'mtranspose': Pstep([0, 2].pseq, [4, 4].pseq),
        'legato': 2,
        'rel': 1,
        //'harmonic': [1, 1.5],
        'scale': Scale.yu
    ].p
)
)

Pdef(\vstmidi).play
Pdef(\vstmidi).stop