(
func: {|node|

    var background, view, scope, stack, scopeview;
    var monitorwatcher, color;
    view = View(bounds:Rect(0, 0, 511/2, 300/2)).layout_(VLayout().margins_(0).spacing_(0));
    scopeview = View(bounds:Rect(0, 0, 511/2, 300/2)).layout_(VLayout().margins_(0).spacing_(0));
    scope = FreqScopeView(scopeview, scopeview.bounds);
    node = if (node.respondsTo(\node)) {node.node}{node};
    color = if (node.isMonitoring) { node.color } { Color.grey};

    monitorwatcher = {|obj, what|
        if (what == \play) {
            scope.waveColors_([node.color]);
        }{
            if (what == \stop) {
                scope.waveColors_([Color.grey]);
            }
        }
    };

    node.addDependant(monitorwatcher);
    background = {

        var view, markersImage;
        var renderBackgroundImage;
        var freqMarkersFont = Font("Arial", 11);
        var minFreq = 20;
        var maxFreq = 24e3;

        var freqMarkers = [
            (freq:20, tag:"20Hz"), (freq:30), (freq:40), (freq:50), (freq:60), (freq:70), (freq:80),
            (freq:90), (freq:100, tag:"100Hz"), (freq:200), (freq:300), (freq:400), (freq:500), (freq:600),
            (freq:700), (freq:800), (freq:900), (freq:1000, tag:"1kHz"), (freq:2000), (freq:3000),
            (freq:4000), (freq:5000, /*tag:"5kHz"*/), (freq:6000), (freq:7000), (freq:8000), (freq:9000),
            (freq:10e3, tag:"10kHz"),
            /*	(freq:11e3), (freq:12e3), (freq:13e3), (freq:14e3), (freq:15e3), (freq:16e3), (freq:17e3),
            (freq:18e3), (freq:19e3), */
            (freq:24e3) ];

        renderBackgroundImage = {|view|

            markersImage = Image(view.bounds.width.asInteger,view.bounds.height.asInteger);

            markersImage.draw({|image|
                var scaleZero, viewWidth, viewHeight, info, cursorX, cursorY, kernel, font,
                stringBounds;

                viewWidth  = image.width;
                viewHeight = image.height;
                scaleZero = (image.height-1.0) * 0.5;

                Pen.smoothing_(false); // antialias off
                Pen.strokeColor = Color.gray;
                Pen.color = Color.gray;
                Pen.width = 0.5;
                Pen.strokeRect(Rect(0,0,viewWidth-1,viewHeight-1));
                Pen.line(Point(0,scaleZero), Point(viewWidth-1.0,scaleZero));

                freqMarkers.do { arg marker;
                    var x, freq, tag;
                    freq = marker.freq;
                    if (freq >=minFreq) {
                        x = freq.explin(minFreq, maxFreq, 0, viewWidth);
                        Pen.line(Point(x,0), Point(x,viewHeight));
                        tag = marker.tag;
                        if (tag.notNil) {
                            Pen.stringAtPoint(tag, Point(x+2,4), freqMarkersFont);
                        };
                    };
                };

                Pen.stroke;
            });
        };

        view = UserView.new( bounds:Rect(0,0,400,200));
        view.drawFunc_({arg view;
            markersImage.drawAtPoint(0@0);
        });
        view.onResize_({ arg view;
            var viewWidth, viewHeight;
            //"onResize".postln;
            viewWidth  = view.bounds.width;
            viewHeight = view.bounds.height;
            if (markersImage.width!=viewWidth or:{markersImage.height != viewHeight }) {
                //renderMarkersImage.value;
                renderBackgroundImage.(view);
            };
            view.refresh;
        });
        renderBackgroundImage.(view);
        view.refresh;
        view;
    };

    stack = StackLayout(background.().alpha_(0.5), scopeview).mode_(1);
    view.layout.add(stack);

    scope.inBus = node.bus.index;
    scope.freqMode = 1;
    scope.active = true;
    scope.fill = false;
    scope.waveColors_([color]);
    view.onClose_({
        node.removeDependant(monitorwatcher);
        scope.kill
    }); // YOU MUST HAVE THIS
    view
}
)


