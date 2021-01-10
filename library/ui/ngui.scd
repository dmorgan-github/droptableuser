(
Require(App.librarydir ++ "ui/common.scd");
Fdef(\ngui, {arg node, customview;

	var baseview, nodeListener;
	var win;
	var view = View().layout_(VLayout().margins_(0.2).spacing_(0.2));
	var ctrlView = Fdef(\ctrlview);
	var playview = Fdef(\playview);
	var presetsview = Fdef(\presetsview);
	var baseViewFunc = Fdef(\baseview);
	var scrollView = ScrollView();
	var cb = {arg key, val;
		node.set(key, val)
	};
	var viewListener = {arg obj, key, val;
		win.changed(key, val);
	};
	var ctrlViews = ();

	var getSpecs = {
		var specs = ();
		node.getSettings.keysValuesDo({|k, v|
			specs[k.asSymbol] = node.getSpec(k.asSymbol) ?? { ControlSpec(0, 1, \lin, 0, 0) };
		});
		specs;
	};

	var getSpecGroups = {

		var specs = getSpecs.();
		var groups = ();
		var specgroups;

		specs.do({arg val;
			var key = val.asSpec.units ?? {""};
			groups[key] = 1
		});

		specgroups = groups.keys.asSortedList.collect({arg group;

			var returnval = List.new;
			specs.keysValuesDo({arg k, v;
				if (v.units.asString == group.asString) {
					returnval.add(k -> v);
				}
			});
			returnval.quickSort({arg a, b; a.key < b.key});
		});
		specgroups.flatten;
	};

	if (node.respondsTo(\editor)) {
		view.layout.add(Button().states_([ ["vst"] ]).action_({ node.editor }) );
	};

	getSpecGroups.().do({arg assoc;
		var k = assoc.key;
		var v = assoc.value;
		var val = node.getSettings[k.asSymbol];
		var ctrl = ctrlView.(k, v.asSpec, Color.rand, val, cb);
		ctrlViews[k] = ctrl;
		view.layout.add(ctrl.asView.minHeight_(20).maxHeight_(20));
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
							{v.setValue(val)}.defer(0.001)
						}
					}
				}
			});
		}
	};
	node.addDependant(nodeListener);

	win = View().layout_(VLayout(
		playview,
		customview, // this can be nil
		scrollView,
		nil
	)
	.margins_(2)
	.spacing_(2))
	.onClose_({
		\onclose.debug(node.key);
		playview.removeDependant(viewListener);
		node.removeDependant(nodeListener);
	});

	baseview = baseViewFunc.(win, node.key, 150, 170);
	baseview.front;
});
)

