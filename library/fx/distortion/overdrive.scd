(
synth: {|in|

    var gain, sig, hi, lo;
    sig = HPF.ar(in, \hpf.kr(20, spec: ControlSpec(20, 8000, \exp, 0, 20, "overdrive")));
    sig = LPF.ar(sig, \lpf.kr(8000, spec: ControlSpec(1000, 8000, \exp, 0, 8000, "overdrive")));
    gain = [
        \gainL.ar(1, spec: ControlSpec(1, 100, \lin, 0, 1, units:"overdrive")).lag(0.01), 
        \gainR.ar(1, spec: ControlSpec(1, 100, \lin, 0, 1, units:"overdrive")).lag(0.01)
    ];
    sig = SoftClipAmp8.ar(sig, gain) * (gain.reciprocal.sqrt);
    sig = LeakDC.ar(sig) * \output.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, "overdrive"));
    sig = in.blend(sig, \overdrive_mix.kr(0.3), spec: ControlSpec(0, 1, \lin, 0, 0.3, "overdrive"));
    sig
}
)
