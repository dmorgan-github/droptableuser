(
view: {arg name, envir;

	var buf;
	var navView, sfv;
	var synth, player;
	var font = Font("Courrier New", 10);
	var status = StaticText().font_(font).string_("");
	var height = 20;
	var width = 300;
	var controlsView;
	var view = View().layout_(VLayout().margins_(2).spacing_(2))
	.onClose_({
		envir[name].clear;
		envir[name] = nil;
	});

	view.layout.add(StaticText().string_(name).font_(font));

	controlsView = {

		var view = View().layout_(HLayout().margins_(2).spacing_(2));
		view.layout.add(Button()
			.fixedSize_(30@height)
			.font_(font)
			.states_([ ["open"] ])
			.action_({arg ctrl;
				buf = Buffer.loadDialog(s, action:{
					buf.loadToFloatArray(action:{arg a;
						{
							sfv.setData(a, channels: buf.numChannels);
							sfv.setSelection (0, [0, buf.numFrames]);
							envir[name].set(\buf, buf.bufnum);
							sfv.mouseUpAction.value(sfv);
						}.defer
					});
				});
			})
		);

		view.layout.add(

			Slider()
			.orientation_(\horizontal)
			.thumbSize_(10)
			.fixedSize_(50@height)
			.font_(font)
			.value_(1.linlin(0.1, 8, 0, 1))
			.action_({arg ctrl;
				var val = ctrl.value.linlin(0, 1, 0.1, 8);
				envir[name].fadeTime = val;
				status.string_("fadetime: " ++ val.asString);
			})
		);

		view.layout.add(
			Button()
			.fixedSize_(30@height)
			.states_([ ["play"], ["stop"] ])
			.font_(font)
			.string_("play")
			.action_({arg ctrl;
				if (ctrl.value == 1) {
					envir[name].play;
				} {
					envir[name].stop;
				}
			})
		);

		view.layout.add(View().minWidth_(width*0.8));
		view;
	};

	sfv = SoundFileView()
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
		envir[name].set(\lo, loFrames, \hi, hiFrames);
		status.string_("pos : " ++ loFrames.asString ++ " : " ++ hiFrames.asString);
	});
	sfv.setSelectionColor(0, Color.blue(alpha:0.5));

	// Node
	envir[name] = NodeProxy.audio;
	envir[name].fadeTime = 1;
	envir[name][0] = {

		var lo = \lo.kr(0);
		var hi = \hi.kr(1);
		var rate = \rate.kr(1);
		var buf = \buf.kr(0);
		var phasor = Phasor.ar(0, BufRateScale.kr(buf) * rate, lo, hi);
		var sig = BufRd.ar(buf.numChannels, buf, phasor);
		Pan2.ar(sig, 0);
	};

	view.layout.add(controlsView.());
	view.layout.add(sfv);
	view.layout.add(Slider()
		.orientation_(\horizontal)
		.fixedSize_(300@height)
		.action_({arg ctrl;
			var val = ctrl.value.linlin(0,1,0.1,4);
			envir[name].set(\rate, val);
		})
		.value_(1.linlin(0.1,4,0,1))
	);
	view.layout.add(status);
	view;
};
)


