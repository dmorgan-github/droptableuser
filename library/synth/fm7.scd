(
synth: {|freq, gate|

    var vel = ~vel ?? 0;
    var velamt = ~velamt ?? 0.55;

    var algo = ~algo ?? 0;
    var mods = ~mods;
    var outs = ~outs ?? [0, 2];
    var sig;
    var fb = \fm7fb.kr(0, spec: ControlSpec(0, 1, \lin, 0, 0, "fm7"));

    var indexlforate = \indexlforate.kr(0, spec:ControlSpec(0, 20, \lin, 0, 0, "fm7"));
    var indexlfodepth = \indexlfodepth.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, "fm7"));
    var indexlfo = SinOsc.ar(indexlforate).unipolar(indexlfodepth);

    var ops = 6.collect({|i|

        var num = i + 1;
        var units = "op" ++ num;
        var ratio = ('op' ++ num ++ 'ratio').asSymbol.kr(1, spec: DMControlSpec(1/8, 31, \lin, 0.0, 1, units: units, sort:1) );
        var atk = ('op' ++ num ++ 'atk').asSymbol.kr(1, spec: DMControlSpec(0, 2, \lin, 0, 0.01, units: units, sort:2) );
        var dec = ('op' ++ num ++ 'dec').asSymbol.kr(1, spec: DMControlSpec(0, 1, \lin, 0, 0.2, units: units, sort:3) );
        var suslevel = ('op' ++ num ++ 'suslevel').asSymbol.kr(0.7, spec: DMControlSpec(0, 1, \lin, 0, 0.7, units: units, sort:4) );
        var rel = ('op' ++ num ++ 'rel').asSymbol.kr(0.5, spec: DMControlSpec(0, 8, \lin, 0, 0.5, units: units, sort:5) );

        var atkcurve = ('op' ++ num ++ 'atkcurve').asSymbol.kr(0, spec: DMControlSpec(-8, 8, \lin, 0, 0, units: units, sort:6) );
        var deccurve = ('op' ++ num ++ 'deccurve').asSymbol.kr(0, spec: DMControlSpec(-8, 8, \lin, 0, 0, units: units, sort:7) );
        var relcurve = ('op' ++ num ++ 'relcurve').asSymbol.kr(0, spec: DMControlSpec(-8, 8, \lin, 0, 0, units: units, sort:8) );

        var env = Env.adsr(
            attackTime:atk, decayTime:dec, sustainLevel:suslevel, releaseTime:rel,
            peakLevel: 1,
            curve:[atkcurve, deccurve, relcurve]
        ).ar(gate: gate);

        var index = units.asSymbol.kr(0.15, spec: DMControlSpec(0, 1, \lin, 0, 0.15, units: units, sort:0)).linlin(0, 1, 0, 2pi);
        var lfoamt = ('op' ++ num ++ 'lfoamt').asSymbol.kr(1, spec: DMControlSpec(0, 1, \lin, 0, 0, units: units, sort:9) );

        vel = 1+(vel * velamt);
        index = index * (1+(indexlfo * lfoamt)) * vel;

        [freq.asArray[0] * ratio, 0, env * index];
    });
    
    if (mods.notNil) {
        var vals = mods.(fb).debug("fm7 algo");
        var o = outs.value.debug("outs");
        sig = FM7.ar(ops, vals).slice( o ).asArray.sum    
    } {
        sig = FM7.arAlgo(algo.debug("fm7 algo"), ops, fb).asArray.sum
    };
    
    sig;
},
presets: [

    preset1: [
        'op2lfoamt', 0.51505016722408,
        'op6rel', 0.5,
        'op3atkcurve', -4,
        'atk', 0.01,
        'op3relcurve', -4,
        'op1deccurve', -4,
        'rel', 2.0383141762452,
        'op1suslevel', 0.7,
        'op6relcurve', -4,
        'op2', 0.59889893396193,
        'op4suslevel', 0.038461538461538,
        'op1dec', 0.2,
        'op6atkcurve', -4,
        'op2suslevel', 0.17432950191571,
        'op4atk', 0.023411371237458,
        'op3deccurve', -4,
        'op2ratio', 2.0,
        'op6deccurve', -4,
        'suslevel', 1.0,
        'op3dec', 0.17432950191571,
        'op1lfoamt', 0,
        'op5suslevel', 0.051724137931034,
        'op6lfoamt', 0,
        'op1ratio', 1,
        'indexlfodepth', 0,
        'op1relcurve', -4,
        'op6', 0.0,
        'op4atkcurve', -4,
        'op2atkcurve', -4,
        'op2relcurve', -4,
        'op1atk', 0.01,
        'op2atk', 0.03448275862069,
        'op6ratio', 15.0,
        'op6atk', 0.01,
        'op4ratio', 1,
        'op5atk', 0.01,
        'op5deccurve', -4,
        'op5rel', 0.38314176245211,
        'op5', 0.13659098493869,
        'op5lfoamt', 0,
        'op2deccurve', -4,
        'glis', 0,
        'atkcurve', -4,
        'detunehz', 0,
        'op3', 0.14709798378012,
        'fm7fb', 0.29933110367893,
        'op5relcurve', -4,
        'op1atkcurve', -4,
        'op3rel', 0.61302681992337,
        'vdepth', 0,
        'op4dec', 0.54013377926421,
        'op6dec', 0.67432950191571,
        'op4deccurve', -4,
        'op1', 1,
        'op4relcurve', -4,
        'relcurve', -4,
        'op5atkcurve', -4,
        'op3ratio', 8.0,
        'op3lfoamt', 0,
        'op1rel', 2.0689655172414,
        'op3suslevel', 0.099616858237548,
        'op2rel', 0.5,
        'op4', 3.4673096176744,
        'op4rel', 0.32183908045977,
        'op6suslevel', 0.059386973180077,
        'op5dec', 0.3735632183908,
        'op3atk', 0.01,
        'vrate', 6,
        'vel', 0,
        'op5ratio', 3.0,
        'op4lfoamt', 0,
        'bend', 0,
        'indexlforate', 0,
        'op2dec', 0.2,
    ]
]
)
