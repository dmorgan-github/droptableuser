Require(App.librarydir ++ "ui/common.scd");
(
func: {arg node;

    var key = node.key;

    var buf = {
        var buf = node.get(\buf);
        if (buf.isNumber) {
            buf = Buffer.cachedBufferAt(Server.default, buf.asInteger)
        };
        buf;
    }.();//.debug("buf");

    var startPos = node.get(\startPos) ?? {0};
    var endPos = node.get(\endPos) ?? {1};

    var id = UniqueID.next;
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
    .gridResolution_(0.0)
    .drawsRMS_(false)
    .toolTip_(bufname)
    .timeCursorOn_(true)
    //.timeCursorPosition_(220500)
    .waveColors_(wavecolors)
    .background_(backgroundcolor.alpha_(0.3))
    .gridColor_(gridcolor)
    .timeCursorColor_(cursorcolor);

    watcher = {|obj, what, vals|
        if (what == \set) {
            vals.pairsDo({|k, v|
                if (k == \buf) {
                    var buf = v;
                    if (buf.isNumber) {
                        buf = Buffer.cachedBufferAt(Server.default, buf.asInteger)
                    };
                    buf.loadToFloatArray(action:{|a|
                        {
                            sfv.setData(a, channels: buf.numChannels);
                        }.defer
                    });

                }
            })
        };
    };

    sfv.setSelectionColor(0, selectioncolor);
    sfv.setSelectionStart(0, selstart);
    sfv.setSelectionSize(0, selend - selstart);
    buf.loadToFloatArray(action:{|a|
        {
            sfv.setData(a, channels: buf.numChannels);
        }.defer
    });
    view.layout.add(HLayout(

        Slider().orientation_('horizontal')
        .action_({|ctrl|
            selstart = (ctrl.value * numframes).max(0);
            selend = (selstart + selsize).min(numframes);
            selsize = selend - selstart;
            nb.value = selsize/buf.sampleRate;
            sfv.setSelectionStart(0, selstart);
            sfv.setSelectionSize(0, selsize);
        })
        .mouseUpAction_({|ctrl|
            node.set(\startPos, selstart/numframes, \endPos, selend/numframes);
        })
        .value_(startPos),

        /*
        end.orientation_('horizontal')
        .action_({|ctrl|
            selend = ctrl.value * numframes;
            selsize = selend - selstart;
            sfv.setSelectionSize(0, selsize);
            nb.value = selsize/buf.sampleRate;
        })
        .mouseUpAction_({|ctrl|
            node.set(\endPos, selend/numframes)
        })
        .value_(endPos),
        */

        nb.maxWidth_(60).action_({|ctrl|
            var val = buf.sampleRate * ctrl.value.max(0.001);
            selend = (selstart + val).min(numframes);
            selsize = selend - selstart;
            sfv.setSelectionSize(0, selsize);
            end.value = selend.linlin(0, numframes, 0, 1);
            node.set(\endPos, selend/numframes)
        })
        .clipLo_(0.001)
        .value_(selsize/buf.sampleRate)
    ));
    view.layout.add(sfv);
    view.layout.add(
        HLayout(nil,
            StaticText().string_(buf.bufnum),
            StaticText().string_(" | "),
            StaticText().string_(buf.sampleRate),
            StaticText().string_(" | "),
            StaticText().string_(buf.numFrames),
            StaticText().string_(" | "),
            StaticText().string_(buf.duration)
        ).spacing_(2).margins_(2)
    );

    node.set(\bufposreplyid, id);
    OSCdef(key, {arg msg;
        var val = msg[4];
        var replyid = msg[2];
        {
            if (replyid == id) {
                sfv.timeCursorPosition = val;
            }
        }.defer;
    }, osckey);

    view.name = bufname;
    view.onClose_({
        OSCdef(key).free;
    });//.front;
}
)


