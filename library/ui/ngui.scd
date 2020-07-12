(
Require("~/projects/droptableuser/library/ui/common.scd");
Fdef(\ngui, {arg node;

	var baseview;
	var win;
	var view = View().layout_(VLayout().margins_(0.2).spacing_(0.2));
	var ctrlView = Fdef(\ctrlview).(view);
	var playview = Fdef(\playview).(view);
	var baseViewFunc = Fdef(\baseview).(view);
	var scrollView = ScrollView(bounds:Rect(0,0,160,300));
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
		playview.(node);
	).margins_(2).spacing_(2));

	win.layout.add(scrollView);
	win = win.fixedSize_(Size(150, 170));
	baseview = baseViewFunc.(win, node.key, 150, 170);
	baseview.front;
});
//Fdef(\ngui).(~nij);
)

