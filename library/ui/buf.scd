(
/*
wavecolors: [ Color(0.43959131240845, 0.79266436100006, 0.30364065170288), Color(0.66478049755096, 0.49995653629303, 0.70197350978851) ]
cursorcolor: Color(0.84537670612335, 0.36948044300079, 0.3913670539856)
selectioncolor: Color(0.51573536396027, 0.84512507915497, 0.53207337856293, 0.3)

wavecolors: [ Color(0.61928951740265, 0.83827149868011, 0.62928142547607), Color(0.39956138134003, 0.31510877609253, 0.32997171878815) ]
cursorcolor: Color(0.69044966697693, 0.50304594039917, 0.81559367179871)
selectioncolor: Color(0.54703931808472, 0.47684147357941, 0.30883383750916, 0.3)

wavecolors: [ Color(0.89660904407501, 0.62982008457184, 0.6746563911438), Color(0.43881783485413, 0.68764214515686, 0.819051861763) ]
cursorcolor: Color(0.39686644077301, 0.41232590675354, 0.30532243251801)
selectioncolor: Color(0.84771122932434, 0.69915246963501, 0.72183072566986, 0.3)

wavecolors: [ Color(0.40564169883728, 0.6053453207016, 0.7909015417099), Color(0.31981158256531, 0.58410909175873, 0.50972764492035) ]
cursorcolor: Color(0.70569634437561, 0.30306115150452, 0.59129848480225)
selectioncolor: Color(0.70866029262543, 0.53474006652832, 0.5210898399353, 0.3)

wavecolors: [ Color(0.60651075839996, 0.8049923658371, 0.70752568244934), Color(0.60326929092407, 0.47521297931671, 0.79439527988434) ]
cursorcolor: Color(0.36555833816528, 0.37462205886841, 0.48073024749756)
selectioncolor: Color(0.57690789699554, 0.77623701095581, 0.75495657920837, 0.3)

*/
Require("~/projects/droptableuser/library/ui/common.scd");
Fdef(\buf, {arg node;


	var baseview;
	var baseViewFunc = Fdef(\baseview);
	var key = node.key;
	var buf = node.get(\buf);
	var numframes = buf.numFrames;
	var osckey = (key ++ 'pos').asSymbol;
	var wavecolors = [Color.rand, Color.rand].debug(\wavecolors);
	var cursorcolor = Color.rand.debug(\cursorcolor);
	var selectioncolor = Color.rand.alpha_(0.3).debug(\selectioncolor);
	var gridcolor = Color.rand;
	var startPos = node.get(\startPos);
	var endPos = node.get(\endPos);

	var view = View()
	.layout_(VLayout().margins_(2).spacing_(2))
	.palette_(QPalette.dark);

	var sfv = SoundFileView()
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
	.mouseDownAction_({arg ctrl;
		true;
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

	OSCdef(osckey, {arg msg;
		{
			sfv.timeCursorPosition = msg[4];
		}.defer;
	}, osckey);

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

	view.layout.add(sfv);
	view = view.onClose_({
		\free.debug(osckey);
		OSCdef(osckey).free;
	})
	.fixedWidth_(200)
	.fixedHeight_(100);

	baseview = baseViewFunc.(view, key, 200, 100);
	baseview.front;
});
)
