(
Require("~/projects/droptableuser/library/ui/common.scd");
Fdef(\ngui, {arg node;

	var baseview, nodeListener;
	var win;
	var view = View().layout_(VLayout().margins_(0.2).spacing_(0.2));
	var ctrlView = Fdef(\ctrlview);
	var playview = Fdef(\playview);
	var presetsview = Fdef(\presetsview);
	var baseViewFunc = Fdef(\baseview);
	var scrollView = ScrollView(bounds:Rect(0,0,160,300));
	var cb = {arg key, val;
		node.set(key, val)
	};
	var viewListener = {arg obj, key, val;
		win.changed(key, val);
	};
	var ctrlViews = ();

	if (node.respondsTo(\editor)) {
		view.layout.add(Button().states_([ ["vst"] ]).action_({ node.editor }) );
	};

	node.controlNames.do({arg cn;
		var k = cn.name;
		var v = node.getSpec(k) ? [0, 1, \lin, 0, 1];
		var val = node.get(k);
		var ctrl = ctrlView.(k, v.asSpec, Color.rand, val, cb);
		ctrlViews[k] = ctrl;
		view.layout.add(ctrl.asView);
		//view.layout.add(ctrl);
	});

	view.layout.add(nil);
	scrollView.canvas = view.background_(Color.clear);
	presetsview = presetsview.();
	playview = playview.(node).addDependant(viewListener);

	nodeListener = {|obj, op, pairs|
		if (op == \set) {
			var vals = pairs.flatten;
			vals.doAdjacentPairs({|key, val|
				if (val.isNumber) {
					var v = ctrlViews[key];
					if (v.isNil.not) {
						var current = v.getValue();
						if (current != val) {
							v.setValue(val);
						}
					}
				}
			});
		}
	};
	node.addDependant(nodeListener);

	win = View().layout_(VLayout(
		presetsview,
		playview
	).margins_(2).spacing_(2));

	win.layout.add(scrollView);
	win.layout.add(nil);
	win = win
	.fixedSize_(Size(150, 170))
	.onClose_({
		playview.removeDependant(viewListener);
		node.removeDependant(nodeListener);
	});
	baseview = baseViewFunc.(win, node.key, 150, 170);
	baseview.front;
});
)

