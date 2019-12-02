L {
	*new {
		var view;
		var pdefs = Pdef.all.keys.asArray
		.sort
		.select({arg k; k.asString.contains("_ptrn")})
		.collect({arg k; Pdef(k)});

		var buttons = List.new;
		var currentrow = nil;
		var lastkey = "";
		pdefs.do({arg pdef, i;
			var key = pdef.key;
			if (key.asString.beginsWith(lastkey).not) {
				lastkey = key.asString.split($_)[0];
				currentrow = List.new;
				buttons.add(currentrow);
			};
			currentrow.add(Button()
				.states_([ [key, nil, Color.gray], [key, nil, Color.blue] ])
				.action_({arg ctrl;
					if (ctrl.value == 1) {
						pdef.play;
					}{
						pdef.stop;
					}
				})
				.value_(pdef.isPlaying)
			);
		});
		view = View().layout_(GridLayout.rows(*buttons));
		view.front;
	}
}

B : S {

	classvar <all;

	var <buf;

	*new {arg key, path;
		var res = all[key];
		if (res.isNil) {
			var synth = \smplr_1chan;
			res = super.new(key, synth).bInit(path);
			all.put(key, res);
		};
		^res;
	}

	bInit {arg inPath;
		if (inPath.isKindOf(Buffer)) {
			var bufnum = inPath.bufnum;
			buf = inPath;
			this.specs.add(\buf -> ControlSpec(bufnum, bufnum, \lin, 0, bufnum));
			this.set(\buf, buf);
			if (buf.numChannels == 2) {
				this.set(\instrument, \smplr_2chan);
			}
		}{
			Buffer.read(Server.default, inPath, action:{arg mybuf;
				var bufnum;
				"buffer loaded; numchannels: %".format(mybuf.numChannels).debug(\b);
				bufnum = mybuf.bufnum;
				buf = mybuf;
				this.specs.add(\buf -> ControlSpec(bufnum, bufnum, \lin, 0, bufnum));
				this.set(\buf, buf);
				if (buf.numChannels == 2) {
					this.set(\instrument, \smplr_2chan);
				};
			});
		};
		^this;
	}

	prNoteOn {arg rate, vel=1;
		if (this.node.isPlaying) {
			var evt = {
				this.envir.select({arg val; val.isKindOf(Pattern).not});
				this.envir[\vel] = vel;
				this.envir;
			}.();
			var args = [\out, this.node.bus.index, \rate, rate] ++ evt.asPairs();
			Synth(this.envir[\instrument], args, target:this.node.nodeID);
		}
	}

	prNoteOff {arg midinote;
		// no op
		// we are using timed envelopes
	}

	gui {
		var sfv;
		var defaultDur = envir[\dur] ?? 1;
		var view = View().layout_(VLayout().margins_(0.5).spacing_(0.5))
		.minHeight_(200)
		.minWidth_(200)
		.palette_(QPalette.dark);

		var start = NumberBox().normalColor_(Color.white);
		var beats = NumberBox().action_({arg ctrl;
			var begin = sfv.selection(0)[0];
			var dur = ctrl.value;
			var size = dur * TempoClock.default.tempo * buf.sampleRate;
			var end = size + begin;
			this.set(\dur, dur);
			sfv.setSelection(0, [begin, size]);
		})
		.normalColor_(Color.white)
		.value_(defaultDur);

		sfv = SoundFileView()
		.background_(Color.gray(0.3))
		.timeCursorOn_(true)
		.gridOn_(true)
		.gridResolution_(0)
		.mouseUpAction = ({arg ctrl;
			var loFrames, hiFrames;
			var msg;
			var begin = ctrl.selection(0)[0];
			var end = ctrl.selection(0)[1] + begin;
			var dur = (end - begin)/buf.sampleRate;
			var start = begin/buf.numFrames;
			this.set(\start, start, \dur, dur);
			beats.value = dur;
		});
		buf.loadToFloatArray(action:{arg a;
			{
				sfv.setData(a, channels: buf.numChannels);
				sfv.setSelection (0, [0, buf.numFrames]);
				sfv.mouseUpAction.value(sfv);
			}.defer
		});

		view.layout.add(HLayout(start, beats));
		view.layout.add(sfv);
		^view.front;
	}

	*initClass { all = () }
}
/*
(
OscCtrl.paths('/rotary8/r', (1..12), {arg val, num;
	var note = 48 + (num-1);
	if (val == 1) {
		S(\synth1).on(note, 1);
	}{
		S(\synth1).off(note);
	}
});
)
OscCtrl.paths('/rotary8/r', (1..12), nil);
*/
OscCtrl {

	/*
	Note: use symbol notation for path
	*/
	*path {arg path, func;
		var key = path.asSymbol;
		if (func.isNil) {
			OSCdef(key).free;
		}{
			OSCdef.newMatching(key, {arg msg, time, addr, recvPort;
				var val = msg[1];
				func.(val);
			}, key).permanent_(true);
		};
	}

	/*
	Note: use symbol notation for prefix
	*/
	*paths {arg prefix, nums, func;
		if (func.isNil) {
			nums.do({arg i;
				var path =  "%%".format(prefix, i).asSymbol;
				"free %".format(path).debug(\many);
				OSCdef(path).free;
			});
		}{
			nums.do({arg i;
				var path =  "%%".format(prefix, i).asSymbol;
				"register %".format(path).debug(\many);
				OSCdef.newMatching(path, {arg msg, time, addr, recvPort;
					var val = msg[1];
					func.(val, i);
				}, path).permanent_(true);
			});
		}
	}
}

