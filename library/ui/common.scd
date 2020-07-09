(
Fdef(\baseview, {arg view, title, w, h;

	var mousey, mousex;
	var width = w ? view.sizeHint.width;
	var height = h ? view.sizeHint.height;
	var top = Window.screenBounds.height - height;
	var win = Window.new(title, bounds:Rect(0, top, width, height), border:false);

	var outerview = View().layout_(
		VLayout(
			HLayout(
				StaticText().string_(title),
				nil,
				Button().states_([ ["x", Color.white, nil] ])
				.action_({ win.close })
				.maxWidth_(25)
			).margins_(2).spacing_(1),
			view
		).margins_(0).spacing_(0)
	)
	.mouseDownAction_({arg ctrl, x, y;
		mousey = ctrl.sizeHint.height - y;
		mousex = x;

		//[win.bounds.top, mousey].postln;
	})
	.mouseMoveAction_({arg ctrl, x, y;

		var height = ctrl.sizeHint.height;
		var top = ctrl.sizeHint.height - y;
		var left = win.bounds.left + x - mousex;
		var width = ctrl.sizeHint.width;
		top = win.bounds.top + (top - mousey);
		//top = win.bounds.top + top;
		//if (top > (Window.screenBounds.height - height)) {
		//	top = Window.screenBounds.height - height;
		//};
		//[top].postln;
		//[mousey, top, top - mousey].postln;

		win.bounds = Rect(left, top, width, height);
		true;
	});
	win.layout = VLayout(outerview).margins_(0).spacing_(0);
	win.asView.palette_(QPalette.dark);
})
)