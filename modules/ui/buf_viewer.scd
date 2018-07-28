(
~buf_viewer = {arg buf, size = 200, cb;

	var view = View().layout_(HLayout());
	var sfv = SoundFileView()
	.background_(Color.gray(0.3))
	.timeCursorOn_(true)
	.gridOn_(true)
	.resize_(5)
	.gridResolution_(0.0)
	.fixedSize_(size)
	.mouseUpAction = ({arg view;
		var loFrames, hiFrames;
		loFrames = view.selection(0)[0];
		hiFrames = view.selection(0)[1] + loFrames;
		cb.(loFrames, hiFrames);
	});
	sfv.setSelectionColor(0, Color.blue(alpha:0.5));

	buf.loadToFloatArray(action:{arg a;
		{
			sfv.setData(a, channels: buf.numChannels);
			sfv.setSelection (0, [0, buf.numFrames]);
			sfv.mouseUpAction.value(sfv);
		}.defer;
	});

	view.layout.add(sfv);
	view;
}
)