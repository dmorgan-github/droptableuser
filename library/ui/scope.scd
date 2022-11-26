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
    //view.mouseMoveAction_({|ctrl, x, y|

    //    var xdir, ydir;

    //    xdir = if (x < lastx) {-1}{1} * 0.05;
    //    ydir = if (y < lasty) {-1}{1} * 0.05;

    //    zoomx = (zoomx + xdir).clip(1, 10);
    //    zoomy = (zoomy + ydir).clip(1, 10);

    //    scope.xZoom = zoomx;
    //    scope.yZoom = zoomy;

    //});
    view = View().layout_(HLayout(
        VLayout(
            scopeview, 
            Slider()
            .orientation_(\horizontal)
            .thumbSize_(0.5)
            .action_({|ctrl|
                var zoom = ctrl.value.linlin(0, 1, 1, 10);
                scope.xZoom = zoom;
            })
            .value_(5.linlin(1, 10, 0, 1))
            .background_(Color.clear)
            //.palette_(sliderpalette)
        ).margins_(0).spacing_(0),
        Slider()
        .orientation_(\vertical)
        .thumbSize_(0.5)
        .action_({|ctrl|
            var zoom = ctrl.value.linlin(0, 1, 1, 10);
            scope.yZoom = zoom;
        })
        .value_(10.linlin(1, 10, 0, 1))
        .background_(Color.clear)
        //.palette_(sliderpalette)
    ).margins_(0).spacing_(0));
    scopeview.onClose = { scope.free };
    view
}
)
