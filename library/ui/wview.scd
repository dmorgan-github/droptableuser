(
var volmeter = {|node|
    var dBLow = -80;
    var updateFreq = 10;
    var server = Server.default;
    var objid = "%_levels_%".format(node.key, UniqueID.next).asSymbol;
    var path = "/%".format(objid);

    var meters = {
        LevelIndicator()
        .drawsPeak_(true)
        .warning_(0.9)
        .critical_(1.0);
    }.dup(2);

    var view = View()
    .layout_(HLayout(*meters).margins_(0).spacing_(2));

    OSCdef(objid, {|msg|

        meters.do({|meter, i|

            var baseIndex = 3 + (2*i);
            var peakLevel = msg.at(baseIndex);
            var rmsValue = msg.at(baseIndex + 1);

            if (meter.notNil) {
                if (meter.isClosed.not) {
                    {
                        meter.peakLevel = peakLevel.ampdb.linlin(dBLow, 0, 0, 1, \min);
                        meter.value = rmsValue.ampdb.linlin(dBLow, 0, 0, 1);
                    }.defer
                }
            }
        });

    }, path.asSymbol);

    Ndef(objid, {
        var in = InFeedback.ar(node.bus.index, node.bus.numChannels).asArray;
        SendPeakRMS.kr(in, updateFreq, 3, path);
    });

    view
    .onClose_({
        OSCdef(objid).free;
        Ndef(objid).free;
    })

};

var update, skipjack;
var view = View().layout_(VLayout().spacing_(1).margins_(1));
var layout = HLayout().spacing_(1).margins_(1);
var editor = View().layout_(VLayout().spacing_(0).margins_(0));
var buttons = HLayout().spacing_(1).margins_(1);
var buttonview = View().layout_(VLayout().margins_(0).spacing_(0));

var getObjs = {
    var objs = S.all.select({|v, k| v.isKindOf(S) });
    objs = objs ++ D.dictFor(Server.default).envir
    .select({|v, k| v.isKindOf(D) })
    .reject({|v, k| k.asString.endsWith("_chain") });
    objs;
};

var objs = getObjs.();

var buttonlayout = {|k, v|

    var isMute = v.node.isMonitoring.not;

    var meter = volmeter.(v.node)
    .fixedWidth_(25).minHeight_(50);

    var amp = if (v.get(\amp).notNil) { v.get(\amp).linlin(0, 2, 0, 1) } { -6.dbamp.linlin(0, 2, 0, 1) };
    var pan = if (v.get(\pan).notNil) { v.get(\pan).linlin(-1, 1, 0, 1) } { 0.liinlin(-1, 1, 0, 1) };

    VLayout(

        HLayout(

            meter,

            VLayout(
                Button()
                .states_([ ["M", ], ["M", nil, QtGUI.palette.highlight] ])
                .action_({|ctrl|
                    if (ctrl.value == 1) {
                        v.node.stop
                    }{
                        v.node.play
                    }

                })
                .value_(isMute)
                .maxWidth_(20),

                /*
                Button()
                .states_([ [">"], ["[]"] ])
                .action_({|ctrl|
                    if (ctrl.value == 1) {
                        v.play(fadeTime:v.fadeTime)
                    }{
                        v.stop(fadeTime:v.fadeTime)
                    }
                })
                .maxWidth_(20)
                .value_(v.isPlaying),
                */

                NumberBox()
                .maxWidth_(20)
                .action_({|ctrl|
                    v.node.monitor.out = ctrl.value;
                })
                .toolTip_("out bus")
                .value_(v.node.monitor.out)

                /*

                Button().action_({
                    v.view.front
                })
                .maxWidth_(20)
                .states_([ ["E"] ] )
                */
            ),

            VLayout(

                Knob().action_({|ctrl|
                    var val = ctrl.value.linlin(0, 1, 0, 2);
                    v.set(\amp, val);
                })
                .toolTip_("amp")
                .value_(amp),

                Knob().action_({|ctrl|
                    var val = ctrl.value.linlin(0, 1, -1, 1);
                    v.set(\pan, val);
                })
                .toolTip_("pan")
                .value_(pan),
            ),

            nil
        ),

        StaticText()
        .string_(k)
        .mouseUpAction_({
            v.view.front
        })
        .toolTip_(k)
    )
};

objs.keysValuesDo({|k, v|
    buttons.add(
        buttonlayout.(k, v)
    )
});

buttonview.layout.add(buttons);
buttonview.layout.add(nil);
layout.add(buttonview);
layout.add(editor);

/*
view.layout.add(HLayout(
    Button().states_( [ ["kb"] ] ).action_({
        W.kb
    }),
    Button().states_([ ["loopr"] ]).action_({

        FileDialog({|paths|
            var selected = paths[0];
            var name = PathName(selected).fileNameWithoutExtension;
            B.read(name.asSymbol, selected, cb:{|buf|
                buf.loopr
            });
        }, {
            postln("Dialog was cancelled. Try again.");
        }, path:"~/Documents/supercollider/media".standardizePath);

    }),
    Button().states_([ ["grainr"] ]).action_({

        FileDialog({|paths|
            var selected = paths[0];
            var name = PathName(selected).fileNameWithoutExtension;
            B.mono(name.asSymbol, selected, cb:{|buf|
                buf.grainr
            });
        }, {
            postln("Dialog was cancelled. Try again.");
        }, path:"~/Documents/supercollider/media".standardizePath);

    })
));
*/

view.layout.add(layout);

update = {
    var oldObjs = objs;
    var hasNew = false;
    objs = getObjs.value;
    objs.keys.difference(oldObjs.keys).do({|k|
        var v = objs[k];
        hasNew = true;
        buttons.add(
            buttonlayout.(k, v)
        )
    });

    if (hasNew) {
        buttons.add(nil);
    }
};

skipjack = SkipJack(update, 1, name:'wview');

view
.onClose_({
    skipjack.stop();
})
.front;
)
