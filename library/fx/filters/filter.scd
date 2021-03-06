(
synth: {arg sig_in;

    var in = sig_in * \input.ar(1);
    var sig = in;
    var f1, f2, f3, f4, f5, f6;
    var which = \which.kr(0).lag(0.01);
    var cutoff = \cutoff.ar(1000).clip(20, 16000).lag(0.01);
    var res = \res.ar(0).linlin(0, 1, 1, 0.01).lag(0.01);

    f1 = BLowPass.ar(sig, cutoff, rq:res);

    f2 = BLowPass4.ar(sig, cutoff, rq:res);

    // two pole
    f3 = Resonz.ar(sig, cutoff, bwr:res);

    f4 = BPF.ar(sig, cutoff, rq:res);

    // this is blowing up
    //f5 = BHiPass.ar(sig, cutoff, rq:res);

    f5 = BHiPass4.ar(sig, cutoff, rq:res);

    sig = Select.ar(which, [f1, f2, f3, f4, f5]);
    Splay.ar(sig,
        spread:\spread.ar(1),
        center:\pan.ar(0)
    ) * \output.ar(1);
},
specs: [
    \cutoff-> ControlSpec(20, 16000, \lin, 0, 1200, units:"fx"),
    \res -> ControlSpec(0, 1, \lin, 0, 0, units:"fx"),
    \which -> ControlSpec(0, 4, \lin, 1, 0, units:"fx"),
    \spread -> ControlSpec(0,1,\lin,0, 1, units:"stereo"),
    \pan -> ControlSpec(-1,1,\lin,0,0, units:"stereo"),
    \input -> ControlSpec(0, 2, \lin, 0, 1, units:"vol"),
    \output -> ControlSpec(0, 2, \lin, 0, 1, units: "vol")
],
ui: {|node|

    var cutoff = node.get(\cutoff);
    var res = node.get(\res);
    var view = View().layout_(VLayout(
        Slider2D().action_({|ctrl|
            node.set(\res, ctrl.y, \cutoff, ctrl.x.linlin(0, 1, 20, 16000))
        })
        .x_(cutoff.linlin(20, 16000, 0, 1))
        .y_(res)
    ))
    .minSize_(Size(180, 100));
    view
}
)