(
view: {arg objName, envir, components;

	var size = 128;
	var maxdel = 0.5;
	var dels = Buffer.alloc(s, size, 1);
	var fb = Buffer.alloc(s, size, 1);

	var node = NodeProxy.audio(s, 2)
	.filter(100, {arg sig_in;

		var in = sig_in * \input.ar(1);
		var maxdel = 0.5;
		var buf = LocalBuf(size * 2, 1).clear;
		var pulse = Impulse.ar(0.33);
		var chain = FFT(buf, in, 0.25);
		chain = PV_BinDelay(chain, maxdel, \dels.ar, \fb.ar, 0.25);

		Splay.ar(IFFT(chain), spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
	})
	.set(\dels, dels, \fb, fb);

	var specs = [
		\pan -> [-1,1,\lin,0,0],
		\amp -> [0,4,\lin,0,1],
		\input -> [0, 10, \lin, 0, 1],
		\spread -> [0,1,\lin,0, 1],
		\center -> [-1,1,\lin,0,0],
	];

	var view = View().layout_(VLayout());
	var specsView = components[\specsView].(objName, specs, node, envir, view);

	var delayView = MultiSliderView().action_({arg ctrl;
		var val = ctrl.currentvalue * maxdel;
		NotificationCenter.notify(view, \status, "del: " ++ ctrl.index ++ " " ++ val);
		dels.set(ctrl.index, val);
	})
	.value_(Array.fill(size, {0}))
	.xOffset_(5)
	.thumbSize_(12.0)
	.valueThumbSize_(15.0)
	.fixedWidth_(300)
	.indexThumbSize_(300/size)
	.gap_(0);

	var fbView = MultiSliderView().action_({arg ctrl;
		NotificationCenter.notify(view, \status, "fb: " ++ ctrl.index ++ " " ++ ctrl.currentvalue);
		fb.set(ctrl.index, ctrl.currentvalue);
	})
	.value_(Array.fill(size, {0}))
	.xOffset_(5)
	.thumbSize_(12.0)
	.thumbSize_(12.0)
	.valueThumbSize_(15.0)
	.fixedWidth_(300)
	.indexThumbSize_(300/size)
	.gap_(0);

	view.layout.add(delayView);
	view.layout.add(fbView);
	view.layout.add(specsView);

	envir[objName] = node;

	NotificationCenter.register(view, \close, view, {arg msg;
		msg.debug("clean up");
		// not sure why this needs to be deferred
		// otherwise it crashes the server
		{
			dels.free;
			fb.free;
		}.defer(5);
	});

	view;
}
)