/*
(
MidiCtrl(\key, \iac)
.note(
	{arg note, vel;
		var myvel = vel/127;
		S(\synth1).noteon(note, myvel)
	},
	{arg note;
		S(\synth1).noteoff(note)
	}
)
)
MidiCtrl(\synth1).note(nil, nil);
*/
MidiCtrl {
	classvar <all;

	var <key, <src, <chan;

	*new {arg key, src=\iac, chan;
		var res = all[key];
		if (res.isNil) {
			res = super.new.init(key, src, chan);
			all.put(key, res);
		};
		^res;
	}

	init {arg inKey, inSrcKey, inChan;
		key = inKey;
		chan = inChan;
		MIDIClient.init;
		if (inSrcKey.isNil.not) {
			src = switch(inSrcKey,
				\roli_usb, {
					MIDIClient.sources
					.select({arg src; src.device.beginsWith("Lightpad BLOCK")})
					.first
				},
				\roli_bt, {
					MIDIClient.sources
					.select({arg src; src.device.beginsWith("Lightpad Block 1UOC")})
					.first
				},
				\iac, {
					MIDIClient.sources
					.select({arg src; src.device.beginsWith("IAC Driver")})
					.first;
				}
			);
			MIDIIn.connect(device:src);
		};
		^this;
	}

	note {arg on, off;

		var mychan = if (chan.isNil) {"all"}{chan};
		var srcid = if (this.src.isNil.not){src.uid}{nil};
		var srcdevice = if (this.src.isNil.not){this.prNormalize(src.device)}{"any"};
		var onkey = ("%_%_%_on").format(this.key, mychan, srcdevice).asSymbol;
		var offkey = ("%_%_%_off").format(this.key, mychan, srcdevice).asSymbol;

		if (on.isNil) {
			"free %".format(onkey).debug(this.key);
			MIDIdef(onkey).permanent_(false).free;
		}{
			"register %".format(onkey).debug(this.key);
			MIDIdef.noteOn(onkey, func:{arg vel, note, chan, src;
				on.(note, vel, chan);
			}, chan:chan, srcID:srcid)
			.permanent_(true);
		};

		if (off.isNil){
			"free %".format(offkey).debug(this.key);
			MIDIdef(offkey).permanent_(false).free;
		}{
			"register %".format(offkey).debug(this.key);
			MIDIdef.noteOff(offkey, func:{arg vel, note, chan, src;
				off.(note, chan);
			}, chan:chan, srcID:srcid)
			.permanent_(true);
		};

		^this;
	}

	cc {arg num, func;
		var mychan = if (chan.isNil) {"all"}{chan};
		var srcid = if (this.src.isNil.not){src.uid}{nil};
		var srcdevice = if (this.src.isNil.not){this.prNormalize(src.device)}{"any"};
		var key = "%_%_%_cc%".format(this.key, mychan, srcdevice, num).asSymbol;
		if (func.isNil) {
			"free %".format(key).debug(this.key);
			MIDIdef(key).permanent_(false).free;
		}{
			"register %".format(key).debug(this.key);
			MIDIdef.cc(key, {arg val, num, chan, src;
				func.(val, num, chan);
			}, chan:chan, srcID:srcid)
			.permanent_(true);
		}
	}

	bend {arg func;
		var mychan = if (chan.isNil) {"all"}{chan};
		var srcid = if (this.src.isNil.not){src.uid}{nil};
		var srcdevice = if (this.src.isNil.not){this.prNormalize(src.device)}{"any"};
		var key = "%_%_%_bend".format(this.key, mychan, srcdevice).asSymbol;
		if (func.isNil) {
			"free %".format(key).debug(this.key);
			MIDIdef(key).permanent_(false).free;
		}{
			"register %".format(key).debug(this.key);
			MIDIdef.bend(key, {arg val, chan, src;
				// var bend = val.linlin(0, 16383, 0.9, 1.1);
				func.(val, chan);
			}, chan:chan, srcID:srcid)
			.permanent_(true);
		}
	}

	clear {
		this.note(nil, nil);
		this.bend(nil);
		// clear all with brute force
		127.do({arg i;
			this.cc(i, nil);
		});
		all.removeAt(key)
	}

	prNormalize {arg str;
		^str.toLower().stripWhiteSpace().replace(" ", "")
	}

	*clearAll {
		all.do({arg m; m.clear()});
		all.clear;
	}

	*initClass { all = () }
}

