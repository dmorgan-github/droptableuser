(
view: {arg objName, envir, util;

	var buf;
	var navView;
	var synth, player;
	var height = 20;
	var width = 300;

	// Node
	var node = NodeProxy.audio.source_({

		var lo = \lo.kr(0);
		var hi = \hi.kr(1);
		var rate = \rate.kr(1);
		var buf = \buf.kr(0);
		var phasor = Phasor.ar(0, BufRateScale.kr(buf) * rate, lo, hi);
		var sig = BufRd.ar(buf.numChannels, buf, phasor);
		Pan2.ar(sig, \pan.kr(0));
	});

	var view = View().layout_(VLayout().margins_(2).spacing_(2))
	.onClose_({
		node.clear;
		node = nil;
	});

	var controlsView = {

		var myView = View().layout_(HLayout().margins_(2).spacing_(2));
		var dragSink, button;

		button = Button()
		.fixedSize_(8)
		.states_([ ["x"] ])
		.font_(Font().size_(9))
		.action_({
			dragSink.string = "";
			button.enabled = false;
		})
		.enabled_(false);

		dragSink = DragSink()
		.string_("<-  ")
		.background_(Color.clear)
		.canReceiveDragHandler_({
			var obj = View.currentDrag;
			var bufnum = obj[\bufnum];
			(bufnum.isNil.not);
		})
		.receiveDragHandler_({arg v;

			var obj = View.currentDrag.value;
			var bufnum = obj[\bufnum];
			var name = obj[\name];

			if (bufnum.isNil.not) {

				var buf = s.cachedBufferAt(bufnum);
				buf.loadToFloatArray(action:{arg a;
					{
						sfv.setData(a, channels: buf.numChannels);
						sfv.setSelection (0, [0, buf.numFrames]);
						node.set(\buf, buf.bufnum);
						sfv.mouseUpAction.value(sfv);
					}.defer
				});

				v.string = name;
				button.enabled = true;
			} {
				var msg = "bufnum % doesn't exist in environment".format(bufnum);
				NotificationCenter.notify(view, \status, msg);
				button.enabled = false;
			}
		})
		.maxHeight_(35)
		.minWidth_(35);

		myView.layout.add(dragSink, button);
		myView;
	};

	var specs = (
		pan: [-1,1,\lin,0,0],
		rate: [0,4,\lin,0,1]
	);

	var playView = util[\playView].(objName, node, view);
	var specsView = util[\specsView].(objName, specs, node, envir, view);

	var sfv = SoundFileView()
	.background_(Color.gray(0.3))
	.timeCursorOn_(true)
	.gridOn_(true)
	.resize_(5)
	.gridResolution_(0.0)
	.fixedSize_(width@75)
	.mouseUpAction = ({arg view;
		var loFrames, hiFrames;
		loFrames = view.selection(0)[0];
		hiFrames = view.selection(0)[1] + loFrames;
		node.set(\lo, loFrames, \hi, hiFrames);
		//status.string_("pos : " ++ loFrames.asString ++ " : " ++ hiFrames.asString);
	});
	sfv.setSelectionColor(0, Color.blue(alpha:0.5));

	view.layout.add(playView);
	view.layout.add(controlsView.());
	view.layout.add(sfv);
	view.layout.add(specsView);

	envir[objName] = node;

	view.onClose_({
		envir[objName].clear(envir[objName].fadeTime);
		{
			"destroy: ".debug(objName);
			envir[objName] = nil;
		}.defer(envir[objName].fadeTime + 1);
	});
};
)


