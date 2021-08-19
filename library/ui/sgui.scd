(
Require(App.librarydir ++ "ui/common.scd");
Fdef(\sgui, {|node|

    var height = 19;
    var skipId = UniqueID.next.asSymbol;
    var keys;
    var connections;

    var getKeys = {
        node.envir.keys
        .select({|key|
            node.get(key).isNumber
        })
        .reject({|key|
            [\gate, \trig, \out, \in].includes(key)
        }).asArray
        .sort({|a, b|
            //"%%".format(node.getSpec[a].units, a) < "%%".format(node.getSpec[b].units, b)
            a < b
        })
    };

    var getSpec = {|key|
        var specs = node.getSpec;
        var spec = specs[key];
        if (spec.isNil) {
            spec = [0, 1, \lin, 0, 0].asSpec;
        };
        spec
    };

    var getView = {

        var controls, sliders, numbers, ctrls, view;

        keys = getKeys.();

        controls = keys.collect({|key|
            var val = node.get(key);
            var spec = getSpec.(key);
            if (val.isNil) {
                val = spec.default;
            };
            NumericControlValue(val, spec:spec)
        });

        sliders = keys.collect({|key, i|
            Slider()
            .maxHeight_(height)
            .value_(controls[i].input)
            .orientation_(\horizontal)
            .thumbSize_(10)
        });

        numbers = keys.collect({|key, i|
            var hi = controls[i].spec.maxval;
            var lo = controls[i].spec.minval;
            NumberBox().clipHi_(hi).clipLo_(lo)
            .maxHeight_(height)
            .maxWidth_(80)
        });

        ctrls = keys.collect({|key, i|
            HLayout(
                StaticText().fixedWidth_(50).string_(key).toolTip_(key),
                sliders[i],
                numbers[i]
            )
        });

        view = View().layout_(VLayout(*ctrls).margins_(5).spacing_(2)).background_(Color.rand.alpha_(0.3));

        connections = ConnectionList.make {
            controls.connectEach(\input, sliders, _.valueSlot);
            controls.connectEach(\value, numbers, _.valueSlot);
            sliders.connectEach(\value, controls, _.inputSlot);
            numbers.connectEach(\value, controls, _.valueSlot);

            controls.do({|ctrl, i|
                ctrl.connectTo({|ctrl, slot, mapped, val|
                    var key = keys[i];
                    node.set(key, mapped);
                })
            });

            node.signal(\set).connectTo({|obj, operation, val|
                val.pairsDo({|k, v|
                    var index = keys.indexOf(k);
                    if (index.notNil) {
                        controls[index].value = v;
                    }
                })
            });
        };

        view.layout.add(nil);
        view
    };

    var view = View(bounds:220@200).layout_(VLayout().margins_(4).spacing_(4)).name_(node.key);
    var scroll = ScrollView();
    scroll.canvas = getView.();

    view.layout.add(scroll);
    view.layout.add(HLayout(
        Button().states_([ [">"], [ "[]" ] ]).action_({|ctrl|
            if (ctrl.value == 1) {
                node.play
            }{
                node.stop
            }
        })
        .value_(node.isPlaying),
        nil
    ));

    SkipJack({
        var prev = keys.size;
        var new = getKeys.().size;
        if (prev != new) {
            connections.free;
            scroll.canvas = getView.();
        }
    }, name: skipId);

    view.onClose_({
        connections.free;
        SkipJack.stop(skipId)
    })
    .front;

    /*
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
    */
});
)
