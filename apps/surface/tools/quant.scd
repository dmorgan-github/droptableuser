(
view: {arg name, envir, util;

	var node = NodeProxy.control;
	var view = View().layout_(VLayout().margins_(2).spacing_(2)).onClose_({
		envir[name].free;
		envir[name].clear;
		envir[name] = nil;
		"destroy: ".debug(name);
	});
	var grid = View().layout_(GridLayout().margins_(2).spacing_(2));

	var scale_keys = FloatArray[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
	//var scale = Buffer.alloc(s, 12);

	node[0] = {
		var trig = \trig.kr;
		DC.kr(0);
	};
	envir[name] = node;

	view.layout.add(
		PopUpMenu()
		.mouseDownAction_({arg ctrl;
			var result = util[\getProxyList].(envir, node, \trig);
			ctrl.items_([""] ++ result);
		})
		.action_({arg ctrl;

			var val = ctrl.item.asString;
			var split = val.split($:);
			var name = split[0];

			if (name.isNil or: (name == "") ) {
				envir[name].unset(\trig)
			} {
				var trig, name;
				val = val.asSymbol;
				trig = envir[val];
				if (trig.isNil.not) {
					envir[name].set(\trig, trig);
				}
			};
		});
	);

	12.reverseDo({arg i;

		var color = Color.white;
		if ( [1,3,6,8,10].includes(i) ) {
			color = Color.black;
		};
		grid.layout.add(Button().states_([ ["", nil, color] ]).maxWidth_(45).maxHeight_(20).enabled_(false), i, 0);
		grid.layout.add(
			Button()
			.states_([ [], ["", nil, Color.green] ])
			.maxWidth_(10)
			.maxHeight_(20)
			.action_({arg ctrl;

				var index = 11-i;
				var result;
				if (ctrl.value == 1) {
					scale_keys[index] = index;
				} {
					scale_keys[index] = -1;
				};
				result = scale_keys.select({arg val; val > -1});
				[index, i, scale_keys, result].postln;
			}),
			i, 1);
	});

	view.layout.add(grid);
	view;
};
)


//12.reverseDo({arg i;i.postln;})