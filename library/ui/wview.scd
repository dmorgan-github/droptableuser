(
var update, skipjack;
var view = View().layout_(VLayout().spacing_(1).margins_(1));
var layout = HLayout().spacing_(1).margins_(1);
var editor = View().layout_(VLayout().spacing_(0).margins_(0));
var buttons = VLayout().spacing_(1).margins_(1);
var buttonview = View().layout_(VLayout().margins_(0).spacing_(0));

var getObjs = {
    var objs = S.all.select({|v, k| v.isKindOf(S) });
    objs = objs ++ D.dictFor(Server.default).envir
    .select({|v, k| v.isKindOf(D) })
    .reject({|v, k| k.asString.endsWith("_chain") });
    objs;
};

var button = {|k, v|

    var name = k.asString[..19];
    Button().states_([ [name], [name, nil, QtGUI.palette.highlight.alpha_(0.5)] ]).action_({|ctrl|
        if (ctrl.value == 1) {
            var children = buttonview.children;
            children.do({|child|
                if (child.isKindOf(Button)) {
                    if (child != ctrl) {
                        child.value = 0;
                    }
                }
            });
            editor.children.do({|child|
                child.remove
            });
            editor.layout.add(StaticText().string_(k));
            editor.layout.add(v.view.minWidth_(300));
        } {
            editor.children.do({|child|
                child.remove
            });
            {
                var size = view.sizeHint;
                view.resizeToHint(size);
            }.defer(0.1)
        }
    })
    .toolTip_(k);
};

var objs = getObjs.value;

var buttonlayout = {|k, v|

    \here12.postln;
    HLayout(
        Button()
        .states_([ [">"], ["[]"] ])
        .action_({|ctrl|
            if (ctrl.value == 1) {
                v.play
            }{
                v.stop
            }
        })
        .value_(v.isPlaying),
        button.(k, v)
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

view.layout.add(layout);

update = {
    var oldObjs = objs;
    var hasNew = false;
    objs = getObjs.value;
    objs.keys.difference(oldObjs.keys).do({|k|
        var v = objs[k];
        hasNew = true;
        \here.postln;
        buttonlayout.(k, v)
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



