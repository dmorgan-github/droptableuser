(
func: {|node|

    var morphbeats = 20;

    var buttons = 14.collect({|i|
        var color_active = Color.white.alpha_(0.9);
        var color_saved = Color.green.alpha_(0.9);
        var color_empty = Color.gray;
        var issaved = P.getSource(node, i).notNil;
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
                var preset = P.getSource(node, i);
                if (preset.isNil) {
                    //log.("% preset %".format(\save, i));
                    P.addCurrentSource(node, i);
                } {
                    //log.("% preset %".format(\morph, i));
                    P.morphSource(node, i, fadeTime:morphbeats);
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
                P.removeSource(node, i);
                ctrl.states = [ [nil, nil, color_empty ], [nil, nil, color_active ] ];
            };
            if (mod == 131072) {
                //log.("% preset %".format(\overwrite, i));
                P.addCurrentSource(node, i);
            };
        })
        .states_([ [nil, nil, color_init ], [nil, nil, color_active ] ])
    });

    View().layout_(
        VLayout(

            StaticText().string_("sources"),

            NumberBox()
            .action_({|ctrl|
                morphbeats = ctrl.value;
            })
            .toolTip_("morph time")
            .value_(morphbeats),

            GridLayout.rows(
                buttons[0..6],
                buttons[7..13]
            ).margins_(0).spacing_(0),

            nil


        ).margins_(0).spacing_(0)
    )
}
)