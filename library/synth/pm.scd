(
synth: {|freq, gate|

    /*
    https://scsynth.org/t/clean-fm-with-sinosc-phase/6887/2?u=droptableuser
var mod = SinOsc.ar(freq * ratio) * index;
var phase = Phasor.ar(0, freq * SampleDur.ir, 0, 1) * 2pi;
var carrier = SinOsc.ar(0, (phase + mod) % 4pi);
*/

    var mod = {
        var ratio = \mratio.kr(1, spec:DMControlSpec(0.5, 20, \lin, 0, 1, units:"pm", sort:0));
        var fb = \mfb.kr(0, spec:DMControlSpec(-1, 1.5, \lin, 0, 0, units:"pm", sort:1));
        var index = \mindex.kr(0, spec:DMControlSpec(0, 20, \lin, 0, 0, units:"pm", sort:2));
        var atk = \matk.kr(0.01, spec:DMControlSpec(0, 2, \lin, 0, 0.01, units:"pm", sort:3));
        var dec = \mdec.kr(0.3, spec:DMControlSpec(0, 2, \lin, 0, 0.3, units:"pm", sort:5));
        var suslevel = \msuslevel.kr(1, spec:DMControlSpec(0, 1, \lin, 0, 0.7, units:"pm", sort:6));
        var rel = \mrel.kr(0.2, spec:DMControlSpec(0, 8, \lin, 0, 0.2, units:"pm", sort:7));

        var atkcurve = \matkcurve.kr(-4, spec:DMControlSpec(-8, 8, \lin, 0, -4, units:"pm", sort:8));
        var deccurve = \mdeccurve.kr(-4, spec:DMControlSpec(-8, 8, \lin, 0, -4, units:"pm", sort:9));
        var relcurve = \mrelcurve.kr(-4, spec:DMControlSpec(-8, 8, \lin, 0, -4, units:"pm", sort:10));

        var meg, sig;
        var curve = [atkcurve, deccurve, relcurve];
        if (~gatemode.debug("pm gate mode") == \retrig) {
            var sus = \msustain.kr(0.1, spec:DMControlSpec(0, 1, \lin, 0, 0.1, units:"pm", sort:12));
            meg = Env([0, 0, 1, suslevel, suslevel, 0], [0, atk, dec, sus, rel], curve:curve);
            //env = Env([0, 1, suslevel, suslevel, 0], [atk, dec, sus, rel], curve:curve);
        }{
            meg = Env.adsr(
                attackTime:atk,
                decayTime:dec,
                sustainLevel:suslevel,
                releaseTime:rel,
                curve:curve
            );
        };

        meg = meg.ar(gate:gate + Impulse.kr(0));
        sig = SinOscFB.ar(freq * ratio, fb);
        sig = sig * meg * index;
        sig;
    };

    var carratio = \cratio.kr(1, spec:DMControlSpec(0.5, 20, \lin, 0, 1, units:"pm", sort:11));

    var sig = SinOsc.ar(freq * carratio, mod.().mod(2pi));
    sig
}
)
