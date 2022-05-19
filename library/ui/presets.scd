(
func: {|node|

    var morphbeats = 20;

    var buttons = 14.collect({|i|
        var color_active = Color.white.alpha_(0.9);
        var color_saved = Color.green.alpha_(0.9);
        var color_empty = Color.gray;
        var issaved = P.getPreset(node, i).notNil;
        var color_init = if (issaved) {color_saved}{color_empty};
        Button()
        .action_({|ctrl|
            buttons.do({|btn, j|
                if (i != j) {
                    if (btn.value == 1) {
                        btn.states = [ [nil, nil, color_saved ], [nil, nil, color_active ] ]
                    };
                    btn.value = 0;
                }
            });

            if (ctrl.value == 1) {
                var preset = P.getPreset(node, i);
                if (preset.isNil) {
                    //log.("% preset %".format(\save, i));
                    P.addCurrent(node, i);
                } {
                    //log.("% preset %".format(\morph, i));
                    P.morph(node, i, beats:morphbeats);
                };
            }{
                // button stays on
                ctrl.value = 1
            }
        })
        .mouseDownAction_({|ctrl, x, y, mod, num, count|
            // 262144 ctrl delete
            // 131072 shift overwrite
            // 524288 option
            if (mod == 262144) {
                //log.("% preset %".format(\remove, i));
                P.remove(node, i);
                ctrl.states = [ [nil, nil, color_empty ], [nil, nil, color_active ] ];
            };
            if (mod == 131072) {
                //log.("% preset %".format(\overwrite, i));
                P.addCurrent(node, i);
            };
        })
        .states_([ [nil, nil, color_init ], [nil, nil, color_active ] ])
    });

    HLayout(
        GridLayout.rows(
            buttons[0..6].collect(_.fixedSize_(10)),
            buttons[7..13].collect(_.fixedSize_(10))
        ).margins_(0).spacing_(0),

        NumberBox()
        .action_({|ctrl|
            morphbeats = ctrl.value;
        })
        .toolTip_("morph time")
        .value_(morphbeats)
    ).margins_(0).spacing_(0)
};
)