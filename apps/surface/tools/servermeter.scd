(
view: {arg name, envir;

	var font = Font("Courrier new", 10);
	var view = View().layout_(VLayout().margins_(0).spacing_(0))
	.font_(font)
	.minWidth_(400)
	.minHeight_(245);

	var win = Window.new("Server Levels");
	var smv = ServerMeterView.new(s, win, 10@10, 2, 16);

	view.layout.add(StaticText()
		.string_(s.options.inDevice ++ " | " ++ s.options.outDevice)
		.maxHeight_(20));
	view.layout.add(smv.view);
	view;
}
)
//[\view].("", ()).front;


