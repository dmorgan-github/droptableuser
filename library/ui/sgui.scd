(
Require(App.librarydir ++ "ui/common.scd");
Fdef(\sgui, {arg synth;

	var win, nodeListener;
	var view = View()
	.layout_(VLayout().margins_(0.5).spacing_(0.5));

	var baseview;
	var ctrlView = Fdef(\ctrlview);
	var baseViewFunc = Fdef(\baseview);
	var playview = Fdef(\playview);
	var presetsview = Fdef(\presetsview);
	var specs = Halo.at(synth, \spec);

	var scrollView = ScrollView();
	var cb = {arg key, val;
		synth.set(key, val)
	};

	var ctrlViews = ();

	playview = playview.(synth.node);//.addDependant(viewListener);
	presetsview = presetsview.(synth, {|num|
		var preset = synth.getPreset(num);
		if (preset.isNil) {
			synth.addPreset(num);
		} {
			synth.loadPreset(num);
		}
	});

	{
		var groups = ();
		var specgroups;
		specs.do({arg val; groups[val.asSpec.units.asSymbol] = 1});
		specgroups = groups.keys.asSortedList.collect({arg group;
			var returnval = List.new;
			specs.keysValuesDo({arg k, v;
				if (v.units == group.asString) {
					returnval.add(k -> v);
				}
			});
			returnval.quickSort({arg a, b; a.key < b.key})
		});

		specgroups.do({arg val;
			val.do({arg assoc;
				var k = assoc.key;
				var v = assoc.value;
				var ctrl = ctrlView.(k, v.asSpec, Color.rand, synth.get(k), cb, synth);
				ctrlViews[k] = ctrl;
				view.layout.add(ctrl.asView);
			});
		});

	}.();

	view.layout.add(nil);
	scrollView.canvas = view.background_(Color.clear);
	presetsview = presetsview.();
	playview = playview.(synth.node);//.addDependant(viewListener);

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
	synth.addDependant(nodeListener);

	win = View().layout_(VLayout(
		presetsview,
		playview
	).margins_(2).spacing_(2));

	win.layout.add(scrollView);
	win = win.fixedSize_(Size(150, 170)).onClose_({
		synth.removeDependant(nodeListener);
	});

	baseview = baseViewFunc.(win, synth.key, 150, 170);
	baseview.front;
});
)
