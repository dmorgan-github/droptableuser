(
Require("~/projects/droptableuser/library/ui/common.scd");
Fdef(\scope, {arg node;

	var baseview;
	var key = node.key;
	var win = Window.new(key, bounds:Rect(width:200, height:200));
	var view = View().layout_(VLayout().margins_(0).spacing_(0)).palette_(QPalette.dark);
	var scope;
	win.layout = HLayout(view).margins_(0).spacing_(0);
	scope = Stethoscope.new(s, view:view).style_(1).index_(node.bus.index).numChannels_(2);
	win.onClose = { scope.free };
	4.do({
		view.children[0].children[0].remove
	});
	view.children[0].children[0].waveColors_([Color.rand, Color.rand]);

	win = win.asView.fixedSize_(200@200);

	baseview = Fdef(\baseview).(win, key);
	baseview.front;
})
)
