(
Require(App.librarydir ++ "ui/common.scd");
Fdef(\sgui, {arg synth;

	var win, nodeListener;
	var view = View()
	.layout_(VLayout().margins_(0).spacing_(0));

	var baseview;
	var ctrlView = Fdef(\ctrlview);
	var baseViewFunc = Fdef(\baseview);
	var playview = Fdef(\playview);
	var presetsview = Fdef(\presetsview);
	//var foo = Halo.at(synth, \spec);

    var specs = synth.envir.keys.collect({|key|
        var spec = synth.getSpec(key);
        if (spec.isNil) {
            spec = [0, 1].asSpec;
        };
        [key, spec]
    }).asArray.flatten.asDict;

	var scrollView = ScrollView();
	var cb = {arg key, val;
		synth.set(key, val)
	};

	var ctrlViews = ();
	playview = playview.(synth.node);//.addDependant(viewListener);

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
				var ctrl = ctrlView.(k, v.asSpec, QtGUI.palette.highlight, synth.get(k), cb, synth);
				ctrlViews[k] = ctrl;
				view.layout.add(ctrl.asView.maxHeight_(20));
			});
		});

	}.();

	view.layout.add(nil);
	scrollView.canvas = view;
	presetsview = presetsview.();
	playview = playview.(synth.node);

	nodeListener = {|obj, op, pairs|
		if (op == \set) {
			var vals = pairs.flatten;
			vals.doAdjacentPairs({|key, val|
				if (val.isNumber) {
					var v = ctrlViews[key];
					if (v.isNil.not) {
						var current = v.getValue();
						if (current != val) {
                            {
                                v.setValue(val);
                            }.defer
						}
					}
				}
			});
		}
	};
	synth.addDependant(nodeListener);

	win = View().layout_(VLayout(
		playview,
		scrollView
	)
	.margins_(2)
	.spacing_(2))
	.onClose_({
		\onclose.debug(synth.key);
		synth.removeDependant(nodeListener);
	});

	baseview = baseViewFunc.(win, synth.key, 150, 170);
	baseview.front;
});
)
