(
view: {arg name, envir, config, util;

	var view, subview, presets;
	var font = Font("Courrier New", 10);
	var height = 20;
	var status = StaticText().font_(font).string_("");

	envir[name] = NodeProxy.control;
	envir[name].fadeTime = 1;
	envir[name][0] = config[\func];

	view = View().layout_(VLayout().margins_(2).spacing_(2))
	.onClose_({
		envir[name].clear;
		envir[name] = nil;
	});
	view.layout.add(HLayout(
		StaticText().string_(name).font_(font),
		Button()
		.fixedSize_(30@height)
		.font_(font)
		.string_("doc")
		.mouseDownAction_({arg ctrl; envir[name].document; })
	));

	presets = util[\presetsView].(envir[name], config, view);
	subview = util[\specsView].(config[\specs], envir[name], envir, view, status);

	view.layout.add(presets);
	view.layout.add(subview);
	view.layout.add(status);
	view;
};
)

