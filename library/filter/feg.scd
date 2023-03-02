(
{|freq, gate, aeg|

    var gatemode = ~gatemode;
    var velamt = ~velamt ?? 0.55;
    var vel = ~vel;
    var envmode = ~fenvmode.debug("feg fenvmode");
    var keyamt = \keyamt.kr(0, spec: DMControlSpec(0, 1, \lin, 0, 0, "filter", sort:8));
    var cutoff = \cutoff.kr(2000, spec: DMControlSpec(100, 16000, \exp, 0, 2000, "filter", sort:9));
    var res = \res.kr(0.1, spec:DMControlSpec(0, 1, \lin, 0, 0.1, units:"filter", sort:10));
    var basefreq = 48.midicps;
    var cutoffratio, feg;

    if (envmode == \follow) {
        feg = aeg;
    } {
        var fatkcurve = \fatkcurve.kr(-1, spec: DMControlSpec(-8, 8, \lin, 0, -1, units:"filter", sort:5));
        //var fdeccurve = \fdeccurve.kr(-1, spec: DMControlSpec(-8, 8, \lin, 0, -1, units:"filter", sort:6));
        var frelcurve = \frelcurve.kr(-1, spec: DMControlSpec(-8, 8, \lin, 0, -1, units:"filter", sort:7));

        var atk = \fatk.kr(0, spec: DMControlSpec(0, 1, \lin, 0, 0.01, units:"filter", sort:1));
        //var dec = \fdec.kr(0.2, spec: DMControlSpec(0, 1, \lin, 0, 0.2, units:"filter", sort:2));
        //var suslevel = \fsuslevel.kr(0.5, spec: DMControlSpec(0, 1, \lin, 0, 0.5, units:"filter", sort:3));
        var rel = \frel.kr(0.2, spec: DMControlSpec(0, 8, \lin, 0, 0.29, units:"filter", sort:4));
        //var curve = [fatkcurve, fdeccurve, frelcurve];
        var curve = [fatkcurve, frelcurve];
        var ts = \fts.kr(1);

        if (gatemode.debug("filter gate mode") == \retrig) {
            //var sus = \fsustain.kr(1, spec:DMControlSpec(0, 1, \lin, 0, 0.1, units:"filter", sort:1));
            feg = Env(
                [0, 1, 0],
                [
                    atk,
                    rel
                ],
                curve:curve
            ).ar(gate:gate, timeScale: ts);

        }{
            feg = Env.asr(
                atk,
                1,
                rel,
                curve:curve
            ).ar(gate:gate, timeScale: ts);//.linlin(0, 1, 1, 0.1);
        };
    };

    cutoffratio = Select.kr(freq < basefreq, [
        basefreq + ((freq - basefreq) * keyamt),
        basefreq - ((basefreq - freq) * keyamt)
    ]);
    cutoffratio = cutoffratio / basefreq;

     // apply velocity to cutoff
    cutoff = cutoff * (1 + (vel * velamt));
    // apply key tracking
    cutoff = cutoff * cutoffratio;
    // apply envelope
    cutoff = cutoff * feg;

    cutoff = cutoff.clip(20, 20000);

    [cutoff, res]
}
)
