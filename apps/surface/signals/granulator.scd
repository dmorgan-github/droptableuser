(
view: {arg name, envir, util;

	var buf;
	var windowSize = 1024;
	var envbuf = Buffer.sendCollection(s, Signal.hanningWindow(windowSize), 1);
	var node = NodeProxy.new;

	var onEnvChange = {arg val;

		case
		{val == "hann"} {
			envbuf.setn(0, Signal.hanningWindow(windowSize) );
		}
		{val == "hamming"} {
			envbuf.setn(0, Signal.hammingWindow(windowSize) );
		}
		{val == "welch"} {
			envbuf.setn(0, Signal.welchWindow(windowSize) );
		}
		{val == "rectangle"} {
			envbuf.setn(0, Signal.rectWindow(windowSize) );
		}
		{val == "perc"} {
			envbuf.setn(0, Env.perc.asSignal(windowSize) );
		}
		{val == "triangle"} {
			envbuf.setn(0, Env.triangle.asSignal(windowSize) );
		}
		{val == "blackman"} {

			var blackman = {arg size = 2048;

				var sig, alpha, a0, a1, a2;
				alpha = 0.16;
				sig = Signal.newClear(size);

				a0 = 0.5*(1-alpha);
				a1 = 0.5;
				a2 = alpha*0.5;

				sig.waveFill( { arg x, i; a0 - (a1*cos( (2*pi*x)/(size-1) ) ) + (a2*cos( (4*pi*x)/(size-1) ) )}, 0, size );
				sig;
			};

			envbuf.setn(0, blackman.(windowSize));
		}
	};

	var specs = (
		rate: [0.1, 200, \lin, 0, 1],
		graindur: [0.01, 8, \lin, 0, 0.5],
		pitch: [0.1, 4, \lin, 0, 1],
		pan: [-1, 1, \lin, 0, 0],
		pos: [0, 1, \lin, 0, 0],
		grainamp: [0.1,1,\lin, 0, 1],
		reverse: [0,1,\lin, 0, 0]
	);

	var view = {

		var main = View().layout_(VLayout().margins_(2).spacing_(2))
		.onClose_({
			node.clear;
			node = nil;
		});
		var soundFileView;
		var bufpath = StaticText().string_("");
		var bufdur = "";
		var height = 20;
		var status = StaticText().string_("");

		var menuView = {

			var view = View().layout_(HLayout().margins_(2).spacing_(2));
			view.layout.add(util[\playView].(name, node, main));

			view.layout.add(Button()
				.string_("open")
				.action_({
					Dialog.openPanel(
						okFunc: {arg path;

							var buffer;
							var soundFile = SoundFile.new;

							soundFile.openRead(path);
							buffer = Buffer.readChannel(s, path, channels: [0], action:{arg buf;
								AppClock.sched(0, {
									bufpath.string_(path ++ " (" ++ buf.duration.round(0.01) ++ " sec.)");
									nil;
								});
							});

							soundFileView.soundfile_(soundFile);
							soundFileView.read(0, soundFile.numFrames);
							node.set(\buf, buffer.bufnum);

							//specs[\pos] = ControlSpec(0, soundFile.numFrames);
							//soundFileView.mouseUpAction.value(soundFileView);
						},
						cancelFunc: {"cancelled"}
					);
				})
			);

			view;
		};

		var waveView = {
			var view = View().layout_(VLayout().margins_(2).spacing_(2));

			soundFileView = SoundFileView()
			.minHeight_(100)
			.background_(Color.gray(0.3));
			//.mouseUpAction = ({arg view;
			//	var loFrames, hiFrames, loSlider, hiSlider;
			//	loFrames = view.selection(0)[0];
			//	hiFrames = view.selection(0)[1] + loFrames;
			//	loSlider = specs[\pos].unmap(loFrames);
			//	hiSlider = specs[\pos].unmap(hiFrames);
				//2.do{centerPosSlider.setSpanActive(loSlider, hiSlider)}; // 2.do = hack...
			//});
			soundFileView.timeCursorOn = true;
			soundFileView.timeCursorColor = Color.blue(alpha:0.5);
			soundFileView.setSelectionColor(0, Color.blue(alpha:0.5));
			soundFileView.gridResolution = 0.0;

			view.layout.add(bufpath);
			view.layout.add(soundFileView);
			view;
		};

		main.layout.add(menuView.());
		main.layout.add(util[\presetsView].(node, (), main));
		main.layout.add(waveView.());

		main.layout.add(PopUpMenu()
			.items_(["hann", "hamming", "welch", "blackman", "rectangle", "perc", "triangle"])
			.action_({arg ctrl;
				onEnvChange.(ctrl.item);
			})
			.value_(0)
		);

		main.layout.add(util[\specsView].(specs, node, envir, main));
		main.layout.add(status);
		main;
	};

	node[0] = {

		var buf = \buf.kr(0);
		var pos = \pos.kr.range(\pos_min.kr(0), \pos_max.kr(1));
		var graindur = \graindur.kr.range(\graindur_min.kr(0.001), \graindur_max.kr(8));
		var rate = \rate.kr.range(\rate_min.kr(0.1), \rate_max.kr(200));
		var pitch = \pitch.kr.range(\pitch_min.kr(0.1), \pitch_max.kr(4));
		var envbuf = \envbuf.kr(-1).lag(0.01);
		var pan = \pan.kr.range(\pan_min.kr(-1), \pan_max.kr(1));
		var grainamp = \grainamp.kr.range(\grainamp_min.kr(0), \grainamp_max.kr(1));
		var impulse = Impulse.kr(rate);
		var amp = Dwhite(grainamp, 1, inf);
		var reverse = \reverse.kr.range(\reverse_min.kr(0), \reverse_max.kr(1));
		var rev = Dwrand([-1,1], [reverse,1-reverse], inf);

		var sig = GrainBufJ.ar(2,
			impulse,
			dur: graindur,
			sndbuf: buf,
			rate: pitch * rev,
			pos: pos,
			loop: 0,
			interp: 4,
			grainAmp: amp,
			pan: pan,
			envbufnum: envbuf
		);

		sig;
	};

	envbuf.set(\envbuf, envbuf);

	envir[name] = node;
	view.();
};

);
