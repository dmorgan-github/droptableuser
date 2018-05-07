(
view: {arg name, envir, config, util;

	var mainView, horizontalView, inputs, controls, presets;
	var font = Font("Courrier New", 10);
	var height = 20;
	var status = StaticText().font_(font).string_("");
	var filterSlot = 100;
	var func = {

		var func = config[\func];
		if (func.argNames.size() > 0) {
			if (func.argNames[0] == \self) {
				func = config[\func].value(config);
			}
		};
		func;
	};

	envir[name] = NodeProxy.audio;
	envir[name].fadeTime = 1;

	config[\init].value(config);
	envir[name][0] = func.value;
	mainView = View().layout_(VLayout().margins_(2).spacing_(2))
	.onClose_({
		envir[name].clear(envir[name].fadeTime);
		{
			"destroy: ".debug(name);
			config[\destroy].value(config);
			envir[name] = nil;
		}.defer(envir[name].fadeTime + 1);
	});

	controls = util[\specsView].(name, config[\specs], envir[name], envir, mainView, status);
	presets = util[\presetsView].(envir[name], config, mainView);

	horizontalView = View().layout_(HLayout().margins_(2).spacing_(2));
	horizontalView.layout.add(controls);

	// main
	mainView.layout.add(util[\playView].(name, envir[name], status));
	mainView.layout.add(presets);
	mainView.layout.add(horizontalView);
	mainView.layout.add(status);

	mainView;
};
)

