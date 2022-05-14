Require(App.librarydir ++ "ui/common.scd");
(
func: {|patterns|

    var rows, grid;
    var active = if (~launch_active.isNil) { ~launch_active = (); ~launch_active } {~launch_active};
    var allButtons = List.new;
    var reset = {
        allButtons.do({|btn|
            btn.valueAction = 0;
        });
    };

    rows = patterns.flatten.collect({|assoc|
        var buttons;
        var key = (assoc.key ++ '_obj_launch').asSymbol.postln;
        buttons = assoc.value.collect({|obj, i|

            var func;
            var isactive = (active[key] == i);
            var button = Button();
            if (obj.isKindOf(Pattern)) {
                if (isactive) {
                    Pdef(key, PfsetC({ { { button.value = 0}.defer } }, obj ));
                };
                func = { Pdef(key, PfsetC({ { { button.value = 0}.defer } }, obj )) };
            }{
                func = { obj }
            };

            button
            .states_([ [nil, nil, Color.clear.alpha_(1.5) ], [nil, nil, Color.white.alpha_(0.8) ] ])
            .action_({|ctrl|

                var myobj;
                if (ctrl.value == 1) {
                    buttons.do({|btn, j|
                        if (i != j) {
                            btn.value = 0;
                        }
                    });

                    active[key] = i;
                    myobj = func.value;
                    if (myobj.isKindOf(Function)) {
                        myobj.value(1);
                    }{
                        myobj.play;
                    }
                } {
                    myobj = func.value;
                    if (myobj.isKindOf(Function)) {
                        myobj.value(0)
                    }{
                        myobj.stop
                    };
                    active[key] = nil;
                }
            })
            .value_(if (isactive) {1}{0})
        });

        allButtons.addAll(buttons);
        [
            HLayout(
                StaticText()
                .string_(assoc.key)
                .minWidth_(50)
                .mouseUpAction_({|ctrl, x, y, mod, num, click|
                    //if (Pdef.all[assoc.key].isKindOf(S)) {
                    //  S(assoc.key).view;
                    //}
                    //Pdef(assoc.key).gui
                })
                .mouseOverAction_({|ctrl|
                    //if (Pdef.all[assoc.key].isKindOf(S)) {
                    //  ctrl.stringColor = Color.blue;
                    //}
                })
                .mouseLeaveAction_({|ctrl|
                    //ctrl.stringColor = Color.white;
                }),
                NumberBox().fixedSize_(25).action_({|ctrl|
                    Pdef(key).fadeTime = ctrl.value;
                })
                .toolTip_("fadetime")
                .value_(Pdef(key).fadeTime.ifnil(2)),

                NumberBox().fixedSize_(25).action_({|ctrl|
                    Pdef(key).quant = ctrl.value;
                })
                .toolTip_("quant")
                .value_(Pdef(key).quant.ifnil(1)),
            )
            .spacing_(2)
            .margins_(2)
        ]
        ++
        buttons
    });

    grid = View().layout_(GridLayout.rows(*rows).margins_(0).spacing_(0));
    if (~view.isNil) {

        var baseViewFunc = Fdef(\baseview);
        var baseview;

        ~view = View().layout_(VLayout().margins_(3).spacing_(3));
        ~gridview = View().layout_(VLayout().margins_(3).spacing_(3));
        ~gridview.layout.add(grid);
        //~view.layout.add(TextField().action_({|ctrl| ctrl.value.postln}));
        //~view.layout.add(TextField().action_({|ctrl| ctrl.value.postln;}));
        ~view.layout.add(~gridview);
        CmdPeriod.add(reset);
        ~view.onClose = {
            \close.debug(\launcher);
            ~view = nil;
            CmdPeriod.remove(reset);
        };
        //~view.front;
        baseview = baseViewFunc.(~view, 'launcher');
        baseview.acceptsMouseOver = true;
        baseview.front;
    } {
        ~view.children.do({|child| child.remove});
        ~view.layout.add(grid);
    };
}
)


