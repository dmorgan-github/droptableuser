(
view: {arg name, envir;

	var node = NodeProxy.audio.quant_(1.0);
	var view = View().layout_(VLayout().margins_(2).spacing_(2));
	var height = 20;
	var status = StaticText().string_("");
	var textView;

	var mainView = {
		var view = View().layout_(VLayout().margins_(2).spacing_(2));
		textView = TextView()
		.fixedSize_(400@200)
		.enterInterpretsSelection_(false)
		.tabWidth_(4);

		view.layout.add(textView);
		view;
	};

	view.layout.add(

		HLayout(

			StaticText().string_(name),

			View().minWidth_(200),

			Button()
			.fixedSize_(30@height)
			.string_("eval")
			.action_({arg ctrl;

				//textView.string.postln;
				//var input = "play({ SinOsc.ar }, target: group, outbus: bus)";
				var input = textView.string;
				var wrap = "{arg group, bus; { " ++ input ++ " } }";
				var func = wrap.interpret;
				var result = func.(node.group, node.bus);
				node[0] = Task(result);
				textView.syntaxColorize;
			}),

			Button()
			.fixedSize_(30@height)
			.states_([ ["play"], ["stop"] ])
			.string_("play")
			.action_({arg ctrl;
				if (ctrl.value == 1) {
					node.play;
				} {
					node.stop;
				}
			}),

			Button()
			.fixedSize_(30@height)
			.string_("doc")
			.mouseDownAction_({arg ctrl; envir[name].document;})

		).margins_(2).spacing_(2)
	);

	envir[name] = node;
	view.layout.add(mainView.());
	view.layout.add(status);
	view.onClose_({
		envir[objName].clear(envir[objName].fadeTime);
		{
			"destroy: ".debug(objName);
			envir[objName] = nil;
		}.defer(envir[objName].fadeTime + 1);
	});
}
)//[\view].(\test, currentEnvironment).front;