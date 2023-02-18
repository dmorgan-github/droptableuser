(
synth: {|freq, gate, aeg|

    var pitch = A2K.kr(freq).cpsmidi;
    var struct = \struct.kr(0.25, spec:ControlSpec(0, 1, \lin, 0, 0.25, "rings"));
    var bright = \bright.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, "rings"));
    var damp = \damp.kr(0.7, spec:ControlSpec(0, 1, \lin, 0, 0.7, "rings"));
    var pos = \pos.kr(0.25, spec:ControlSpec(0, 1, \lin, 0, 0.25, "rings"));
    var model = \model.kr(0, spec:ControlSpec(0, 5, \lin, 1, 0, "rings"));
    var poly = \poly.kr(1, spec:ControlSpec(1, 4, \lin, 1, 1, "rings"));
    var exciter = ~exciter ?? {0};

    var sig = MiRings.ar(
        in: exciter.value,
        trig: gate,
        pit: pitch,
        struct: struct,
        bright: bright,
        damp: damp,
        pos: pos,
        model: model,
        poly: poly,
        //intern_exciter: 1
    );

    var even = sig[0];
    var odd = sig[1];
    var evenodd = \evenodd.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, "rings"));

    sig = even.blend(odd, evenodd).asArray.sum;
    sig
},
doc: "
0: MODAL_RESONATOR
1: SYMPATHETIC_STRING
2: MODULATED/INHARMONIC_STRING
3: 2-OP_FM_VOICE
4: SYMPATHETIC_STRING_QUANTIZED
5: STRING_AND_REVERB

[EVEN, ODD] - In monophonic mode, these two outputs carry two complementary components of the signal
(odd and even numbered partials with the modal resonator, dephased components due to picking position
and pickup placement with the string resonators). In polyphonic mode, splits the signal into odd
and even numbered strings/plates.
"
)
