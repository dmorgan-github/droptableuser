(
Require(App.librarydir ++ "ui/common.scd");
Fdef(\transport, {|clock=(TempoClock.default)|

    var baseViewFunc = Fdef(\baseview);
    var baseview;
    var ctrlTempo = StaticText().string_(t.tempo * 60),
    ctrlBar = StaticText().string_(0).minWidth_(25),
    ctrlBeat = StaticText().string_(0).minWidth_(25);

    var controller = SimpleController(clock)
    .put(\tempo, {|obj, prop|
        { ctrlTempo.string = obj.tempo * 60 }.defer
    });

    var view = View().layout_(
        VLayout(

            HLayout(
                ctrlTempo,
                ctrlBar,
                ctrlBeat,
                nil
            ),

            HLayout(

                Button().states_([[""]])
                .action_({|ctrl|
                    S.loadSynths
                })
                .maxWidth_(35)
                .toolTip_("load synths")
                .icon_(Image.new(App.librarydir ++ "images/noun_Synthesizer_2145531.png")),

                Button().states_([[""]])
                .action_({|ctrl|
                    S.printSynths;
                    Document.current.dir.postln;
                })
                .maxWidth_(35)
                .toolTip_("print synths")
                .icon_(Image.new(App.librarydir ++ "images/noun_print_2120752.png")),

                Button().states_([[""]])
                .action_({|ctrl|
                    Server.default.plotTree
                })
                .maxWidth_(35)
                .toolTip_("plot tree")
                .icon_(Image.new(App.librarydir ++ "images/noun_Treemap_151030.png")),

                Button().states_([[""]])
                .action_({|ctrl|
                    Server.default.freqscope;
                })
                .maxWidth_(35)
                .toolTip_("show freq scope")
                .icon_(Image.new(App.librarydir ++ "images/noun_Oscilloscope_3422171.png")),

                Button().states_([ [""] ])
                .action_({|ctrl| Server.default.meter(2, 2) })
                .maxWidth_(35)
                .toolTip_("server meter")
                .icon_(Image.new(App.librarydir ++ "images/noun_sound level_1921781.png")),

                Knob().mode_(\vert).action_({|ctrl|
                    var val = ctrl.value.ampdb;
                    Server.default.volume.volume = val;
                    ctrl.toolTip = Server.default.volume.volume.trunc(0.01);
                })
                .value_(Server.default.volume.volume.dbamp)
                .toolTip_(Server.default.volume.volume.trunc(0.01))
                .maxSize_(30)
                .toolTip_("volume"),

                Button().states_([ ["", nil, Color.grey ], ["", Color.black, Color(1, 0.67, 0) ] ]).action_({|ctrl|
                    if (ctrl.value == 1) {
                        Server.default.volume.mute;
                        ctrl.icon = Image.new(App.librarydir ++ "images/noun_Volume_1940053.png");
                    }{
                        Server.default.volume.unmute;
                        ctrl.icon = Image.new(App.librarydir ++ "images/noun_Mute_1939974.png");
                    }
                })
                .maxWidth_(35)
                .toolTip_("mute")
                .icon_(Image.new(App.librarydir ++ "images/noun_Mute_1939974.png")),

                Button().states_([ [ "", nil, Color.grey ], ["", Color.black, Color.red] ])
                .action_({|ctrl|
                    if (ctrl.value == 1) {
                        W.record;
                        ctrl.icon = Image.new(App.librarydir ++ "images/noun_Stop_1939990.png");
                    }{
                        W.stopRecording;
                        ctrl.icon = Image.new(App.librarydir ++ "images/noun_Record_1939983.png");
                    }
                })
                .maxWidth_(35)
                .toolTip_("record")
                .icon_(Image.new(App.librarydir ++ "images/noun_Record_1939983.png"))
            ).margins_(2).spacing_(2),
        ).margins_(2).spacing_(2),
    )
    .onClose_({controller.remove});

    var nextBar = clock.nextBar/clock.beatsPerBar;

    clock.schedAbs(clock.nextTimeOnGrid(1), {
        {
            var barnum = clock.bar;// - nextBar;
            var beat = (clock.beats - clock.bars2beats(barnum)).trunc;
            ctrlBar.string = (barnum - nextBar + 1).trunc;
            ctrlBeat.string = beat + 1;
            //[barnum, beat].postln;
        }.defer(s.latency);
        if (view.isClosed) {
            nil;
        }{
            clock.beatDur;
        }
    });

    baseview = baseViewFunc.(view, 'transport');
    baseview.front;
})
)
