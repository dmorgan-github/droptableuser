(
SynthDef(\grain_mono, {

	var osc1 = {

		var buf = \buf.kr(0);
		var pos = \pos.kr(0.1);
		var graindur = \graindur.kr(0.5);
		var rate = \rate.kr(1);
		var pitch = \pitch.kr(1);
		var envbuf = \envbuf.kr(-1).lag(0.01);
		var pan = \pan.kr(0);
		var grainamp = \grainamp.kr(1);
		var impulse = Impulse.kr(rate);
		var amp = Dwhite(grainamp, 1, inf);
		var panValue = Dwhite(pan.neg, pan, inf);//SinOsc.kr(10).range(pan.neg,pan);
		var reverse = \reverse.kr(0);
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
			pan: panValue,
			envbufnum: envbuf
		);

		//SendReply.kr(impulse, '/grain_data', [pos, graindur, pitch, amp, pan], 1905);

		sig;
	};

	var sig = osc1.();

	sig = Splay.ar(sig) * \amp.kr(0.1);

	Out.ar(\out.kr(0), sig);

}).add;
)

/////////////////////////////////////////
(

~grainrApp = {

	var view, gui, specs;
	var obj = ();
	var synth, buf;
	var windowSize = 2048;
	var envbuf = Buffer.sendCollection(s, Signal.hanningWindow(windowSize), 1);
	var lfo = (
		\pos: NodeProxy.new.source_({ DC.kr(0.1) });
	);
	var node = NodeProxy.new;
	var grainr = ();
	var event = (
		instrument:\grain_mono,
		type:\on,
		\amp: 1,
		\freq: 1
	);

	obj.onPosChange = {arg self, lo, hi;
		[lo, hi].debug("onPosChange");
	};
	obj.onEnvChange = {arg self, val;
		val.debug("onEnvChange");
	};
	obj.onControlChange = {arg self, name, val;
		[name, val].debug("onControlRangeChange");
	};
	obj.onSoundFileSelected = {arg self, buffer;
		buffer.bufnum.debug("onSoundFileSelected");
	};
	obj.onPlay = {arg self;
		"onplay".postln;
	};
	obj.onStop = {arg self;
		"onStop".postln;
	};
	obj.onRecord = {arg self;
		"onRecord".postln;
	};
	obj.onNodeGui = {arg self;
		"onNodeGui".postln;
	};
	obj.onLfoWaveChange = {arg self, index, val;
		[index, val].debug("onLfoWaveChange");
	};
	obj.onLfoFreqChange = {arg self, key, val;
		[key, val].debug("onLfoFreqChange");
	};
	obj.onLfoMapping = {arg self, key, val;
		[key, val].debug("onLfoMapping");
	};

	specs = (
		rate: [0.1, 200, \lin, 0.1, 1, "rate"].asSpec,
		graindur: [0.01, 8, \lin, 0.01, 0.5, "graindur"].asSpec,
		pitch: [0.1, 4, \lin, 0.1, 1, "pitch"].asSpec,
		pan: [0, 1, \lin, 0.1, 0.5, "pan"].asSpec,
		pos: \amp.asSpec,
		lfo: [0.01, 20,\lin,0.01,1,"lfo"].asSpec,
		grainamp: [0.1,1,\lin,0.1,1,"grainamp"].asSpec,
		reverse: \amp.asSpec
	);

	view = {

		var main = View().layout_(GridLayout());
		var fontFamily = "Courier New";
		var fontSize = 10;
		var font = Font(fontFamily, fontSize);
		var soundFileView, centerPosSlider;
		var bufpath = StaticText().string_("").font_(font);
		var bufdur = "";

		var menuView = {

			var view = View().layout_(HLayout());
			view.layout.add(Button()
				.string_("open")
				.font_(font)
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

							obj.onSoundFileSelected(buffer);

							specs[\pos] = ControlSpec(0, soundFile.numFrames);
							soundFileView.mouseUpAction.value(soundFileView);
						},
						cancelFunc: {"cancelled"}
					);
				})
			);
			view.layout.add(Button().string_("play").font_(font).action_({obj.onPlay()}));
			view.layout.add(Button().string_("stop").font_(font).action_({obj.onStop()}));
			view.layout.add(Button().string_("rec").font_(font).action_({obj.onRecord()}));
			view;
		};

		var lfoView = {

			var view = View().layout_(VLayout());

			1.do({arg index;

				var lfoView = View().layout_(VLayout()).maxHeight_(150);
				var nb, knob;
				var default = 0.1;
				var spec = [0.01,20,\lin,0.01,default].asSpec;
				var scaled = spec.unmap(default);

				knob = Knob().action_({arg ctrl;
					var val = spec.map(ctrl.value);
					obj.onLfoFreqChange(index, ctrl.value);
					nb.value_(val);
				})
				.value_(scaled);

				nb = NumberBox().font_(font).action_({arg ctrl;
					var val = ctrl.value;
					knob.valueAction_(spec.unmap(val));
				})
				.value_(default);

				lfoView.layout.add(StaticText().string_("lfo " ++ index).font_(font));
				lfoView.layout.add(PopUpMenu()
					.items_(["...", "sine", "saw", "noise"])
					.font_(font)
					.action_({arg ctrl;
						obj.onLfoWaveChange(index, ctrl.item);
					})
				);

				lfoView.layout.add(knob);
				lfoView.layout.add(nb);
				view.layout.add(lfoView);
			});

			view;
		};

		var waveView = {
			var view = View().layout_(VLayout());

			soundFileView = SoundFileView()
			.background_(Color.gray(0.3))
			.mouseUpAction = ({arg view;
				var loFrames, hiFrames, loSlider, hiSlider;
				loFrames = view.selection(0)[0];
				hiFrames = view.selection(0)[1] + loFrames;
				loSlider = specs[\pos].unmap(loFrames);
				hiSlider = specs[\pos].unmap(hiFrames);
				2.do{centerPosSlider.setSpanActive(loSlider, hiSlider)}; // 2.do = hack...
			});
			soundFileView.timeCursorOn = true;
			soundFileView.timeCursorColor = Color.blue(alpha:0.5);
			soundFileView.setSelectionColor(0, Color.blue(alpha:0.5));
			soundFileView.gridResolution = 0.0;

			view.layout.add(bufpath);
			view.layout.add(soundFileView);
			view;
		};

		var filtersView = {
			var view = View().layout_(VLayout());
			view.layout.add(Button()
				.font_(font)
				.string_("node")
				.action_({
					obj.onNodeGui();
			}), align:\top);

			8.do({
				view.layout.add(PopUpMenu().font_(font), align:\top);
			});

			view;
		};

		var controlsView = {

			var view = View().layout_(GridLayout());

			var ezKnob = {arg label;

				var view = View().layout_(VLayout()).minWidth_(100);
				var nb, knob;
				var spec = specs[label.asSymbol];
				var default = spec.default;
				var scaled = spec.unmap(default);

				nb = NumberBox().font_(font).action_({arg ctrl;
					var val = ctrl.value;
					knob.valueAction_(spec.unmap(val));
				})
				.maxWidth_(50)
				.value_(default);

				knob = Knob().action_({arg ctrl;
					var val = spec.map(ctrl.value);
					nb.value_(val);
					obj.onControlChange(label, val);
				})
				.value_(scaled);

				view.layout.add(nb, align:\left);
				view.layout.add(knob, align:\left);
				view.layout.add(StaticText().string_(label).font_(font));
				view;
			};

			var disperalView = {

				var view = View().layout_(HLayout());
				var slider, nb;
				var spec = specs[\lfo];
				var default = spec.default;
				var scaled = spec.unmap(default);

				view.layout.add(PopUpMenu()
					.font_(font)
					.items_(["","sine","saw","square","random"])
					.action_({arg ctrl;
						var val = ctrl.item;
						obj.onLfoWaveChange(\pos, val);
					})
				);

				slider = Slider().orientation_(\horizontal).action_({arg ctrl;
					var val = spec.map(ctrl.value);
					nb.value_(val);
					obj.onLfoFreqChange(\pos, val);
				})
				.value_(scaled);

				nb = NumberBox().font_(font).maxWidth_(35).action_({arg ctrl;
					var val = ctrl.value;
					slider.valueAction_(spec.unmap(val));
				})
				.value_(default);

				view.layout.add(slider);
				view.layout.add(nb);
				view;
			};

			centerPosSlider = RangeSlider()
			.orientation_(\horizontal)
			.hi_(0.5)
			.lo_(0.5)
			.action_({arg ctrl;
				obj.onPosChange(ctrl.lo, ctrl.hi);
			});

			//view.layout.addSpanning(centerPosSlider, 0,0, columnSpan: 6);
			view.layout.addSpanning(disperalView.(), 1,0, columnSpan: 6);
			view.layout.add(ezKnob.("rate"), 2, 0);
			view.layout.add(ezKnob.("graindur"), 2, 1);
			view.layout.add(ezKnob.("grainamp"), 2, 2);
			view.layout.add(ezKnob.("pitch"), 2, 3);
			view.layout.add(ezKnob.("reverse"), 2, 4);
			view.layout.add(ezKnob.("pan"), 2,5);
			view.layout.addSpanning(PopUpMenu()
				.font_(font)
				.items_(["hann", "hamming", "welch", "blackman", "rectangle", "perc", "triangle"])
				.action_({arg ctrl;
					obj.onEnvChange(ctrl.item);
				})
				.value_(0)
				, 3, 0, columnSpan: 6);

			view;
		};

		main.layout.addSpanning(menuView.(), 0, 0, columnSpan:2);

		main.layout.add(waveView.(), 1, 0);
		main.layout.add(filtersView.(), 1,1, align:\top);

		main.layout.add(controlsView.(), 2, 0);
		//main.layout.add(lfoView.(), 2, 1);

		obj.show = {
			main.front;
		};

		obj;
	};

	gui = view.();

	gui.onPosChange = {arg self, lo, hi;
		lfo[\pos].set(\lo, lo, \hi, hi);
	};
	gui.onEnvChange = {arg self, val;

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
	gui.onControlChange = {arg self, name, val;
		synth.set(name.asSymbol, val);
		event[name.asSymbol] = val;
	};
	gui.onSoundFileSelected = {arg self, buffer;
		buf = buffer.bufnum;
		synth.set(\buf, buf);
		event[\buf] = buf;
	};
	gui.onPlay = {arg self;

		node.play;

		event[\buf] = buf;
		event[\pos] = lfo[\pos];
		event[\envbuf] = envbuf.bufnum;
		event[\group] = node.group;
		event[\out] = node.bus;

		synth = event.play;
	};
	gui.onStop = {arg self;
		synth.release;
	};
	gui.onRecord = {arg self;
		"onRecord".postln;
	};
	gui.onNodeGui = {arg self;
		node.gui;
	};
	gui.onLfoWaveChange = {arg self, key, val;

		// TODO: fix this
		case
		{val == "sine"} {
			lfo[key].source = {
				SinOsc.kr(\freq.kr(1)).range(\lo.kr(0.1), \hi.kr(0.1));
			};
		}
		{val == "saw"} {
			lfo[key].source = {
				LFSaw.kr(\freq.kr(1)).range(\lo.kr(0.1), \hi.kr(0.1));
			};
		}
		{val == "random"} {
			lfo[key].source = {
				LFNoise2.kr(\freq.kr(1)).range(\lo.kr(0.1), \hi.kr(0.1));
			};
		}
		{val == "square"} {
			lfo[key].source = {
				LFPulse.kr(\freq.kr(1)).range(\lo.kr(0.1), \hi.kr(0.1));
			};
		};
	};

	gui.onLfoFreqChange = {arg self, key, val;
		lfo[key].set(\freq, val);
	};
	gui.onLfoMapping = {arg self, name, val;

		/*
		var mylabel = name.asSymbol;
		var in = Ndef(val.asSymbol);
		var spec = specs[mylabel];
		var default = spec.default;
		[name, val].debug("onLfoMapping");

		Ndef(mylabel, {
		var sig = in.kr;
		sig.range(\lo.kr(default), \hi.kr(default));
		});

		synth.set(mylabel, Ndef(mylabel));
		*/
	};

	grainr[\app] = gui;
	grainr[\node] = node;

	grainr;
};

)

