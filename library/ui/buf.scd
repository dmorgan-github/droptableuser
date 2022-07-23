(
func: {arg node;

    var key = node.key;
    var refresh, skipjack;
    var bufspec, dorefresh;

    var buf = {
        var buf = node.get(\buf);
        if (buf.isNumber) {
            buf = Buffer.cachedBufferAt(Server.default, buf.asInteger)
        };
        buf;
    }.();

    var bufnumView, srView, numframesView, durView;
    var startPos = node.get(\startPos) ?? {0};
    var endPos = node.get(\endPos) ?? {1};

    var id = UniqueID.next;
    var oscdef = "bufpos_%".format(id).asSymbol;
    var osckey = 'bufpos';
    var numframes = buf.numFrames;
    var bufname = if (buf.path.notNil) {
        PathName(buf.path).fileName
    }{
        "buffer %".format(buf.bufnum)
    };
    var selstart = startPos * numframes;
    var selend = endPos * numframes;
    var selsize = selend - selstart;

    var wavecolors =  [
        Color(0.59429912567139, 0.71457996368408, 0.45395700931549),
        Color(0.85957117080688, 0.86903350353241, 0.57564690113068)
    ];
    var gridcolor = Color(0.59298334121704, 0.61996343135834, 0.82784349918365);
    var backgroundcolor = Color(0.32606270313263, 0.39292259216309, 0.8526659488678);// Color.rand.debug(\background);
    var cursorcolor = Color(0.84076716899872, 0.8562139749527, 0.69819803237915);
    var selectioncolor = Color(0.38695478439331, 0.68618059158325, 0.31084091663361, 0.3);

    var watcher;
    var nb = NumberBox();
    var end = Slider();
    var view = View().layout_(VLayout().margins_(0).spacing_(0));//.minSize_(Size(300, 150));
    var sfv = SoundFileView()
    .gridOn_(false)
    .drawsRMS_(false)
    .drawsCenterLine_(true)
    .drawsBoundingLines_(false)
    .gridColor_(Color.black)
    .background_(Color.black)
    .waveColors_([node.color, Color.red])
    .gridResolution_(0.0)
    .toolTip_(bufname)
    .timeCursorOn_(true)
    .timeCursorColor_(cursorcolor)
    .mouseUpAction_({|ctrl, x, y|
        var val = ctrl.selection(0);
        var start = val[0];
        var len = val[1];
        var end = start + len;
        var numframes = buf.numFrames;
        var startPos = start/numframes;
        var endPos = end/numframes;

        //[startPos, endPos].debug(\pos);
        if (endPos <= startPos) {
            var start = startPos * numframes;
            var size = numframes - start;
            endPos = 1;
            ctrl.setSelection(0, [start, size])
        };
        node.set('endPos', endPos, 'startPos', startPos);
    });

    watcher = {|obj, what, vals|
        if (what == \set) {
            vals.pairsDo({|k, v|
                if (k == \buf) {
                    buf = v;
                    if (buf.isNumber) {
                        buf = Buffer.cachedBufferAt(Server.default, buf.asInteger)
                    };
                    buf.loadToFloatArray(action:{|a|
                        {
                            var startPos = node.get(\startPos);
                            var endPos = node.get(\endPos);
                            var numframes, selstart, selend, selsize;
                            numframes = buf.numFrames;
                            selstart = startPos * numframes;
                            selend = endPos * numframes;
                            selsize = selend - selstart;

                            sfv.setData(a, channels: buf.numChannels);
                            sfv.setSelection(0, [selstart, selsize]);

                            bufnumView.string = buf.bufnum;
                            srView.string = buf.sampleRate;
                            numframesView.string = buf.numFrames;
                            durView.string = buf.duration;

                        }.defer
                    });
                }
            })
        };
    };

    //sfv.setSelectionColor(0, selectioncolor);
    //sfv.setSelectionStart(0, selstart);
    //sfv.setSelectionSize(0, selend - selstart);
    buf.loadToFloatArray(action:{|a|
        {
            var startPos = node.get(\startPos);
            var endPos = node.get(\endPos);
            var numframes, selstart, selend, selsize;
            numframes = buf.numFrames;
            selstart = startPos * numframes;
            selend = endPos * numframes;
            selsize = selend - selstart;

            sfv.setData(a, channels: buf.numChannels);
            sfv.setSelection(0, [selstart, selsize]);

        }.defer
    });

    /*
    bufspec = node.getSpec['buf'] ?? { [buf.bufnum, buf.bufnum].asSpec };
    view.layout.add(VLayout(
        LevelSlider("buf", bufspec, node.color)
        .value_(buf.bufnum)
        .mouseUpAction_({|ctrl|
            var val = ctrl.value;
            node.set(\buf, val);
        })
    ));
    */

    /*
    view.layout.add(HLayout(

        LevelSlider("startPos", [0, 1].asSpec, node.color)
        .action_({|ctrl|
            //selstart = (ctrl.value * numframes).max(0);
            //selend = (selstart + selsize).min(numframes);
            //selsize = selend - selstart;
            //nb.value = selsize/buf.sampleRate;
            //sfv.setSelectionStart(0, selstart);
            //sfv.setSelectionSize(0, selsize);
        })
        .mouseUpAction_({|ctrl|
            //node.set(\startPos, selstart/numframes, \endPos, selend/numframes);
        })
        .value_(startPos)
        ,

        nb.maxWidth_(60)
        .action_({|ctrl|
            //var val = buf.sampleRate * ctrl.value.max(0.001);
            //selend = (selstart + val).min(numframes);
            //selsize = selend - selstart;
            //sfv.setSelectionSize(0, selsize);
            //end.value = selend.linlin(0, numframes, 0, 1);
            //node.set(\endPos, selend/numframes)
        })
        .clipLo_(0.001)
        .value_(selsize/buf.sampleRate)
    ));
    */

    view.layout.add(sfv);
    view.layout.add(
        HLayout(nil,
            bufnumView = StaticText().string_(buf.bufnum),
            StaticText().string_(" | "),
            srView = StaticText().string_(buf.sampleRate),
            StaticText().string_(" | "),
            numframesView = StaticText().string_(buf.numFrames),
            StaticText().string_(" | "),
            durView = StaticText().string_(buf.duration)
        ).spacing_(2).margins_(2)
    );

    // TODO: this is very inneficient
    // but i'm not sure how to render buffer
    // updates without reloading
    refresh = {
        buf.loadToFloatArray(action:{arg a;
		    {
			    sfv.setData(a, channels: buf.numChannels);
		    }.defer
	    })
    };

    // we'll refresh the display only for smaller buffers
    dorefresh = (node.get(\dorefresh) == 1);
    if (dorefresh) {
        skipjack = SkipJack(refresh, dt: 1, name:"%_%".format(node.key, id));
    };

    node.set(\bufposreplyid, id);
    OSCdef(oscdef, {arg msg;
        var val = msg[4];
        var replyid = msg[2];
        {
            if (replyid == id) {
                if (val.notNil) {
                    sfv.timeCursorPosition = val;
                }
            }
        }.defer;
    }, osckey);

    node.addDependant(watcher);
    view.name = bufname;
    view.onClose_({
        "close".debug(\buf);
        node.removeDependant(watcher);
        if (skipjack.notNil) {
            skipjack.stop;
        };
        OSCdef(oscdef).free;
    });//.front;
}
)


