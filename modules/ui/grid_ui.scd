(

~mouse_pad = {arg key, size;

	var view = UserView()
	.fixedSize_(size)
	.drawFunc_({arg view;
		Pen.fillColor = Color.black.alpha_(rrand(0.1, 0.8));
		Pen.fillRect(Rect(0, 0, size, size));
	})
	.mouseOverAction_({arg ctrl, x, y;

		if (x.isNil.not) {
			var bounds = ctrl.bounds;
			var width = bounds.width;
			var height = bounds.height;
			var x_ = x.linlin(0,width,0,1);
			var y_ = y.linlin(0,height,1,0);

			Fdef(('mo_' ++ key).asSymbol).value(ctrl, x_, y_);
		};
		false;
	})
	.mouseUpAction_({arg ctrl, x, y, modifiers;

		if (x.isNil.not) {
			var bounds = ctrl.bounds;
			var width = bounds.width;
			var height = bounds.height;
			var x_ = x.linlin(0,width,0,1);
			var y_ = y.linlin(0,height,1,0);

			Fdef(('mu_' ++ key).asSymbol).value(ctrl, x_, y_, modifiers);
		};
		false;
	})
	.mouseDownAction_({arg ctrl, x, y, modifiers, buttonNumber, clickCount;

		if (x.isNil.not) {

			var bounds = ctrl.bounds;
			var width = bounds.width;
			var height = bounds.height;
			var x_ = x.linlin(0,width,0,1);
			var y_ = y.linlin(0,height,1,0);

			if (clickCount == 2) {
				Fdef(('dc_' ++ key).asSymbol).value(ctrl, x_, y_, modifiers, buttonNumber, clickCount);
			}{
				Fdef(('md_' ++ key).asSymbol).value(ctrl, x_, y_, modifiers, buttonNumber, clickCount);
			}
		};
		false;
	})
	.mouseEnterAction_({arg ctrl, x, y;

		if (x.isNil.not) {
			var bounds = ctrl.bounds;
			var width = bounds.width;
			var height = bounds.height;
			var x_ = x.linlin(0,width,0,1);
			var y_ = y.linlin(0,height,1,0);

			Fdef(('me_' ++ key).asSymbol).value(ctrl, x_, y_);
		};
		false;
	})
	.mouseMoveAction_({arg ctrl, x, y, modifiers;

		if (x.isNil.not) {
			var bounds = ctrl.bounds;
			var width = bounds.width;
			var height = bounds.height;
			var x_ = x.linlin(0,width,0,1);
			var y_ = y.linlin(0,height,1,0);

			Fdef(('mm_' ++ key).asSymbol).value(ctrl, x_, y_, modifiers);
		};
		false;
	});

	view;
};

~grid_ui = {arg size=100, grid=3;

	var rows = grid;
	var cols = grid;

	var defaultView = {
		UserView()
		.fixedSize_(size)
		.drawFunc_({arg view;
			Pen.fillColor = Color.black.alpha_(rrand(0.1, 0.8));
			Pen.fillRect(Rect(0, 0, size, size));
		});
	};

	var uv = {arg y, x;

		var key = (y.asSymbol ++ '_' ++ x.asSymbol).asSymbol;
		var myView = Fdef(('v_' ++ key).asSymbol).value(size);

		if (myView.isNil.not) {
			myView
		} {
			~mouse_pad.(key, size);
		};
	};

	var view = View()
	.alwaysOnTop_(false)
	.palette_(QPalette.dark)
	.acceptsMouseOver_(true)
	.layout_(VLayout().spacing_(0.5).margins_(0.5))
	.minWidth_(size * cols)
	.minHeight_(size * rows + 15);

	view.layout.add(
		Button().states_([ ["--"], ["__"] ]).action_({arg ctrl;
			if (ctrl.value == 1) {
				view.alwaysOnTop = true;
			}{
				view.alwaysOnTop = false;
			}
		}).maxSize_(15);
	);

	rows.do({arg i;
		var layout = HLayout();
		cols.do({arg j;
			layout.add(uv.(i, j));
		});
		view.layout.add(layout);
	});

	view.front;
};
)