(
Require("~/projects/droptableuser/library/ui/common.scd");
Fdef(\ngui, {arg node;

	var baseview;
	var win;
	var ctrlView = Fdef(\ctrlview);
	var scrollView = ScrollView(bounds:Rect(0,0,160,300));
	var view = View().layout_(VLayout().margins_(0.2).spacing_(0.2));
	var cb = {arg key, val;
		node.set(key, val)
	};

	node.controlNames.do({arg cn;
		var k = cn.name;
		var v = node.getSpec(k) ? [0, 1, \lin, 0, 1];
		var val = node.get(k);
		var ctrl = ctrlView.(k, v.asSpec, Color.rand, val, cb);
		view.layout.add(ctrl);
	});

	view.layout.add(nil);
	scrollView.canvas = view.background_(Color.clear);

	win = View().layout_(VLayout(
		HLayout(
			Button().states_([
				[">"],
				["[]"]
			]).action_({arg ctrl;
				if (ctrl.value == 1) {
					node.play;
				} {
					node.stop;
				}
			})
			.value_(node.isMonitoring.asInteger)
			.maxHeight_(18)
			.maxWidth_(25),
			Slider()
			.orientation_(\horizontal)
			.thumbSize_(7)
			.action_({arg ctrl;
				node.vol = ctrl.value;
			})
			.value_(node.vol)
			.minWidth_(50),

			Slider()
			.orientation_(\horizontal)
			.thumbSize_(7)
			.maxWidth_(20)
			.action_({arg ctrl;
				node.fadeTime = ctrl.value;
			})
			.value_(node.fadeTime)
			.minWidth_(50),
		)
	).margins_(2).spacing_(2));

	win.layout.add(scrollView);
	win = win.fixedSize_(Size(150, 170));
	baseview = Fdef(\baseview).(win, node.key, 150, 170);
	baseview.front;
});
//Fdef(\ngui).(~nij);
)

