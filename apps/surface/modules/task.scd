(
view: {arg name, envir;

	var node = NodeProxy.audio.quant_(1.0);
	var view = View().layout_(VLayout().margins_(2).spacing_(2));
	var font = Font("Courrier New", 10);
	var height = 20;
	var status = StaticText().font_(font).string_("");
	var textView;

	var mainView = {
		var view = View().layout_(VLayout().margins_(2).spacing_(2));
		textView = TextView()
		.fixedSize_(400@200)
		.font_(font)
		.enterInterpretsSelection_(false)
		.tabWidth_(4);

		view.layout.add(textView);
		view;
	};

	view.layout.add(

		HLayout(

			StaticText().string_(name).font_(font),

			View().minWidth_(200),

			Button()
			.fixedSize_(30@height)
			.string_("eval")
			.font_(font)
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
			.font_(font)
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
			.font_(font)
			.string_("doc")
			.mouseDownAction_({arg ctrl; envir[name].document;})

		).margins_(2).spacing_(2)
	);

	envir[name] = node;
	view.layout.add(mainView.());
	view.layout.add(status);
	view;
}
)//[\view].(\test, currentEnvironment).front;