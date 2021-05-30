(
Fdef(\baseview, {arg view, title, w, h;

    var mousey, mousex;
    var width = w ? view.sizeHint.width;
    var height = h ? view.sizeHint.height;
    var top = Window.screenBounds.height * 0.5;
    var left = Window.screenBounds.width * 0.3;
    var win = Window.new(title, bounds:Rect(left, top, width, height), border:true);
    var status = StaticText().string_("").background_(Color.black.alpha_(0.1));

    var viewListener = {arg view, key, value;
        var msg = "";
        if (key == \prop) {
            status.string = value[\val]
        }
    };

    var outerview = View().layout_(
        VLayout(
            view,
            status;
        ).margins_(1).spacing_(1)
    );

    view.addDependant(viewListener);
    win.layout = VLayout(outerview).margins_(0).spacing_(0);
    win.asView
    //.palette_(QPalette.dark)
    .onClose_({
        view.removeDependant(viewListener);
    });
});

Fdef(\ctrlview, {arg key, spec, color, val, cb;

    var controlSpec = spec;
    var myval = val ?? controlSpec.default;

    var stack, view;
    var font = Font(size:9);
    var label = if (key.asString.size > 0) {key ++ ": "}{""};
    var labelView = StaticText().string_(label)
    .font_(font)
    .stringColor_(Color.white)
    .toolTip_(label);

    var li, st, nb;
    var getValue = {}, setValue = {};

    //color = Color.white.alpha_( rrand(0.0, 1.0) );

    if (myval.isNumber) {

        li = LevelIndicator().value_(controlSpec.unmap(myval));
        st = StaticText().string_(myval.trunc(0.001)).font_(font).stringColor_(Color.white);
        nb = NumberBox()
        .font_(font)
        .value_(myval)
        .background_(Color.white)
        .minDecimals_(3)
        .clipLo_(controlSpec.minval)
        .clipHi_(controlSpec.maxval);

        setValue = {|self, val|
            var unmap = controlSpec.unmap(val);
            li.value = unmap;
            st.string_(val.trunc(0.001));
            nb.value = val;
            myval = val;
        };

        getValue = {|self|
            myval;
        };

        stack = StackLayout(
            View()
            .layout_(
                StackLayout(
                    View().layout_(HLayout(labelView, st, nil).margins_(1).spacing_(1)),
                    li
                    .style_(\continuous)
                    .meterColor_(color.alpha_(0.5))
                    .warningColor_(color.alpha_(0.5))
                    .criticalColor_(color.alpha_(0.5))
                    .background_(color.alpha_(0.2))
                )
                .mode_(\stackAll)
            )
            .mouseMoveAction_({arg ctrl, x, y, mod;
                var val = x.linlin(0, ctrl.bounds.width, 0, 1);
                var mappedVal = controlSpec.map(val);
                if (mod == 0) {
                    li.value = val;
                    st.string_(mappedVal.trunc(0.001));
                    nb.value = mappedVal;
                    myval = mappedVal;
                    cb.(key, mappedVal);
                };
                true;
            })
            .mouseDownAction_({arg ctrl, x, y, mod, num, count;
                var val = controlSpec.default;
                if (count == 2) {
                    li.value = controlSpec.unmap(val);
                    st.string_(val.trunc(0.001));
                    nb.value = val;
                    myval = val;
                    cb.(key, val);
                } {
                    if (mod == 0) {
                        var val = x.linlin(0, ctrl.bounds.width, 0, 1);
                        var mappedVal = controlSpec.map(val);
                        li.value = val;
                        st.string_(mappedVal.trunc(0.001));
                        nb.value = mappedVal;
                        myval = mappedVal;
                        cb.(key, mappedVal);
                        true;
                    };
                };
            }),
            nb
            .action_({arg ctrl;
                var val = ctrl.value;
                li.value = controlSpec.unmap(val);
                st.string_(val);
                myval = val;
                cb.(key, val);
                stack.index = 0;
            }),
        ).mode_(\stackOne)
        .margins_(0)
        .spacing_(0);

        view = View().layout_(HLayout(
            View()
            .layout_(stack)
            .mouseDownAction_({arg ctrl, x, y, mod, num, count;
                if (mod == 262144) {
                    stack.index = 1;
                };
                true;
            })
            //.fixedHeight_(25)
        ).margins_(0.5).spacing_(1))
    } {
        var text = label + myval.asCompileString;
        var st = StaticText().string_(text).font_(font).stringColor_(Color.white);
        view = View().layout_(HLayout( st ).margins_(1).spacing_(1) )//.fixedHeight_(25);
    };

    (
        getValue: getValue,
        setValue: setValue,
        asView: view
    );
});

Fdef(\playview, {arg node;

    var levelkey;
    var view;
    var font = Font(size:8);
    var slider = Slider();
    var levelView, setAmps, skipjack;
    var uv, preAmp = 0, postAmp = 0;
    var height = 20;
    var volspec = [0, 2, \lin, 0, 1].asSpec;

    var onrec = {|buf|
        var key = "%_%_%".format(node.key, "loopr", UniqueID.next).asSymbol;
        O(key).set(\buf, buf);
        currentEnvironment.put(key, O(key))
    };

    view = View().layout_(

        HLayout(
            Button().states_([
                [],
                []
            ]).action_({arg ctrl;
                if (ctrl.value == 1) {
                    node.play(fadeTime:node.fadeTime);
                    ctrl.icon = Image.new(App.librarydir ++ "images/noun_no sound_1940059.png");
                } {
                    node.stop(fadeTime:node.fadeTime);
                    ctrl.icon = Image.new(App.librarydir ++ "images/noun_Volume_1940053.png");
                }
            })
            .value_(node.isMonitoring.asInteger)
            .fixedSize_(Size(height, height))
            .icon_(Image.new(App.librarydir ++ "images/noun_no sound_1940059.png")),

            slider
            .orientation_(\horizontal)
            .thumbSize_(7)
            .action_({arg ctrl;
                var msg;
                node.vol = volspec.map(ctrl.value);
                msg = "vol:" + node.vol.trunc(0.001);
                view.changed(\prop, (key:\vol, val:msg));
            })
            .value_(volspec.unmap(node.vol))
            .fixedHeight_(height)
            .fixedWidth_(75)
            .toolTip_("vol")
            .background_(Color.new255(77, 77, 77)),

            NumberBox()
            .action_({arg ctrl;
                var msg;
                node.fadeTime = ctrl.value;
                msg = "fadetime:" + node.fadeTime.trunc(0.001);
                view.changed(\prop, (key:\fadetime, val:msg));
            })
            .font_(font)
            //.normalColor_(Color.white)
            //.background_(Color.gray)
            .decimals_(2)
            .fixedWidth_(35)
            .fixedHeight_(height-2)
            .value_(node.fadeTime)
            .toolTip_("fade time"),

            NumberBox()
            .action_({arg ctrl;
                var msg;
                msg = "channel:" + ctrl.value;
                view.changed(\prop, (key:\channel, val:msg));
            })
            .font_(font)
            //.normalColor_(Color.white)
            //.background_(Color.gray)
            .decimals_(0)
            .fixedWidth_(25)
            .fixedHeight_(height-2)
            .value_(node.monitor.out)
            .toolTip_("channel"),

            Button()
            .action_({
                node.rec(cb:onrec)
            })
            .fixedSize_(Size(height, height))
            .icon_(Image.new(App.librarydir ++ "images/noun_Record_1939983.png"))
            .toolTip_("record")
            /*
            .setContextMenuActions(
                MenuAction("loopr", {|action|
                    onrec = {|buf|
                        var key = (node.key ++ '_loopr').asSymbol;
                        O(key).set(\buf, buf).view;
                    };
                }),
                MenuAction("grainr", {|action|
                    onrec = {|buf|
                        G( (node.key ++ '_grainr').asSymbol ).set(\buf, buf).view;
                    };
                })
            )*/
            ,

            NumberBox()
            .minWidth_(20)
            .decimals_(0)
            .fixedWidth_(25)
            .fixedHeight_(height-2)
            .value_(4)
            .toolTip_("seconds"),

            /*
            Button()
            .states_([ ["M"] ])
            .action_({
                var key = (node.key ++ '_matrix').asSymbol;
                M(key).addSrc(node);
                M(key).view;
            })
            .toolTip_("matrix"),

            Button()
            .states_([ ["C"] ])
            .action_({
                "echo % | pbcopy".format(node.key).systemCmd;
            })
            .toolTip_("copy key to clipboard"),
            */

            nil
        )
        .spacing_(1)
        .margins_(0)
    );

    levelView = {|parent, bounds|

        var preCol = Color.yellow(1.0, 0.4);
        var postCol = Color.green(0.7, 0.4);
        var preSatCol = Color.red(1, 0.4);
        var satCol = Color.red(1, 0.6);

        uv = UserView(parent, bounds);
        //uv.background_(Color(1,1,1,0));
        uv.acceptsMouse_(false);

        // horizontal for now:
        uv.drawFunc = { |uv|
            var bounds = uv.bounds;
            var maxwid = bounds.width - 4;
            var height = bounds.height - 4;
            var satPreLeft, satLeft;

            if (preAmp > 0) {
                Pen.color_(preCol);
                Pen.addRect(Rect(2,2, preAmp * maxwid, height));
                Pen.fill;
                if (preAmp > 1.0) {
                    Pen.color_(preSatCol);
                    satPreLeft = (1 - (preAmp - 1).clip(0, 1)) * maxwid;
                    Pen.addRect(Rect( satPreLeft, 2, maxwid, height));
                    Pen.fill;
                };
            };

            if (postAmp > 0) {
                Pen.color_(postCol);
                Pen.addRect(Rect(2,2, postAmp * maxwid, height));
                Pen.fill;
                if (postAmp > 1.0) {
                    Pen.color_(satCol);
                    satLeft = (1 - (postAmp - 1).clip(0, 1)) * maxwid;
                    Pen.addRect(Rect( satLeft, 2, maxwid, height));
                    Pen.fill;
                };
            };
        };
    };

    setAmps = {|pre = 0, post = 0|
        preAmp = pre.sqrt;
        postAmp = post.sqrt;
        uv.refresh;
    };

    levelView.(slider, slider.bounds.left_(0).top_(0));
    levelkey = (node.key ++ 'amp' ++ UniqueID.next).asSymbol;

    Ndef(levelkey, {
        var decay = 0.99994;
        var inArray = InFeedback.ar(node.bus.index, node.bus.numChannels).asArray;
        var amps = A2K.kr(PeakFollower.ar(inArray, decay: decay));
        var max = 0;
        amps.do {|amp| max = max(max, amp)	};
        max;
    });

    OSCdef(levelkey, {|msg|
        var vols = msg.copyToEnd(3);
        var preVol = vols[0];
        var postVol = if (node.monitor.isPlaying, node.vol, 0) * preVol;
        defer {
            setAmps.(preVol, postVol);
        };

    }, '/c_setn', Ndef(levelkey).server.addr, nil, [Ndef(levelkey).bus.index]);

    skipjack = SkipJack({
        Ndef(levelkey).server.listSendMsg(Ndef(levelkey).bus.getnMsg(1));
    }, 0.03, false, 'ProxyMeter');

    view.onClose_({
        [node.key, \playview, \release].postln;
        skipjack.stop;
        OSCdef(levelkey).free;
        Ndef(levelkey).free;
        Ndef(levelkey).clear;
    });

});

Fdef(\presetsview, {|node, cb|
    var num = 10;
    var size = 12;
    var grid, view;
    var buttons;
    var presets = node.getPresets;
    var active = if (~preset_active.isNil) { ~preset_active = (); ~preset_active } {~preset_active};

    buttons = num.collect({|i|

        var color = if (presets[i].isNil.not) {
            Color.green.alpha_(0.5)
        }{
            Color.clear.alpha_(1.5)
        };
        var isactive = (active[node.key] == i);

        Button()
        .states_([ [nil, nil, color], [nil, nil, Color.red.alpha_(0.5) ] ])
        .action_({|ctrl|
            buttons.do({|btn, j|
                if (i != j) {
                    if (btn.value == 1) {
                        btn.states = [ [nil, nil, Color.green.alpha_(0.5) ], [nil, nil, Color.red.alpha_(0.5) ] ]
                    };
                    btn.value = 0;
                }
            });
            if (ctrl.value == 1) {
                ~preset_active[node.key] = i;
                cb.(i);
            } {
                ~preset_active[node.key] = nil;
            }
        })
        .mouseDownAction_({|ctrl, x, y, mod, num, count|
            if (mod == 262144) {
                ctrl.states = [ [nil, nil, Color.clear.alpha_(1.5) ], [nil, nil, Color.red.alpha_(0.5) ] ];
                if (~preset_active[node.key] == i) {
                    ~preset_active[node.key] = nil
                };
                cb.(i, true);
            }
        })
        .value_(if(isactive){1}{0})
    });

    grid = GridLayout.rows(
        buttons
    ).margins_(0).spacing_(0);
    view = View().layout_(grid);
    view;
})
)