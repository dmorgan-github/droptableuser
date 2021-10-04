(
Require(App.librarydir ++ "ui/common.scd");
Fdef(\tracks, {arg node;

    var view = View().layout_(VLayout());
    node.indices.do({|i|

        var t = node[i];
        var isplaying = t.isPlaying;
        var v = View().layout_(HLayout(
            StaticText().string_("%) %".format(i, t.key)).mouseUpAction_({
                t.view
            })
            .minWidth_(50),
            Button().states_([ [">"],["0"] ] ).action_({|ctrl|
                if (ctrl.value == 1) {
                    t.play
                }{
                    t.stop
                }
            })
            .value_(isplaying)
        ));
        view.layout.add(v);
    });
    view.layout.add(nil);
    view.front
})
)
