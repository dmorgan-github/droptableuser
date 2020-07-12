(
Require("~/projects/droptableuser/library/ui/common.scd");
Fdef(\launch, {

	//var win = Window.new("launch", bounds:Rect(0, 500, width:100, height:100), border:false);
	var view = View().layout_(VLayout());
	var baseview;
	var baseViewFunc = Fdef(\baseview).(view);
	var pdefs = Pdef.all.keys.asArray
	.sort
	.reject({arg k; k.asString.contains("_pset")})
	.collect({arg k; Pdef(k)});

	var buttons = List.new;
	var currentrow = nil;
	var lastkey = "";
	pdefs.do({arg pdef, i;
		var key = pdef.key;
		if (key.asString.beginsWith(lastkey).not) {
			lastkey = key.asString.split($_)[0];
			currentrow = List.new;
			buttons.add(currentrow);
		};
		currentrow.add(Button()
			.states_([ [key, nil, Color.gray], [key, nil, Color.blue] ])
			.action_({arg ctrl;
				if (ctrl.value == 1) {
					pdef.play;
				}{
					pdef.stop;
				}
			})
			.value_(pdef.isPlaying)
		);
	});

	view.layout.add(GridLayout.rows(*buttons));
	baseview = baseViewFunc.(view, "launch");
	baseview.front;
})
)