~grainr = ~grainrApp.();
~grainr.app.show();

~grainr.node[20] = \filter -> ~fx[\jpverb][\func];
~grainr.node[30] = \filter -> {arg in; Limiter.ar(in, 0.8)}

~grainr.node.vol = 0.4


~grainr2 = ~grainrApp.();
~grainr2.app.show();

~grainr2.node[20] = \filter -> ~fx[\jpverb][\func];
~grainr2.node[30] = \filter -> {arg in; Limiter.ar(in, 0.8)}

o = OSCFunc({arg msg; msg.postln }, '/grain_data');

~fx[\jpverb][\specs].do({arg kv; ControlSpec.specs[kv.key] = kv.value.asSpec})

Ndef(\test).play;

~grainr.node.play
~grainr2.node.play

(
Ndef(\test)[0] = {

	var sig1 = ~grainr.node.ar;
	var sig2 = ~grainr2.node.ar;

	var sig = sig1 + sig2;

	sig + WaveLoss.ar(Squiz.ar(sig));

};
)

Ndef(\test).stop

App.record
s.stopRecording

(
//Blackman Window
var sig, size, alpha, a0, a1, a2;
size = 2048;
alpha = 0.16;
sig = Signal.newClear(size);

a0 = 0.5*(1-alpha);
a1 = 0.5;
a2 = alpha*0.5;

sig.waveFill( { arg x, i; a0 - (a1*cos( (2*pi*x)/(size-1) ) ) + (a2*cos( (4*pi*x)/(size-1) ) )}, 0, size );

// your OSC message
//z = [0, [\b_alloc, 0, 2048, 1, [\b_setn, 0, 0, 2048] ++ sig]]

sig.plot

)

