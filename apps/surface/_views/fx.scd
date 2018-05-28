(
view: {arg name, envir, config, util;

	var mainView, horizontalView, inputs, controls, eq;
	var height = 20;
	var filterSlot = 100;
	var func = {

		var func = config[\func];
		if ( func.argNames[0] == \self ) {
			func = config[\func].value(config);
		};
		func;
	};

	envir[name] = NodeProxy.audio(s, 2);
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

	eq = util[\eqView].(name, envir[name], envir, mainView;);
	inputs = util[\multiInputsView].(envir[name], mainView);
	controls = util[\specsView].(name, config[\specs], envir[name], envir, mainView);

	horizontalView = View().layout_(HLayout().margins_(2).spacing_(2));
	horizontalView.layout.add(controls);

	// main
	mainView.layout.add(util[\playView].(name, envir[name], mainView));
	mainView.layout.add(inputs);
	mainView.layout.add(eq);
	mainView.layout.add(horizontalView);

	mainView;
};
)
