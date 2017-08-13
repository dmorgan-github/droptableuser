(
view: {arg name, envir, config, util;

	var mainView, horizontalView, inputs, controls, presets;
	var font = Font("Courrier New", 10);
	var height = 20;
	var status = StaticText().font_(font).string_("");
	var filterSlot = 100;

	var inputsView = {arg node;

		var view = View().layout_(VLayout().margins_(2).spacing_(2)).background_(Color.rand);

		4.do({arg i;

			view.layout.add(
				HLayout(
					TextField()
					.fixedSize_(60@height)
					.font_(font)
					.action_({arg ctrl;
						var val = ctrl.value;
						if ( envir[val.asSymbol].isNil) {
							var msg = "node " + val + " does not exit";
							status.string_("node " + val + " does not exit");
							msg.error;
						} {
							node[i] = { envir[val.asSymbol].ar * (\vol_ ++ i).asSymbol.kr(1) };
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
	envir[name][filterSlot] = \filter -> config[\func];
	mainView = View().layout_(VLayout().margins_(2).spacing_(2))
	.onClose_({
		envir[name].clear;
		envir[name] = nil;
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