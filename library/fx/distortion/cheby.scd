(
synth: {arg sig_in;

    var in = sig_in * \input.kr(1);
    var buf = \buf.kr(0);
    var gain = \gain.ar(1).max(1);
    var sig = Shaper.ar(buf, in * gain);
    sig = LeakDC.ar(sig) * gain.reciprocal.sqrt;

    Splay.ar(sig,
        spread:\spread.ar(1),
        center:\pan.ar(0)
    ) * \output.ar(1);

},
specs: [
    gain: ControlSpec(1, 10, \lin, 0, 1, units:"fx"),
    spread: ControlSpec(0,1,\lin,0, 1, units:"stereo"),
    pan: ControlSpec(-1,1,\lin,0,0, units:"stereo"),
    input: ControlSpec(0, 2, \lin, 0, 1, units:"vol"),
    output: ControlSpec(0, 2, \lin, 0, 1, units: "vol")
],
ui: {|node|

    var foo = {\here.postln;}.();
    var key = node.key;
    var harms = [1, 0, 0, 0, 0, 0, 0];
    var buf = {
        var buf = B(key);
        if (buf.isNil) {
            var sig;
            B.alloc(key, 1024, 1);
            sig = Signal.chebyFill(513, harms);
            B(key).sendCollection(sig.asWavetableNoWrap);
            buf = B(key);
        };
        buf;
    }.();

    var foo2 = {\here2.postln;}.();
    var view;
    var fxview;
    var knob = {|num|

        var pkey = ('p' ++ num).asSymbol;
        var initval = node.get(pkey) ? harms[num-1];

        var view = View().layout_(VLayout(

            Knob().mode_(\vert)
            .action_({|ctrl|
                var sig;
                var val = ctrl.value;
                harms[num-1] = val;
                sig = Signal.chebyFill(513, harms);
                B(key).sendCollection(sig.asWavetableNoWrap);
                node.set(pkey, val)
            })
            .value_(initval),
            StaticText()
            .string_(pkey)
            .align_(\center)
        ).margins_(0).spacing_(0));
        view;
    };

    var foo3 = {\here3.postln;}.();

    node.set(\buf, buf);

    {\here4.postln;}.();

    view = View().layout_(HLayout(
        *[1, 2, 3, 4, 5, 7].collect({|i|
            knob.(i)
        })
    ));

    {\here5.postln;}.();

    view.layout.add(Button().string_("plot").action_({ buf.plot }));

    {\here6.postln;}.();

    Require(App.librarydir ++ "ui/fx.scd");

    {\here7.postln;}.();

    fxview = Fdef(\fx).(node, view);
    fxview.front;
};
)
