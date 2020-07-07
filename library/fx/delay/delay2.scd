(
view: {arg objName, envir, components;

	var node = NodeProxy.audio(s, 2)
	.filter(100, {arg sig_in;
		var cutoff = 20;
		var sig = HPF.ar(sig_in.sum, cutoff) * \input.ar(1);
		var fbNode1 = FbNode(1, 1, 4);
		var fbNode2 = FbNode(1, 1, 4);
		var fb1del = \timeL.kr(10) * 16.reciprocal;
		var fb2del = \timeR.kr(6) * 16.reciprocal;
		var spread = \spread.kr(1);
		var fbl = \fbL.kr(0.3);
		var fbr = \fbR.kr(0.3);
		var crossl = \crossL.kr(0.1);
		var crossr = \crossR.kr(0.1);

		var sig1 = [
			sig,
			(fbNode1.delay(fb1del) * fbl),
			(fbNode2.delay(fb2del) * crossl)
		].sum;

		var sig2 = [
			sig,
			(fbNode1.delay(fb1del) * crossr),
			(fbNode2.delay(fb2del) * fbr)
		].sum;

		fbNode1.write(sig1);
		fbNode2.write(sig2);

		sig = Pan2.ar(sig1, spread.neg) + Pan2.ar(sig2, spread);
		sig * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
	});

	var specs = [
		\pan -> [-1,1,\lin,0,0],
		\amp -> [0,4,\lin,0,1],
		\input -> [0, 10, \lin, 0, 1],
		\spread -> [0, 1, \lin, 0, 1],
		\fbL -> [0, 1, \lin, 0, 0.3],
		\fbR -> [0, 1, \lin, 0, 0.3],
		\crossL -> [0, 1, \lin, 0, 0.1],
		\crossR -> [0, 1, \lin, 0, 0.1]
	];

	var view = View().layout_(VLayout());
	var specsView = components[\specsView].(objName, specs, node, envir, view);
	var buttonsL = 16.collect({arg i;
		Button()
		.maxSize_(20)
		.states_([ [i+1, nil, Color.grey], [i+1, nil, Color.blue] ])
		.action_({arg ctrl;
			buttonsL.do({arg btn, j;
				if (j != i){
					btn.value = 0;
				};
			});
			if (ctrl.value == 1) {
				node.set(\timeL, i+1)
			}
		})
		.value_(if (i == 5) {1}{0})
	});
	var buttonsR = 16.collect({arg i;
		Button()
		.maxSize_(20)
		.states_([ [i+1, nil, Color.grey], [i+1, nil, Color.blue] ])
		.action_({arg ctrl;
			buttonsR.do({arg btn, j;
				if (j != i){
					btn.value = 0;
				};
			});
			if (ctrl.value == 1) {
				node.set(\timeR, i+1)
			}
		})
		.value_(if (i == 9) {1}{0})
	});
	var timesL = 4.collect({arg i;
		buttonsL[(i*4)..(4*(i+1)-1)]
	});
	var timesR = 4.collect({arg i;
		buttonsR[(i*4)..(4*(i+1)-1)]
	});
	var delayView = View().layout_(HLayout(
		GridLayout.rows(*timesL),
		StaticText().background_(Color.black).maxWidth_(1),
		GridLayout.rows(*timesR),
	).margins_(2).spacing_(2));

	view.layout.add(delayView);
	view.layout.add(specsView);

	envir[objName] = node;

	NotificationCenter.register(view, \close, view, {arg msg;
		msg.debug("clean up");
		// not sure why this needs to be deferred
		// otherwise it crashes the server
	});

	view;
}
)