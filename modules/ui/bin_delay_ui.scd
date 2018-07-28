(
~bin_delay_ui = {arg size = 200, dels = {}, fb = {};

	var view = View().layout_(VLayout().margins_(0).spacing_(0));

	var delayView = MultiSliderView().action_({arg ctrl;
		var val = ctrl.currentvalue;
		dels.value(ctrl.index, val);
	})
	.value_(Array.fill(size, {0}))
	.xOffset_(5)
	.thumbSize_(12.0)
	.fixedHeight_(size/2)
	.fixedWidth_(size)
	.valueThumbSize_(15.0)
	.indexThumbSize_(300/size)
	.gap_(0);

	var fbView = MultiSliderView().action_({arg ctrl;
		fb.set(ctrl.index, ctrl.currentvalue);
	})
	.value_(Array.fill(size, {0}))
	.xOffset_(5)
	.thumbSize_(12.0)
	.thumbSize_(12.0)
	.fixedHeight_(size/2)
	.fixedWidth_(size)
	.valueThumbSize_(15.0)
	.indexThumbSize_(300/size)
	.gap_(0);

	view.layout.add(delayView);
	view.layout.add(fbView);
	view;
}
)