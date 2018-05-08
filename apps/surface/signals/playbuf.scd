(
view: {arg objName, envir, util;

	var view = View().layout_(VLayout().spacing_(2).margins_(2));
	var specs;
	var playView, specsView;

	var node = NodeProxy.audio(s, 2).source_({
		var buf = \buf.kr();
		var sig = PlayBufCF.ar(1, buf, rate:\rate.kr(1), trigger:1, startPos:0, loop:1);
		var env = Env.asr.kr(gate:1);
		Splay.ar(sig) * env
	});

	specs = (
		rate: [0.1, 4, \lin, 0, 1]
	);

	envir[objName] = node;
	playView = util[\playView].(objName, node, view);
	specsView = util[\specsView].(objName, specs, node, envir, view);

	view.layout.add(playView);
	view.layout.add(NumberBox().action_({arg ctrl;
		node.set(\buf, 60);
	}).normalColor_(Color.white));
	view.layout.add(specsView);
	view;
}
)