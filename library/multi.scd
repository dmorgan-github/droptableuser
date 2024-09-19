(
synth: {|freq, gate, aeg|

    var osc1ratio = \osc1ratio.kr(1, spec: ControlSpec(1/8, 8, \lin, 0, 1, units: "multi"));
    var osc2ratio = \osc2ratio.kr(1, spec: ControlSpec(1/8, 8, \lin, 0, 1, units: "multi"));
    var osc3ratio = \osc3ratio.kr(1, spec: ControlSpec(1/8, 8, \lin, 0, 1, units: "multi"));
    var osc4ratio = \osc4ratio.kr(1, spec: ControlSpec(1/8, 8, \lin, 0, 1, units: "multi"));
    var skew = \skew.kr(0, spec: ControlSpec(-1.5, 1.5, \lin, 0, 0, units:"multi"));
    var width = \width.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, units:"multi"));
    var pw = \pw.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, units:"multi"));

    var sig1 = SinOscFB.ar(freq * osc1ratio, skew);
    var sig2 = VarSaw.ar(freq * osc2ratio, 0, width);
    var sig3 = Saw.ar(freq * osc3ratio);
    var sig4 = Pulse.ar(freq * osc4ratio, pw);

    var which = \which.kr(0, spec: ControlSpec(0, 3, \lin, 0, 1, units: "multi"));
    var sig = SelectX.ar(which, [sig1, sig2, sig3, sig4], wrap:true);
    sig;

},
presets: (
    preset1: [
        'fatk', 0.00018315018315018,
        'frel', 0.52747252747253,
        'which', 1.0549450549451,
        'width', 0.5,
        'cutoff', 3234.6046344323,
        'focus', 0.087912087912088,
        'frelcurve', -4.0029304029304,
        'pw', 0.5,
        'snappy', 0.93406593406593,
        'fatkcurve', -4.0029304029304,
        'skew', 0.53846153846154,
        'res', 0.41758241758242
    ]
),
doc: "
SinOscFB
Pulse
Saw
VarSaw
"
)