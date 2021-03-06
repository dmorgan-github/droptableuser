(
Require(App.librarydir ++ "ui/common.scd");
Fdef(\buf, {arg node;

	var width = 200 * 1.5;
	var height = 100 * 1.5;
	var id = UniqueID.next;
	var baseview;
	var baseViewFunc = Fdef(\baseview);
    var playview = Fdef(\playview);
    //var ctrlView = Fdef(\ctrlview);
	var key = node.key;
	var buf = node.get(\buf).debug("buf for %".format(key));
	var numframes = buf.numFrames;
	var osckey = 'bufpos';
	//(key ++ 'pos').asSymbol;
	var wavecolors = [Color.rand, Color.rand].debug(\wavecolors);
	var cursorcolor = Color.rand.debug(\cursorcolor);
	var selectioncolor = Color.rand.alpha_(0.3).debug(\selectioncolor);

	//var wavecolors = [
	//	Color(0.78598186969757, 0.75455839633942, 0.59287083148956),
	//	Color(0.34656608104706, 0.33435337543488, 0.45881831645966)
	//];

	//var cursorcolor = Color(0.48647997379303, 0.57335543632507, 0.37658343315125);
	//var selectioncolor = Color(0.78476850986481, 0.36488585472107, 0.75622744560242, 0.3);
    var gridcolor = Color.rand.debug(\gridcolor);
	var startPos = node.get(\startPos) ? 0;
	var endPos = node.get(\endPos) ? 1;
	var sfv;

	var func = {arg obj, key, vals;
		if (key == \set) {
			var dict = vals.asDict;
			if (dict[\buf].isNil.not) {
				dict[\buf].loadToFloatArray(action:{arg a;
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

	var view = View()
	.layout_(VLayout().margins_(2).spacing_(2));
	//.palette_(QPalette.dark);

    /*
    To zoom in/out: Shift + right-click + mouse-up/down
    To scroll: right-click + mouse-left/right
    */
	sfv = SoundFileView()
	.background_(Color.rand.alpha_(0.3))
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

	// TODO: refactor to use func from above
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
        Button().action_({U(\ngui, node)})
    );
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

	node.addDependant(func);

	view.layout.add(sfv);
	view = view.onClose_({
		\free.debug(osckey);
		node.removeDependant(func);
		OSCdef(node.key).free;
	})
	.fixedWidth_(width)
	.fixedHeight_(height);

	baseview = baseViewFunc.(view, key, width, height);
	baseview.front;
});
)
