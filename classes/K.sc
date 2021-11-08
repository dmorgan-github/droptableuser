K {

    var <order;

    *new {|key, bufs, quant=4|
        var res = super.new.prInit;
        bufs.do({|val, i|
            var mykey = "%_k%".format(key, i).asSymbol;
            res.order[i] = S(mykey).synth(\oneshot);
            res.order[i] @.buf val[0];
            res.order[i].addSpec(\buf, [val.minItem, val.maxItem, \lin, 1, 0]);
            res.order[i].quant = 4;
        })
        ^res;
    }

    hits_ {|val, dur=0.25|

        var pattern = val.replace(" ", "").stripWhiteSpace.split(Char.nl);
        pattern.do({|p, k|

            var ptrn = Pbind(
                \count, Pseries(0, 1),
                \dur, Pfunc({|evt|
                    var i = evt[\count];
                    var char = p.wrapAt(i);
                    if (char == $.) {
                        Rest(1);
                    } {
                        var prob = char.digit/9;
                        if (prob.coin) {
                            1;
                        } {
                            Rest(1);
                        }
                    }
                }),
                \stretch, dur
            );
            order.wrapAt(k).source = ptrn;
        });
    }

    play {
        order.do({|obj|
            obj.play
        })
    }

    stop {
        order.do({|obj|
            obj.stop;
        })
    }

    prInit {
        order = Order.new;
    }

    *initClass {
        StartUp.add({
            "create oneshot synth".debug(\K);
            SynthLib('synths/oneshot').addSynthDef(\slim)
        })
    }
}
