(
view:{arg objName, envir, util;

	var node = NodeProxy.audio(s, 2)
	.filter(100, {arg in;

		var input = Mix.ar(in);
		var buf = \buf.kr(0);
		var reset = \reset.tr;
		var rec = \rec.kr(0);
		var rate = \rate.kr(1);
		var sig, recHead;

		recHead = Phasor.ar(reset, BufRateScale.kr(buf) * rate, 0, BufFrames.kr(buf));
		sig = BufRd.ar(1, buf, recHead);
		BufWr.ar((input * rec) + sig, buf, recHead);

		Pan2.ar(sig, \pan.kr(0));
	});

	var specs = (
		pan: [-1,1,\lin,0,0],
		rate: [0,4,\lin,0,1],
		buf: \set
	);

	var view = View().layout_(VLayout().spacing_(2).margins_(2));

	var playView = util[\playView].(objName, node, view);

	var multiInputsView = util[\multiInputsView].(node, view);

	var specsView = util[\specsView].(objName, specs, node, envir, view);

	var recView = View().layout_(HLayout(
		Button().states_([ ["rec", nil, nil], ["stop",nil,nil] ])
		.action_({arg ctrl;
			if (ctrl.value == 1) {
				node.set(\rec, 1);
				NotificationCenter.notify(view, \status, "rec enabled");
			} {
				node.set(\rec, 0);
				NotificationCenter.notify(view, \status, "rec disabled");
			}
		}),
		Button().string_("reset").action_({arg ctrl;
			node.set(\reset, 0);
			node.set(\reset, 1);
			NotificationCenter.notify(view, \status, "reset");

		})
	).spacing_(2).margins_(2));

	view.layout.add(playView);
	view.layout.add(multiInputsView);
	view.layout.add(recView);
	view.layout.add(specsView);

	envir[objName] = node;

	view.onClose_({
		envir[objName].clear(envir[objName].fadeTime);
		{
			"destroy: ".debug(objName);
			envir[objName] = nil;
		}.defer(envir[objName].fadeTime + 1);
	});
}
)