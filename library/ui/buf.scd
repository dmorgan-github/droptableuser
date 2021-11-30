(
Require(App.librarydir ++ "ui/common.scd");
Fdef(\buf, {arg node;

    var key = node.key;

    var buf = {
        var buf = node.get(\buf);
        if (buf.isNumber) {
            buf = Buffer.cachedBufferAt(Server.default, buf.asInteger)
        };
        buf;
    }.();

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

    var nb = NumberBox();
    var end = Slider();
    var view = View().layout_(VLayout().margins_(0).spacing_(0)).minSize_(Size(300, 150));
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

        nb.maxWidth_(60).action_({|ctrl|
            var val = buf.sampleRate * ctrl.value;
            selend = (selstart + val).min(numframes);
            selsize = selend - selstart;
            sfv.setSelectionSize(0, selsize);
            end.value = selend.linlin(0, numframes, 0, 1);
            node.set(\endPos, selend/numframes)
        })
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
    }).front;

    /*
	var width = 200 * 1.5;
	var height = 100 * 1.5;
	var id = UniqueID.next;
	var baseview;
	var baseViewFunc = Fdef(\baseview);
    var playview = Fdef(\playview);
    //var ctrlView = Fdef(\ctrlview);
	var key = node.key;
    var buf = {

        var buf = node.get(\buf);
        if (buf.isNumber) {
            buf = Buffer.cachedBufferAt(Server.default, buf.asInteger)
        };
        buf;

    }.();//
	var numframes = buf.numFrames;
	var osckey = 'bufpos';

	//var wavecolors = [Color.rand, Color.rand].debug(\wavecolors);
    var wavecolors =  [
        Color(0.59429912567139, 0.71457996368408, 0.45395700931549),
        Color(0.85957117080688, 0.86903350353241, 0.57564690113068)
    ];

    /*
    var wavecolors = [
        Color(0.8730087518692, 0.55612449645996, 0.8803555727005),
        Color(0.76174085140228, 0.44574573040009, 0.67218403816223)
    ];
    */

	//var cursorcolor = Color.rand.debug(\cursorcolor);
    var cursorcolor = Color(0.84076716899872, 0.8562139749527, 0.69819803237915);
	//var selectioncolor = Color.rand.alpha_(0.3).debug(\selectioncolor);
    var selectioncolor = Color(0.38695478439331, 0.68618059158325, 0.31084091663361, 0.3);
    var skipjackname = "buf_%".format(UniqueID.next).asSymbol;

	//var wavecolors = [
	//	Color(0.78598186969757, 0.75455839633942, 0.59287083148956),
	//	Color(0.34656608104706, 0.33435337543488, 0.45881831645966)
	//];

	//var cursorcolor = Color(0.48647997379303, 0.57335543632507, 0.37658343315125);
	//var selectioncolor = Color(0.78476850986481, 0.36488585472107, 0.75622744560242, 0.3);
   // var gridcolor = Color.rand.debug(\gridcolor);
    var gridcolor = Color(0.59298334121704, 0.61996343135834, 0.82784349918365);
    var backgroundcolor = Color(0.32606270313263, 0.39292259216309, 0.8526659488678);// Color.rand.debug(\background);
    var startPos = node.get(\startPos) ?? {0};
    var endPos = node.get(\endPos) ?? {1};
	var sfv;

	var func = {arg obj, key, vals;
		if (key == \set) {
			var dict = vals.asDict;
			if (dict[\buf].isNil.not) {
                var buf = dict[\buf];
                if (buf.isNumber) {
                    buf = Buffer.cachedBufferAt(Server.default, buf.asInteger);
                };
				buf.loadToFloatArray(action:{arg a;
					{
						var start = startPos * numframes;
						var end = (endPos * numframes) - start;
						sfv.setData(a, channels: buf.numChannels);
						sfv.setSelection (0, [start, end]);
					}.defer
				});
			}
		}
	};

    var func2 = {
        var buf = node.get(\buf);
        var startPos = node.get(\startPos) ?? {0};
        var endPos = node.get(\endPos) ?? {1};

        if (buf.isNumber) {
            buf = Buffer.cachedBufferAt(Server.default, buf.asInteger);
        };
        // is it safe to do this?
        buf.loadToFloatArray(action:{arg a;
            {
                var start = startPos * numframes;
                var end = (endPos * numframes) - start;
                sfv.setData(a, channels: buf.numChannels);
                sfv.setSelection (0, [start, end]);
            }.defer
        });
    };


	var view = View()
	.layout_(VLayout().margins_(2).spacing_(2));
	//.palette_(QPalette.dark);

    //SkipJack(func2, 1/10, name:skipjackname);

    /*
    To zoom in/out: Shift + right-click + mouse-up/down
    To scroll: right-click + mouse-left/right
    */
	sfv = SoundFileView()
    .background_(backgroundcolor.alpha_(0.3))
	.timeCursorOn_(true)
	.gridOn_(true)
	.resize_(5)
	.gridResolution_(0.0)
	.waveColors_( wavecolors )
	.rmsColor_(Color.rand)
	.timeCursorColor_(cursorcolor)
	.gridColor_(gridcolor)
	.drawsRMS_(false)
	.mouseDownAction_({arg ctrl, x, y, mod, num, click;
		if (num == 1) {nil;} {true;}
	});
	sfv.setSelectionColor(0, selectioncolor);

	buf.loadToFloatArray(action:{arg a;
		{
			var start = startPos * numframes;
			var end = (endPos * numframes) - start;
			sfv.setData(a, channels: buf.numChannels);
			sfv.setSelection (0, [start, end]);
		}.defer
	});

	node.set(\bufposreplyid, id);
	OSCdef(node.key, {arg msg;
		var val = msg[4];
		var replyid = msg[2];
		{
			if (replyid == id) {
				sfv.timeCursorPosition = val;
			}
		}.defer;
	}, osckey);

    playview = playview.(node);//.addDependant(viewListener);
    view.layout.add(playview);

	view.layout.add(
		RangeSlider()
		.orientation_(\horizontal)
		.action_({arg ctrl;
			var lo = ctrl.lo * numframes;
			var hi = ctrl.hi * numframes;
			sfv.setSelectionStart(0, lo);
			sfv.setSelectionSize(0, hi - lo);
			node.set(\startPos, lo/numframes, \endPos, hi/numframes, \trig, 1);
		})
		.lo_(startPos)
		.hi_(endPos)
	);

	//node.addDependant(func);

	view.layout.add(sfv);
	view = view.onClose_({
		\free.debug(osckey);
		node.removeDependant(func);
		OSCdef(node.key).free;
        //SkipJack.stop(skipjackname);
	})
	.fixedWidth_(width)
	.fixedHeight_(height);

	baseview = baseViewFunc.(view, key, width, height);
	baseview.front;
    */
});
)
