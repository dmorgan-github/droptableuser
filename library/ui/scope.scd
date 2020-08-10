(
//https://doc.sccode.org/Classes/ScopeView.html
/*
Nice color combos
--
Color(0.36152021884918, 0.85237412452698, 0.45180509090424)
Color(0.40423951148987, 0.41675183773041, 0.33699252605438)
--

Color(0.83572676181793, 0.47834537029266, 0.51227059364319)
Color(0.69734115600586, 0.31087968349457, 0.53193626403809)

--
Color(0.60458264350891, 0.35867228507996, 0.43469803333282)
Color(0.74560611248016, 0.83032672405243, 0.84340102672577)

Color(0.46420955657959, 0.51552658081055, 0.39527049064636)
Color(0.86381542682648, 0.81877591609955, 0.88744733333588)

*/

Require("~/projects/droptableuser/library/ui/common.scd");
Fdef(\scope, {arg node;

	var view = View().layout_(VLayout().margins_(0).spacing_(0)).palette_(QPalette.dark);
	var baseViewFunc = Fdef(\baseview);
	var baseview;
	var key = node.key;
	var win = Window.new(key, bounds:Rect(width:200, height:200));
	var scope;
	win.layout = HLayout(view).margins_(0).spacing_(0);
	scope = Stethoscope.new(s, view:view).style_(1).index_(node.bus.index).numChannels_(2);
	win.onClose = { scope.free;  };
	4.do({
		view.children[0].children[0].remove
	});
	view.children[0].children[0].waveColors_([Color.rand.debug(\scope), Color.rand.debug(scope)]);

	win = win.asView.fixedSize_(Size(200,200));

	baseview = baseViewFunc.(win, key);
	baseview.front;
})
)
