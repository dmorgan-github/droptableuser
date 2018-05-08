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

		1.do({arg i;

			view.layout.add(
				HLayout(
					PopUpMenu()
					.maxHeight_(height * 0.8)
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
					.font_(Font().size_(8))
					.action_({arg ctrl;

						var val = ctrl.item.asString;
						var split = val.split($:);
						var name = val;//split[0];

						if (name.isNil or: (name == "") ) {
							node.removeAt(i, node.fadeTime);
						} {

							if ( envir[name.asSymbol].isNil) {
								var msg = "node " + name + " does not exit";
								NotificationCenter.notify(mainView, \status, msg);
								msg.error;
							} {

								if (i == 0) {
									node[i] = {
										var sig = envir[name.asSymbol].ar;
										sig = Pan2.ar(sig, (\pan_ ++ i).asSymbol.kr(-1));
										sig * (\vol_ ++ i).asSymbol.kr(1)
									};
								} //{
								//	node[i] = {
								//		var sig = envir[name.asSymbol].ar.wrapAt(1);
								//		sig = Pan2.ar(sig, (\pan_ ++ i).asSymbol.kr(1));
								//		sig * (\vol_ ++ i).asSymbol.kr(1)
								//	};
								//};
							}
						}
					}),

					Knob()
					.fixedWidth_(20)
					.fixedHeight_(20)
					.value_(1)
					.action_({arg ctrl;

					}),

					Knob()
					.fixedWidth_(20)
					.fixedHeight_(20)
					.value_([-1,1].wrapAt(i))
					.action_({arg ctrl;

					})

					/*

					Slider()
					.fixedSize_(25@height).font_(font)
					.thumbSize_(8)
					.value_(1)
					.action_({arg ctrl;
						envir[name].set( (\vol_ ++ i).asSymbol, ctrl.value );
						status.string_("vol : " + ctrl.value.asString);
					}),

					*/

					/*
					Slider()
					.orientation_(\horizontal)
					.fixedSize_(25@height).font_(font)
					.thumbSize_(8)
					.value_([0,1][i])
					.action_({arg ctrl;
						var val = ctrl.value.linlin(0,1,-1,1);
						envir[name].set( (\pan_ ++ i).asSymbol, val );
						status.string_("pan : " + val.asString);
					});
					*/
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
