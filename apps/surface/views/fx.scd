(
view: {arg name, envir, config, util;

	var mainView, horizontalView, inputs, controls, presets;
	var font = Font("Courrier New", 10);
	var height = 20;
	var status = StaticText().font_(font).string_("");
	var filterSlot = 100;
	var func = {

		var func = config[\func];
		if ( func.argNames[0] == \self ) {
			func = config[\func].value(config);
		};
		func;
	};

	var inputsView = {arg node;

		var view = View().layout_(VLayout().margins_(2).spacing_(2)).background_(Color.rand);

		4.do({arg i;

			view.layout.add(
				HLayout(
					PopUpMenu()
					.maxHeight_(height)
					.allowsReselection_(true)
					.mouseDownAction_({arg ctrl;

						var result = List.new;
						var list = envir.sortedKeysValuesDo({arg k,v;
							if (v.class == NodeProxy) {

								if (v.rate == \audio){
									result.add(k);
								}
							}
						});
						ctrl.items_([""] ++ result);
					})
					.font_(font)
					.action_({arg ctrl;

						var val = ctrl.item.asString;//ctrl.value;
						var split = val.split($:);
						var name = split[0];

						if (name.isNil or: (name == "") ) {
							node.removeAt(i, node.fadeTime);
						} {

							if ( envir[name.asSymbol].isNil) {
								var msg = "node " + name + " does not exit";
								status.string_("node " + name + " does not exit");
								msg.error;
							} {
								if (split.size > 1) {
									node[i] = { envir[name.asSymbol].ar[split[1].asInt] * (\vol_ ++ i).asSymbol.kr(1) };
								} {
									node[i] = { envir[name.asSymbol].ar * (\vol_ ++ i).asSymbol.kr(1) };
								};
							}
						}
					}),

					Slider()
					.fixedSize_(25@height).font_(font)
					.thumbSize_(10)
					.value_(1)
					.action_({arg ctrl;
						envir[name].set( (\vol_ ++ i).asSymbol, ctrl.value );
						status.string_("mix : " + ctrl.value.asString);
					});
				)
			, align:\top);
		});

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
	controls = util[\specsView].(config[\specs], envir[name], envir, mainView, status);
	presets = util[\presetsView].(envir[name], config, mainView);

	horizontalView = View().layout_(HLayout().margins_(2).spacing_(2));
	horizontalView.layout.add(inputs);
	horizontalView.layout.add(controls);

	// main
	mainView.layout.add(util[\playView].(name, envir[name], status));
	mainView.layout.add(presets);
	mainView.layout.add(horizontalView);
	mainView.layout.add(status);

	mainView;
};
)