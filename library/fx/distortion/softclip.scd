(
synth: {|in|

    var gain, sig, hi, lo;
    sig = HPF.ar(in, \softclip_hpf.kr(20, spec: ControlSpec(20, 8000, \exp, 0, 20, "softclip")));
    sig = LPF.ar(sig, \softclip_lpf.kr(8000, spec: ControlSpec(1000, 8000, \exp, 0, 20000, "softclip")));
    gain = \softclip_drive.ar(1, spec: ControlSpec(1, 20, \lin, 0, 1, units:"softclip")).lag(0.01);
    sig = SoftClipAmp8.ar(sig, gain) * (gain.reciprocal.sqrt);
    sig = LeakDC.ar(sig) * 0.5;
    sig = in.blend(sig, \softclip_mix.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.3, "softclip")));
    sig
}
)
