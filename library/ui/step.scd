(
func: {|node|

    var view;
    var valsview;
    var lenview;
    var startview;
    var len = 32;
    var stepval = Ref(1/len);
    var seqvals, lenvals, startvals, seqview;
    var seqvalscontroller, lenvalscontroller, startvalscontroller;
    seqview = MultiSliderView().showIndex_(true);

    seqvals = Ref(node.get(\vals));
    lenvals = Ref(node.get(\len));
    startvals = Ref(node.get(\start));

    seqvalscontroller = SimpleController(seqvals);
    seqvalscontroller.put(\value, {|obj, what, args|
        //obj.value.debug(\vals);
        node.set(\vals, obj.value);
    });

    lenvalscontroller = SimpleController(lenvals);
    lenvalscontroller.put(\value, {|obj, what, args|
        //obj.value.debug(\len);
        node.set(\len, obj.value);
    });

    startvalscontroller = SimpleController(startvals);
    startvalscontroller.put(\value, {|obj, what, args|
        //obj.value.debug(\start);
        node.set(\start, obj.value);
    });

    if (seqvals.value.isNil) {
        seqvals.value_(Array.fill(len, {1.0.rand})).changed(\value);
    };

    if (lenvals.value.isNil) {
        lenvals.value_([1]).changed(\value);
    };

    if (startvals.value.isNil) {
        startvals.value_([0]).changed(\value);
    };

    len = seqvals.value.size;

    valsview = {
        var nb = NumberBox();
        HLayout(
            VLayout(
                StaticText().string_("vals"),

                nb
                .value_(len)
                .action_({|ctrl|
                    var vals = seqview.value;
                    var size = ctrl.value.clip(1, 128).asInteger;
                    seqvals.value_(vals.wrapExtend(size)).changed(\value);
                    seqview.value = seqvals.value;
                }),
                nil
            ),

            seqview
            .step_(1/12)
            .value_(seqvals.value)
            .isFilled_(true)
            .fillColor_(Color.cyan)
            .valueThumbSize_(0.5)
            .action_({|ctrl|
                seqvals.value_(ctrl.value).changed(\value);
            }),
            nil
        )
    };

    lenview = {

        var msv = MultiSliderView();
        var nb = NumberBox();

        HLayout(

            VLayout(
                StaticText().string_("len"),

                nb
                .value_(lenvals.value.size)
                .action_({|ctrl|
                    var vals = msv.value;
                    var size = ctrl.value.clip(1, 128).asInteger;
                    lenvals.value_(vals.wrapExtend(size)).changed(\value);
                    msv.value = lenvals.value;
                }),
                nil
            ),

            msv
            .step_(stepval.value)
            .value_(lenvals.value)
            .isFilled_(true)
            .fillColor_(Color.cyan)
            .valueThumbSize_(0.5)
            .action_({|ctrl|
                lenvals.value_(ctrl.value).changed(\value)
            }),
            nil
        )
    };

    startview = {

        var msv = MultiSliderView();
        var nb = NumberBox();

        HLayout(
            VLayout(
                StaticText().string_("start"),

                nb
                .value_(startvals.value.size)
                .action_({|ctrl|
                    var vals = msv.value;
                    var size = ctrl.value.clip(1, 128).asInteger;
                    startvals.value_(vals.wrapExtend(size)).changed(\value);
                    msv.value = startvals.value;
                }),
                nil
            ),
            msv
            .step_(stepval.value)
            .value_(startvals.value)
            .isFilled_(true)
            .fillColor_(Color.cyan)
            .valueThumbSize_(0.5)
            .action_({|ctrl|
                startvals.value_(ctrl.value).changed(\value)
            }),
            nil
        )
    };

    view = View()
    .layout_(VLayout(
        valsview.(),
        lenview.(),
        startview.()
    ));

    node.source = Pbind(

        \val, Prout({|inval|
            var phase = inval['phase'] ?? 0;
            inf.do({
                var start, len, dir;
                var dirvals = [1];//inval['dir'].asArray;
                var offset = 0;//inval['offset'];
                var vals = inval['vals'].asArray;
                var startvals = inval['start'].asArray;
                var lenvals = inval['len'].asArray;

                start = startvals.wrapAt(phase).linlin(0, 1, 0, vals.size-1).floor;// + offset;
                len = lenvals.wrapAt(phase).linlin(0, 1, 1, vals.size-1).floor;
                dir = dirvals.wrapAt(phase);

                if (dir < 0) {

                    vals.wrapAt( (start..(start+len-1)) ).reverseDo({|val|
                        inval = val.embedInStream(inval);
                    });

                }{
                    vals.wrapAt( (start..(start+len-1)) ).do({|val, i|
                        {
                            // this should raise an event
                            seqview.index = (start+i).mod(vals.size);
                        }.defer(0.0);

                        inval = val.embedInStream(inval);
                    });
                };

                phase = phase + 1;
            });
        })
    );

    view;
}
)