S {
	classvar <all;

	classvar <>defaultRoot, <>defaultScale, <>defaultTuning, <defaultSpecs;

	var <key, <envir, <node, <specs, <synths, <ptrn, synthdef;

	*new {arg key, synth;
		var res = all[key];
		if (res.isNil) {
			res = super.new.prInit(key);
			all.put(key, res);
		};
		if (synth.isNil.not) {
			res.prInitSynth(key, synth);
		};
		^res;
	}

	prInit {arg inKey;

		if (inKey.isNil) {
			Error("key not specified");
		};
		// using a list as a queue for each note
		// because i'm a little uncertain about
		// the potential for race conditions
		// and possibly having a synth floating
		// off in outer space
		synths = Array.fill(127, {List.new});
		specs = List.new;
		envir = ();
		key = inKey;
		node = Ndef(key);
		node.play;

		^this;
	}

	prInitSynth {arg inKey, inSynth;

		var synthname = inSynth;
		if (inSynth.isKindOf(Function)) {
			synthname = inKey;
			this.prBuildSynth(synthname, inSynth);
		};
		envir[\instrument] = synthname;

		synthdef = SynthDescLib.global.at(synthname);
		if (synthdef.isNil) {
			Error("synthdef not found").throw;
		};

		if (synthdef.metadata.isNil.not) {
			specs = synthdef.metadata[\specs].asList;
		} {
			specs = (
				synthdef.controls
				.reject({arg ctrl;
					[
						\out, \freq, \gate, \trig
					].includes(ctrl.name)
				})
				.collect({arg ctrl;
					var key = ctrl.name.asSymbol;
					var spec = defaultSpecs.detect({arg assoc; assoc.key == key}).value;
					if (spec.isNil) {
						var max = if (ctrl.defaultValue < 1) {1} { min(20000, ctrl.defaultValue * 2) };
						spec = [0, max, \lin, 0, ctrl.defaultValue];
					};
					key -> spec.asSpec;
				})
			)
			.asList;
		};
	}

	addSpec {arg key, spec;
		var myspec = this.specs.detect({arg assoc; assoc.key == key});
		if (myspec.isNil) {
			this.specs.add(key -> spec.asSpec);
		} {
			myspec.value = spec.asSpec;
		}
	}

	set {arg ...args;

		if (args.size.even.not) {
			Error("args must be even number").throw;
		};

		forBy(0, args.size-1, 2, {arg i;
			var k = args[i];
			var v = args[i+1];

			case
			{v.isKindOf(Function)} {
				var lfokey = (this.key ++ '_' ++ k).asSymbol;
				"creating lfo node %".format(lfokey).debug(this.key);
				envir[k] = Ndef(lfokey, v);
			}
			{v.isNil} {
				var myspec = specs.select({arg kv; kv.key == k}).first;
				if (myspec.isNil.not) {
					envir[k] = myspec.value.default;
				} {
					envir.removeAt(args[i-1]);
				};
			}
			{
				envir[k] = v;
			}
		});
		^this;
	}

	filter {arg index, func;
		node.put(index, \filter -> func);
	}

	on {arg midinote, vel=1;
		this.prNoteOn(midinote, vel);
	}

	off {arg midinote;
		this.prNoteOff(midinote);
	}

	pattern {arg ...pairs;
		ptrn = pairs.asPairs;
		^this;
	}

	pdef {

		var myspecs = [];
		if (specs.isNil.not) {
			myspecs = specs.collect({arg assoc;
				var key = assoc.key;
				var spec = assoc.value;
				if (envir[key].isNil) {
					envir[key] = spec.default;
				};
				[key, Pfunc({envir[key]})]
			}).flatten;
		};

		myspecs = myspecs ++ [
			\instrument, envir[\instrument],
			\root, Pfunc({defaultRoot}),
			\scale, Pfunc({Scale.at(defaultScale).copy.tuning_(defaultTuning)}),
			\out, Pif(Pfunc({node.bus.isNil}), 0, Pfunc({node.bus.index})),
			\group, Pfunc({node.group})
		];

		^Pdef(key, {arg monitor=true, fadeTime=0, out=0;

			if (node.isMonitoring.not and: monitor) {
				node.play(fadeTime:fadeTime, out:out);
			};

			Pbind(*myspecs)
			<> Pbind(
				\beatdur, Pfunc({thisThread.clock.beatDur}),
				\elapsedbeats, Pfunc({thisThread.clock.elapsedBeats}),
				\bar, Pfunc({thisThread.clock.bar}),
				\beatinbar, Pfunc({thisThread.clock.beatInBar})
			)
		})
	}

	clear {
		Ndef(key).clear;
		Pdef(key).clear;
		this.panic();
		all[key] = nil;
	}

	panic {
		synths.do({arg list, i;
			var synth = list.pop;
			while({synth.isNil.not},{
				synth.free;
				synth = list.pop;
			});
		});
		if (node.group.isNil.not) {
			node.group.free;
		}
	}

	gui {
		/*
		TODO: move to own class and called from here
		*/
		var scrollView = ScrollView();
		var view = View()
		.layout_(VLayout().margins_(0.5).spacing_(0.5))
		.palette_(QPalette.dark);

		specs.do({arg assoc;
			var k = assoc.key;
			var v = assoc.value;
			var ctrl = this.prCtrlView(k, v.asSpec, Color.rand, envir);
			view.layout.add(ctrl);
		});

		view.layout.add(nil);
		scrollView.canvas = view.background_(Color.clear);
		^scrollView.front;
	}

	prBuildSynth {arg inKey, inFunc;

		SynthDef(inKey, {
			var gate = \gate.kr(1);
			var in_freq = \freq.ar(261);
			var detune = \detuneratio.kr(1);
			var bend = \bend.ar(1);
			var freqbend = Lag.ar(in_freq * bend, 0.005);
			var freq = Vibrato.ar([freqbend, freqbend * detune], \vrate.ar(6), \vdepth.ar(0.0));

			var adsr = {
				var da = Done.freeSelf;
				var atk = \atk.kr(0.01);
				var dec = \dec.kr(0.1);
				var rel = \rel.kr(0.1);
				var curve = \curve.kr(-4);
				var suslevel = \suslevel.kr(0.5);
				var ts = \ts.kr(1);
				var env = Env.adsr(atk, dec, suslevel, rel, curve:curve).ar(doneAction:da, gate:gate, timeScale:ts);
				env;
			};

			var aeg = adsr.();
			var sig = inFunc.(freq, gate);

			sig = sig * aeg * AmpCompA.ar(freq) * \vel.kr(1);
			sig = Splay.ar(sig, \spread.kr(0), center:\center.kr(0));
			sig = LeakDC.ar(sig);
			sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
			sig = sig * \amp.kr(-10.dbamp);
			Out.ar(\out.kr(0), sig);

		}).add;
	}

	prNoteOn {arg midinote, vel=1;

		// TODO: see if this technique works
		// https://gist.github.com/markwheeler/b88b4f7b0f2870567b55cbc36abbd5ea
		// there should only be one synth per note
		if (node.isPlaying) {
			var evt = {
				envir.select({arg val; val.isKindOf(Pattern).not});
				envir[\vel] = vel;
				envir;
			}.();
			var args = [\out, node.bus.index, \gate, 1, \freq, midinote.midicps] ++ evt.asPairs();
			if (synths[midinote].last.isNil) {
				synths[midinote].add( Synth(envir[\instrument], args, target:node.nodeID) );
			}
		}
	}

	prNoteOff {arg midinote;
		// popping from a queue seems more atomic
		// than dealing strictly with an array
		// removeAt(0) changes the size of the array
		// copying seems to produce better results
		// but i'm not sure why
		var mysynths = synths.copy;
		var synth = mysynths[midinote].pop;
		while({synth.isNil.not},{
			synth.set(\gate, 0);
			synth = mysynths[midinote].pop;
		});
	}

	prCtrlView {arg key, spec, color, envir=();

		/*
		TODO: move to own class
		*/
		var controlSpec = spec;
		var myval = envir[key] ?? controlSpec.default;
		var stack, view;
		var font = Font(size:10);
		var li = LevelIndicator().value_(controlSpec.unmap(myval));
		var labelView = StaticText().string_(key ++ ": ").font_(font).stringColor_(Color.white);
		var st = StaticText().string_(myval).font_(font).stringColor_(Color.white);
		var nb = NumberBox()
		.font_(font)
		.value_(myval)
		.background_(Color.white)
		.minDecimals_(3)
		.clipLo_(controlSpec.minval)
		.clipHi_(controlSpec.maxval);

		envir[key] = myval;
		stack = StackLayout(
			View()
			.layout_(
				StackLayout(
					View().layout_(HLayout(labelView, st, nil).margins_(1).spacing_(1)),
					li
					.style_(\continuous)
					.meterColor_(color.alpha_(0.5))
					.warningColor_(color.alpha_(0.5))
					.criticalColor_(color.alpha_(0.5))
					.background_(color.alpha_(0.2))
				)
				.mode_(\stackAll)
				.margins_(0)
				.spacing_(0)
			)
			.mouseMoveAction_({arg ctrl, x, y, mod;
				var val = x.linlin(0, ctrl.bounds.width, 0, 1);
				var mappedVal = controlSpec.map(val);
				if (mod == 0) {
					li.value = val;
					st.string_(mappedVal);
					nb.value = mappedVal;
					envir[key] = mappedVal;
				};
			})
			.mouseDownAction_({arg ctrl, x, y, mod, num, count;
				var val = controlSpec.default;
				if (count == 2) {
					li.value = controlSpec.unmap(val);
					st.string_(val);
					nb.value = val;
					envir[key] = val;
				} {
					if (mod == 0) {
						var val = x.linlin(0, ctrl.bounds.width, 0, 1);
						var mappedVal = controlSpec.map(val);
						li.value = val;
						st.string_(mappedVal);
						nb.value = mappedVal;
						envir[key] = mappedVal;
					};
				};
			}),
			nb
			.action_({arg ctrl;
				var val = ctrl.value;
				li.value = controlSpec.unmap(val);
				st.string_(val);
				envir[key] = val;
				stack.index = 0;
			}),
		).mode_(\stackOne)
		.margins_(0)
		.spacing_(0);

		view = View().layout_(HLayout(
			View()
			.layout_(stack)
			.mouseDownAction_({arg ctrl, x, y, mod, num, count;
				if (mod == 262144) {
					stack.index = 1;
				}
			}).fixedHeight_(25),
		).margins_(0).spacing_(1));

		^view;
	}

	*initClass {
		all = ();
		defaultTuning = \et12;
		defaultRoot = 4;
		defaultScale = \dorian;

		defaultSpecs = List.new
		.addAll([
			\cutoff -> [20, 18000, 'exp', 0, 1000],
			\res -> [0, 1, \lin, 0, 0.5],
			\start -> [0, 1, \lin, 0, 0],
			\rate -> [0.1, 4.0, \lin, 0, 1],
			\detuneratio -> [0.9, 1.1, \lin, 0, 1],
			\atk -> [0, 30, \lin, 0, 0.01],
			\dec -> [0, 30, \lin, 0, 0.2],
			\rel -> [0, 30, \lin, 0, 0.29],
			\suslevel -> [0, 1, \lin, 0, 0.7],
			\sus -> [0, 30, \lin, 0, 0.1],
			\atkcurve -> [-4,4,\lin,0,4],
			\relcurve -> [-4,4,\lin,0,-4],
			\curve -> [-24, 24, \lin, 0, -4],
			\ts -> [0, 100, \lin, 0, 1],
			\bend -> [0.9, 1.1, \lin, 0, 1],
			\vrate -> [0, 440, \lin, 0, 6],
			\vdepth -> [0, 1, \lin, 0, 0],
			\vel -> [0, 1, \lin, 0, 1],
			\spread -> [0, 1, \lin, 0, 1],
			\center -> [0, 1, \lin, 0, 0],
			\pan -> [-1, 1, \lin, 0, 0],
			\amp -> [-60.dbamp, 20.dbamp, \lin, 0, -20.dbamp]
		]);
	}
}