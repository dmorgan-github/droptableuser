(
func: {|bufnum, num=4|

    var loopers, fx;

    fx = FxBay();

    Routine({

        M().osc('xloopr').env('asr').add;
        1.wait;

        loopers = num.collect({|i|
            var key = "loopr_%".format(i).asSymbol;
            var synth = S.create(key, 'xloopr');
            var buf = bufnum.asArray.wrapAt(i);
            synth.set(\buf, buf);
            synth;
        });

        1.wait;

        loopers.do({|looper|
            fx.addSrc(looper);
            looper.node.stop;
            looper.on(0);
        })

    }).play;

    fx;
},
doc: "
~loopbay = Module('device/loopbay').(~rec.get(\buf))
~loopbay.gui
"
)