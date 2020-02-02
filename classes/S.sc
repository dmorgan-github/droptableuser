
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
				this.instrument = \smplr_2chan
			}
		}{
			if (inPath.isNumber) {
				var bufnum;
				buf = B.alloc(inPath);
				bufnum = buf.bufnum;
				this.specs.add(\buf -> ControlSpec(bufnum, bufnum, \lin, 0, bufnum));
				this.set(\buf, buf);
				this.instrument = \smplr_2chan;
			}{
				Buffer.read(Server.default, inPath, action:{arg mybuf;
					var bufnum;
					"buffer loaded; numchannels: %".format(mybuf.numChannels).debug(\b);
					bufnum = mybuf.bufnum;
					buf = mybuf;
					this.specs.add(\buf -> ControlSpec(bufnum, bufnum, \lin, 0, bufnum));
					this.set(\buf, buf);
					if (buf.numChannels == 2) {
						this.instrument = \smplr_2chan;
					};
				});
			}
		};
		^this;
	}

	*alloc {arg seconds;
		var numChannels = 2;
		^Buffer.alloc(Server.default, 44100 * seconds, numChannels);
	}

	recSoundIn {arg reclevel=1;
		Synth(\rec_soundin, [\buf, buf, \run, 1, \trig, 1, \reclevel, reclevel]);

		OSCFunc({arg msg;
			msg.debug(\recSoundIn);
		}, '/rec_soundin_done', Server.default.addr).oneShot;
	}

	overdubSoundIn {arg prelevel=0.7, reclevel=1;
		Synth(\rec_soundin, [\buf, buf, \run, 1, \trig, 1, \reclevel, reclevel, \prelevel, prelevel]);

		OSCFunc({arg msg;
			msg.debug(\overdubSoundIn);
		}, '/rec_soundin_done', Server.default.addr).oneShot;
	}

	gui {
		var sfv;
		var defaultDur = 1;
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

	*initClass {

		all = ();

		StartUp.add {
			SynthDef(\rec_soundin, {

				var in = SoundIn.ar([0, 1]);
				var trig = \trig.tr;
				var buf = \buf.kr(0);
				var run = \run.kr(0);

				var sig = RecordBuf.ar(in,
					buf,
					offset:0,
					recLevel:\reclevel.ar(1),
					preLevel:\prelevel.ar(0),
					run:run,
					loop:\loop.kr(0),
					trigger:trig,
					doneAction:Done.freeSelf
				);

				var donetrig = Done.kr(sig);
				SendReply.kr(donetrig, '/rec_soundin_done', 1, 1905);
				sig;

			}).add;
		};
	}
}

