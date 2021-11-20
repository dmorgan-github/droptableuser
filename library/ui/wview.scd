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
    Button().states_([ [k], [k, nil, Color.green.alpha_(0.5)] ]).action_({|ctrl|
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
    });
};

var objs = getObjs.value;

objs.keysValuesDo({|k, v|
    buttons.add(
        button.(k, v)
    )
});


buttonview.layout.add(buttons);
buttonview.layout.add(nil);

layout.add(buttonview);
layout.add(editor);
view.layout.add(layout);

update = {
    var oldObjs = objs;
    var hasNew = false;
    objs = getObjs.value;
    objs.keys.difference(oldObjs.keys).do({|k|
        var v = objs[k];
        hasNew = true;
        buttons.add(
            button.(k, v)
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



