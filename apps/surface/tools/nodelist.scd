(
view: {arg objName, envir, util;

	var view = View().layout_(VLayout().spacing_(2).margins_(2));
	var nodes = ();

	var check = {

		envir.sortedKeysValuesDo({arg k,v;

			if (v.class == NodeProxy) {

				if (nodes[k] == nil) {
					nodes[k] = v;

					view.layout.add(HLayout(

						StaticText().string_(k),
						DragSource()
						.background_(Color.clear)
						.object_((node:v,name:k))
						.string_("-->")
						.maxWidth_(30)
						.minWidth_(30)
						.align_(\right)
					).spacing_(2).margins_(2));
				}
			}
		});
	};

	AppClock.sched(60, {
		check.();
		60;
	});

	check.();
	view;
}
)
