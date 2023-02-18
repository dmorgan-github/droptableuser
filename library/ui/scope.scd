(
func: {|node|

    var cnt = 0;
    var lastx, lasty;
    var zoomy = 10, zoomx = 5;
    var mousedown = false;
    var view, scope, scopeview;
    var numchannels, sliderpalette, xslider, yslider;
    node = if (node.respondsTo(\node)) {node.node}{node};

    sliderpalette = QPalette();
    sliderpalette.setColor(Color.clear, \window, \active);
    sliderpalette.setColor(Color.clear, \highlight, \active);

    numchannels = node.numChannels;
    scopeview = View().layout_(VLayout().margins_(0).spacing_(0));
    scope = Stethoscope.new(s, view:scopeview).style_(1)
    .index_(node.bus.index)
    .numChannels_(numchannels)
    .yZoom_(10)
    .xZoom_(5);

    4.do({
        scopeview.children[0].children[0].remove
    });
    scopeview.children[0].children[0].waveColors_([node.color, node.color.complementary]);
    scopeview.children[0].children[2].remove;
    scopeview.children[0].children[1].remove;
    scopeview.children[0].children[0].background = Color.black;//Color.new255(77, 77, 77);
    scopeview.mouseDownAction_({|ctrl, x, y, mod, num, count|
        lastx = x;
        lasty = y;

        if (count == 2) {
            scope.style = cnt.mod(3);
            cnt = cnt + 1;
        };
    });
    
    view = View().layout_(HLayout(
        VLayout(
            scopeview, 
            HLayout(

                StaticText().string_("x"),

                NumberBox()
                .action_({|ctrl|
                    var zoom = ctrl.value.clip(1, 10);
                    scope.xZoom = zoom;
                })
                .background_(Color.clear)
                .minDecimals_(2)
                .clipHi_(10)
                .clipLo_(1)
                .maxWidth_(45)
                .value_(5.0)
                ,

                StaticText().string_("y"),
                NumberBox()
                .action_({|ctrl|
                    var zoom = ctrl.value.clip(1, 10);
                    scope.yZoom = zoom;
                })
                .background_(Color.clear)
                .minDecimals_(2)
                .clipHi_(10)
                .clipLo_(1)
                .maxWidth_(45) 
                .value_(10.0),

                nil

            ).margins_(0).spacing_(10)

            //.palette_(sliderpalette)
        ).margins_(0).spacing_(0),
               //.palette_(sliderpalette)
    ).margins_(0).spacing_(0));
    scopeview.onClose = { scope.free };
    view
}
)