S {
	classvar <all;

	classvar <>defaultRoot, <>defaultScale, <>defaultTuning, <defaultSpecs;

	var <key, <>instrument, <node, <specs, <synths, synthdef, <scenes, <currentScene, <setterkey;

	var <preset;

	var func;

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
		scenes = Order.new;
		preset = ();
		key = inKey;
		setterkey = (key ++ '_pset').asSymbol;
		node = Ndef(key);
		// play sets up the node for audio
		node.play;

		//func = {
		//    var group = Group.new;
		//	node.group = group;
		//};
		//func.value;
		// i don't understand why this doesn't work
		// after cmdperiod the group is assigned
		// but somehow ignored by the node
		//CmdPeriod.add(func);

		^this;
	}

	prInitSynth {arg inKey, inSynth;

		instrument = inSynth;

		if (inSynth.isKindOf(Function)) {
			instrument = inKey;
			this.prBuildSynth(instrument, inSynth);
		};

		synthdef = SynthDescLib.global.at(instrument);
		if (synthdef.isNil) {
			Error("synthdef not found").throw;
		};

		if (synthdef.metadata.isNil.not) {
			specs = synthdef.metadata[\specs].asList;
		} {
			// TODO: make this smarter
			// so it picks up new controls from synthdef
			// without overwriting any specs added after the fact
			if (specs.size == 0) {
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
			}
		};
	}

	freqscope {

		var view = View()
		.layout_(VLayout().spacing_(0).margins_(0))
		.name_(key)
		.minWidth_(200)
		.minHeight_(150);

		var fsv = FreqScopeView()
		.active_(true)
		.freqMode_(1)
		.inBus_(node.bus.index);

		view.layout.add(fsv);
		view.onClose_({
			fsv.kill;
		});
		view.front;
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
				node.set(k, Ndef(lfokey, v));
			}
			{v.isNil} {
				//var myspec = specs.select({arg kv; kv.key == k}).first;
				//if (myspec.isNil.not) {
					//envir[k] = myspec.value.default;
				//	node.set(k, myspec.value.default);
				//} {
					//envir.removeAt(args[i-1]);
					node.unset(args[i-1]);
				//};
			}
			{
				//envir[k] = v;
				node.set(k, v);
			}
		});
	}

	pset {arg ...args;

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
				Pbindef(this.setterkey, k, Ndef(lfokey, v));
			}
			{
				Pbindef(this.setterkey, k, v);
			}
		});
	}

	filter {arg index, func;
		node.put(index, \filter -> func);
	}

	scene {arg index, func;
		var gdef = Pdef(this.key ++ '_gptrn' ++ index, Pbind(\type, \set, \id, Pfunc({this.node.nodeID})));
		var pattern = func.(this.pdef, gdef, this.scenes);
		var key = (this.key ++ '_ptrn' ++ index).asSymbol;
		pattern = Pdef(key, pattern);
		scenes.put(index, pattern);
	}

	playScene {arg index;
		scenes.do({arg pdef;
			pdef.stop;
		});
		currentScene = index;
		scenes[currentScene].play;
	}

	stopScene {arg index;
		if (index.isNil) {
			scenes.do({arg pdef;
				pdef.stop;
			});
		} {
			scenes[index].stop;
		}
	}

	on {arg midinote, vel=1;
		this.prNoteOn(midinote, vel);
	}

	off {arg midinote;
		this.prNoteOff(midinote);
	}

	pdef {

		var myspecs = [];
		if (specs.isNil.not) {
			myspecs = specs.collect({arg assoc;
				var key = assoc.key;
				var spec = assoc.value;
				//if (envir[key].isNil) {
				//	envir[key] = spec.default;
				//};
				[key, Pif(Pfunc({node.get(key).isNil}), spec.default, Pfunc({node.get(key)}))]
			}).flatten;
		};

		myspecs = myspecs ++ [
			\instrument, instrument,
			\root, Pfunc({defaultRoot}),
			\scale, Pfunc({Scale.at(defaultScale).copy.tuning_(defaultTuning)}),
			\out, Pif(Pfunc({node.bus.isNil}), 0, Pfunc({node.bus.index})),
			\group, Pfunc({node.group})
		];

		^Pdef(key, {arg monitor=true, fadeTime=0, out=0;

			monitor.debug([key, \monitor]);
			if (node.isMonitoring.not and: monitor) {
				node.play(fadeTime:fadeTime, out:out);
			};

			Pbindef(this.setterkey, this.key, 1)
			<> Pbind(*myspecs)
			<> Pbind(
				\beatdur, Pfunc({thisThread.clock.beatDur}),
				\elapsedbeats, Pfunc({thisThread.clock.elapsedBeats}),
				\bar, Pfunc({thisThread.clock.bar}),
				\beatinbar, Pfunc({thisThread.clock.beatInBar}),
				\hit, Pseries(0, 1, inf)
			)
		})
	}

	clear {
		Ndef(key).clear;
		Pdef(key).clear;
		Pdef(this.setterkey).clear;
		scenes.do({arg pdef;
			pdef.clear;
		});
		this.panic();
		//CmdPeriod.remove(func);
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

	gui {arg func={};
		^Sui(this.key, this.specs, this.preset)
		.handler_(func)
		.view.front;
	}

	prBuildSynth {arg inKey, inFunc;

		SynthDef(inKey, {
			var gate = \gate.kr(1);
			var in_freq = \freq.ar(261).lag(\glis.kr(0));
			var detune = \detuneratio.kr(1);
			var bend = \bend.ar(1);
			var freqbend = in_freq * bend;
			var freq = Vibrato.ar([freqbend, freqbend * detune], \vrate.ar(6), \vdepth.ar(0.0));

			var adsr = {
				var da = Done.freeSelf;
				var atk = \atk.kr(0.01);
				var dec = \dec.kr(0.1);
				var rel = \rel.kr(0.1);
				var curve = \curve.kr(-4);
				var suslevel = \suslevel.kr(0.5);
				var ts = \ts.kr(1);
				var atkcurve = \atkcurve.kr(-4);
				var deccurve = \deccurve.kr(-4);
				var relcurve = \relcurve.kr(-4);
				var env = Env(
					[0, 1, suslevel, 0],
					[atk, dec, rel],
					[atkcurve, deccurve, relcurve],
					releaseNode:2
				).ar(doneAction:da, gate:gate, timeScale:ts);
				env;
			};

			var aeg = adsr.();
			var sig = inFunc.(freq, gate, aeg);

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

			var evt = node.nodeMap
			.controlNames
			.select({ arg cn;
				// we only want the params
				// from the node which have
				// corresponding controls in the synth
				specs
				.detect({arg assoc; assoc.key == cn.name})
				.isNil.not
			})
			.collect({arg cn;
				[cn.name, node.get(cn.name)]
			})
			.flatten;

			var args = [\out, node.bus.index, \gate, 1, \freq, midinote.midicps, \vel, vel] ++ evt.asPairs();
			//args.postln;
			if (synths[midinote].last.isNil) {
				synths[midinote].add( Synth(instrument, args, target:node.nodeID) );
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
			\curve1 -> [-24, 24, \lin, 0, -4],
			\curve2 -> [-24, 24, \lin, 0, -4],
			\curve3 -> [-24, 24, \lin, 0, -4],
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