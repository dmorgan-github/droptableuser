(
view: {arg objName, envir, components;

	var size = 12;
	var harms = 1.0/[1,2,3,4,5,6,7,8,9,10,11,12];
	var buf = {
		var buf = Buffer.alloc(s, 1024, 1);
		buf.cheby(harms);
		buf;
	}.();

	var node = NodeProxy.audio(s, 2)
	.filter(100, {arg sig_in;
		var in = sig_in * \input.ar(1);
		var buf = \buf.ar(0);
		var sig = Shaper.ar(buf, in);
		sig = LeakDC.ar(sig);
		Splay.ar(sig, spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
	})
	.set(\buf, buf);

	var harmsView = MultiSliderView()
	.action_({arg ctrl;
		NotificationCenter.notify(view, \status, "harm: " ++ (ctrl.index+1) ++ " " ++ ctrl.currentvalue);
		harms[ctrl.index] = ctrl.currentvalue;
		buf.cheby(harms);
	})
	.value_(harms)
	.drawRects_(true)
	.isFilled_(true)
	.fixedWidth_(300)
	.indexThumbSize_(300/size)
	.gap_(0);

	var specs = [
		\amp -> [0,4,\lin,0,1],
		\input -> [0, 10, \lin, 0, 1],
		\spread -> [0,1,\lin,0, 1],
		\center -> [-1,1,\lin,0,0],
	];

	var view = View().layout_(VLayout());
	var specsView = components[\specsView].(objName, specs, node, envir, view);
	view.layout.add(harmsView);
	view.layout.add(Button().action_({buf.plot}));
	view.layout.add(specsView);
	envir[objName] = node;

	NotificationCenter.register(view, \close, view, {arg msg;
		msg.debug("clean up");
		// not sure why this needs to be deferred
		// otherwise it crashes the server
		{
			buf.free;
		}.defer(5);
	});

	view;
}
)