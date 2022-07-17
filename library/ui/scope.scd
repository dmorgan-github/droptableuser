(
func: {|node|

    var cnt = 0;
    var lastx, lasty;
    var zoomy = 10, zoomx = 5;
    var mousedown = false;
    var numchannels = node.numChannels;
    var view = View().layout_(VLayout().margins_(0).spacing_(0));
    var scope = Stethoscope.new(s, view:view).style_(1)
    .index_(node.bus.index)
    .numChannels_(numchannels)
    .yZoom_(10)
    .xZoom_(5);

    4.do({
        view.children[0].children[0].remove
    });
    view.children[0].children[0].waveColors_([Color.rand, Color.rand]);
    view.children[0].children[2].remove;
    view.children[0].children[1].remove;
    view.children[0].children[0].background = Color.black;//Color.new255(77, 77, 77);
    view.mouseDownAction_({|ctrl, x, y, mod, num, count|
        lastx = x;
        lasty = y;

        if (count == 2) {
            scope.style = cnt.mod(3);
            cnt = cnt + 1;
        };
    });
    view.mouseMoveAction_({|ctrl, x, y|

        var xdir, ydir;

        xdir = if (x < lastx) {-1}{1} * 0.05;
        ydir = if (y < lasty) {-1}{1} * 0.05;

        zoomx = (zoomx + xdir).clip(1, 10);
        zoomy = (zoomy + ydir).clip(1, 10);

        scope.xZoom = zoomx;
        scope.yZoom = zoomy;

    });
    view.onClose = { scope.free };
    view;
}
)