(
var text, canvas, spec;
var sfv = SoundFileView.new();
var file = SoundFile.new;

text = TextView().string_("Hello world!").keyDownAction_({canvas.refresh});
canvas = UserView().acceptsMouse_(false).alpha_(0.1).drawFunc_({
    var b = canvas.bounds();
    var str = text.string;
    Pen.translate( b.center.x, b.center.y );
    Pen.fillColor = Color.blue;//text.palette.baseText.alpha_(0.9);
    str.do { |c|
        var x = 40.0.rand + 10.0;
        var r = c.asString.bounds.center_(0@0);
        Pen.push;
        Pen.rotate( 1.0.rand );
        Pen.translate( rand2(-0.3,0.3) * b.width, rand2(-0.3,0.3) * b.width );
        Pen.scale( x, x );
        Pen.stringCenteredIn(c.asString, r);
        Pen.pop;
    }
}).refresh;

file.openRead(Platform.resourceDir +/+ "sounds/a11wlk01.wav");

sfv.soundfile = file;
sfv.read(0, file.numFrames);
sfv.elasticMode = true;

spec = ControlSpec(0, file.numFrames);

sfv.drawsWaveForm = true;
sfv.gridOn = false;
sfv.gridResolution = 60;
sfv.setSelectionColor(0, Color.gray(0.8, 0.2));
sfv.setSelection(0, spec.map([0.5, 0.6]) );


w=Window().layout_( StackLayout(canvas, sfv, text ).mode_(\stackAll) ).front;
)

nil.set(\abc, 1)

Ndef(\pos).document