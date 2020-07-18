(
Require("~/projects/droptableuser/library/ui/common.scd");
Fdef(\launch, {

	//var win = Window.new("launch", bounds:Rect(0, 500, width:100, height:100), border:false);
	var view = View().layout_(VLayout());
	var baseview;
	var baseViewFunc = Fdef(\baseview);
	var pdefs = Pdef.all.keys.asArray
	.sort
	.reject({arg k; k.asString.contains("_set")})
	.collect({arg k; Pdef(k)});

	var buttons = List.new;
	var currentrow = nil;
	var lastkey = "";
	pdefs.do({arg pdef, i;
		var key = pdef.key;
		var color = Color.rand;
		if (key.asString.beginsWith(lastkey).not) {
			lastkey = key.asString.split($_)[0];
			currentrow = List.new;
			buttons.add(currentrow);
		};
		currentrow.add(Button()
			.states_([ [key, nil, color.alpha_(0.2)], [key, nil, color.copy.alpha_(1)] ])
			.action_({arg ctrl;
				if (ctrl.value == 1) {
					pdef.play;
				}{
					pdef.stop;
				}
			})
			.minHeight_(25)
			.value_(pdef.isPlaying)
		);
	});

	view.layout.add(GridLayout.rows(*buttons).margins_(0).spacing_(0));
	baseview = baseViewFunc.(view, "launch");
	baseview.front;
})
)
