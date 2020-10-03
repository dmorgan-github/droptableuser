(

/*
SendPeakRMS
*/

Require("~/projects/droptableuser/library/ui/common.scd");
Fdef(\sgui, {arg synth;

	var view = View()
	.layout_(VLayout().margins_(0.5).spacing_(0.5));

	var baseview;
	var ctrlView = Fdef(\ctrlview);
	var baseViewFunc = Fdef(\baseview);
	var playview = Fdef(\playview);
	var specs = Halo.at(synth, \spec);

	var scrollView = ScrollView();
	var cb = {arg key, val;
		synth.set(key, val)
	};

	playview = playview.(synth.node);//.addDependant(viewListener);
	view.layout.add(playview);

	{
		// bit of a hack since the specs are configured
		// in a dictionary which doesn't retain order
		// so, we can overload the units prop of a controlspec
		// as a way to gruop related controls together
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
				var ctrl = ctrlView.(k, v.asSpec, Color.rand, synth.get(k), cb);
				view.layout.add(ctrl);
			});
		});

	}.();

	view.layout.add(nil);
	view.onClose_({
		//watcher.debug(\free);
		//watcher.free;
	});
	scrollView.canvas = view.background_(Color.clear);
	scrollView.fixedSize = Size(150, 175);

	baseview = baseViewFunc.(scrollView, synth.key, 150, 175);
	baseview.front;
});
//Fdef(\sgui).(~etf);
)
