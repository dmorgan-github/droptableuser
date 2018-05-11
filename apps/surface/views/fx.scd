(
view: {arg name, envir, config, util;

	var mainView, horizontalView, inputs, controls, presets;
	var height = 20;
	var filterSlot = 100;
	var func = {

		var func = config[\func];
		if ( func.argNames[0] == \self ) {
			func = config[\func].value(config);
		};
		func;
	};

	var inputsView = {arg node;

		var view = View().layout_(HLayout().margins_(2).spacing_(2)).background_(Color.rand);
		var dragSink, button;

		button = Button()
		.fixedSize_(8)
		.states_([ ["x"] ])
		.font_(Font().size_(9))
		.action_({
			dragSink.string = "";
			button.enabled = false;
		})
		.enabled_(false);

		dragSink = DragSink()
		.string_("<-  ")
		.background_(Color.clear)
		.canReceiveDragHandler_({
			var obj = View.currentDrag;
			var node = obj[\node];
			(node.rate == \audio);
		})
		.receiveDragHandler_({arg v;

			var obj = View.currentDrag.value;
			var input = obj[\node];
			var name = obj[\name];
			var msg = "inuput: " ++ name;
			v.string = name;

			node[0] = {
				var sig = input.ar;
				sig * \vol.kr(1)
			};

			NotificationCenter.notify(mainView, \status, msg);
		})
		.maxHeight_(35)
		.minWidth_(35);

		view.layout.add(
			HLayout(dragSink, button,nil)
		);

		view;
	};

	envir[name] = NodeProxy.audio;
	envir[name].fadeTime = 1;

	config[\init].value(config);
	envir[name][filterSlot] = \filter -> func.value;
	mainView = View().layout_(VLayout().margins_(2).spacing_(2))
	.onClose_({
		envir[name].clear(envir[name].fadeTime);
		{
			"destroy: ".debug(name);
			config[\destroy].value(config);
			envir[name] = nil;
		}.defer(envir[name].fadeTime + 1);
	});

	inputs = inputsView.(envir[name]);
	controls = util[\specsView].(name, config[\specs], envir[name], envir, mainView);
	presets = util[\presetsView].(envir[name], config, mainView);

	horizontalView = View().layout_(HLayout().margins_(2).spacing_(2));
	horizontalView.layout.add(controls);

	// main
	mainView.layout.add(util[\playView].(name, envir[name], mainView));
	mainView.layout.add(presets);
	mainView.layout.add(inputs);
	mainView.layout.add(horizontalView);

	mainView;
};
)
