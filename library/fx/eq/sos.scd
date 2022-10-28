(
synth: {|in|
    var fx;
    var coefs = [ 1.035716703737, -1.7296318726034, 0.79112715955471, 1.7296318726034, -0.82684386329171 ];
    // 0!5;
    var coefsctl = \coefs.kr(coefs);
    fx = SOS.ar(in, *coefsctl);
    fx = in.blend(fx, \sos_mix.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, "sos")));
    fx
},
view: 'soskernel'
)