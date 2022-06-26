(
var data = [
    v1: [
        'A Amp EG Release'
    ],

    v2: [
        'A Osc 1 Width 1'
    ]
];
var view = View().layout_(HLayout());
data.pairsDo({|k, v, i|
    var layout = VLayout();
    layout.add( StaticText().string_(k) );
    v.do({|val|
        layout.add(
            LevelSlider(val, [0, 1, \lin, 0, 0.3].asSpec)
            .action_({|ctrl|
                topEnvironment[k].vstplugin.set(val, ctrl.value)
            })
        );
    });
    view.layout.add(layout);
});
view.front
)