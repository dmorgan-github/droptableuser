(
synth: {|freq, gate, aeg|

    var pitch = A2K.kr(freq).cpsmidi;
    var trigger = \trig.tr(1);
    var timbre = \timbre.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, "braids"));
    var color = \color.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, "braids"));
    var model = \model.kr(0, spec:ControlSpec(0, 47, \lin, 1, 0, "braids"));
    var resamp = ~resamp ?? 0;
    var decim = \decim.kr(0, spec:ControlSpec(0, 32, \lin, 0, 0, "braids"));
    var bits = \bits.kr(0, spec:ControlSpec(0, 6, \lin, 1, 0, "braids"));
    var ws = \ws.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, "braids"));

    var sig = MiBraids.ar(
        pitch: pitch,
        timbre: timbre,
        color: color,
        model: model,
        trig: gate,
        resamp: resamp,
        decim: decim,
        bits: bits,
        ws: ws
    );

    sig
},
doc: "
Synthesis model (0 -- 47):
0:CSAW
1:MORPH
2:SAW_SQUARE
3:SINE_TRIANGLE
4:BUZZ
5:SQUARE_SUB
6:SAW_SUB
7:SQUARE_SYNC
8:SAW_SYNC
9:TRIPLE_SAW
10:TRIPLE_SQUARE
11:TRIPLE_TRIANGLE
12:TRIPLE_SINE
13:TRIPLE_RING_MOD
14:SAW_SWARM
15:SAW_COMB
16:TOY
17:DIGITAL_FILTER_LP
18:DIGITAL_FILTER_PK
19:DIGITAL_FILTER_BP
20:DIGITAL_FILTER_HP
21:VOSIM
22:VOWEL
23:VOWEL_FOF
24:HARMONICS
25:FM
26:FEEDBACK_FM
27:CHAOTIC_FEEDBACK_FM
28:PLUCKED
29:BOWED
30:BLOWN
31:FLUTED
32:STRUCK_BELL
33:STRUCK_DRUM
34:KICK
35:CYMBAL
36:SNARE
37:WAVETABLES
38:WAVE_MAP
39:WAVE_LINE
40:WAVE_PARAPHONIC
41:FILTERED_NOISE
42:TWIN_PEAKS_NOISE
43:CLOCKED_NOISE
44:GRANULAR_CLOUD
45:PARTICLE_NOISE
46:DIGITAL_MODULATION
47:QUESTION_MARK
"
)
