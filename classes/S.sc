/*
B = buffer
E = event sequencer
F = preset morph
M = matrix
N = node
O = looper
Q = eq
S = synth
U = ui
W = workspace
*/

S : EventPatternProxy {

	classvar <>defaultRoot, <>defaultScale, <>defaultTuning, <>defaultQuant;

	var <key, <instrument, <node, <synths;

	var listenerfunc, cmdperiodfunc, <>debug;

	*new {arg key, synth;
		var res;
		res = Pdef.all[key];
		if (res.isNil) {
			res = super.new(nil).prInit(key);
			Pdef.all.put(key, res);
		};
		if (synth.isNil.not) {
			res.prInitSynth(key, synth);
			"S with key % initialied".format(key).inform;
		};
		^res;
	}

	*doesNotUnderstand {|key|
		var res = Pdef.all[key];
		if (res.isNil){
			res = S(key);
		};
		^res;
	}

	synth_ {|synth|
		this.prInitSynth(key, synth);
	}

	prInit {arg inKey;

		if (inKey.isNil) {
			Error("key not specified");
		};

		debug = false;
		key = inKey;
		synths = Array.fill(127, {List.new});

		// this isn't doing anything
		listenerfunc = {arg obj, prop, params; [prop, params.asCompileString];};
		node = Ndef(key);
		node.mold(2, \audio);

		if (this.dependants.size == 0) {
			this.addDependant(listenerfunc);
		};

		cmdperiodfunc = {
			{
				\wakeup.debug(key);
				Ndef(key).wakeUp
			}.defer(0.5)
		};
		CmdPeriod.add(cmdperiodfunc);

		// adding to envir just doesn't seem to work
		this.source = Pbind(
			\out, Pfunc({ node.bus.index }),
			\group, Pfunc({node.group})
		);

		this.set(
			\root, {defaultRoot},
			\scale, Scale.at(defaultScale).copy.tuning_(defaultTuning),
		);
		^this;
	}

	prInitSynth {arg inKey, inSynth;

		var synthdef;
		var myspecs = ();
		var ignore = [\out, \freq, \gate, \trig, \retrig, \sustain, \bend];

		instrument = inSynth;

		if (inSynth.isKindOf(Function)) {
			instrument = inKey;
			this.prBuildSynth(instrument, inSynth);
		};

		synthdef = SynthDescLib.global.at(instrument);

		if (synthdef.isNil) {
			var path = "~/projects/droptableuser/library/synths/" ++ instrument.asString ++ ".scd";
			var pathname = PathName(path.standardizePath);
			var name = pathname.fileNameWithoutExtension;
			var fullpath = pathname.fullPath;
			if (File.exists(fullpath)) {
				File.open(fullpath, "r").readAllString.interpret;
				synthdef = SynthDescLib.global.at(instrument);
			} {
				Error("synthdef not found").throw;
			}
		};

		// check the synthdef
		if (synthdef.metadata.isNil.not) {
			if (synthdef.metadata[\specs].isNil.not) {
				myspecs = synthdef.metadata[\specs]
			}
		};

		// add specs from the synth controls
		synthdef.controls
		.reject({arg ctrl;
			myspecs[ctrl.name.asSymbol].isNil.not;
		})
		.do({arg ctrl;
			// check for a matching default spec
			var key = ctrl.name.asSymbol;
			var spec = Spec.specs[key];
			if (spec.isNil) {
				var max = if (ctrl.defaultValue < 1) {1} { min(20000, ctrl.defaultValue * 2) };
				spec = [0, max, \lin, 0, ctrl.defaultValue].asSpec;
			};
			myspecs[key] = spec.default_(ctrl.defaultValue);
		});

		myspecs.keys.do({arg k;
			if (ignore.includes(k)) {
				myspecs.removeAt(k);
			};
			if (k.asString.endsWith("lfo")) {
				myspecs.removeAt(k);
			};
		});

		myspecs.keysValuesDo({arg k, v;
			this.addSpec(k, v);
		});

		this.set(\instrument, instrument);
	}

	randomize {|ignore, seed=nil, func|
		ignore = (ignore ?? []) ++ [\amp, \vel, \center, \spread];
		thisThread.randSeed = seed ?? 1000000000.rand.debug(\randseed);
		this.checkSpec
		.reject({|v,k| ignore.includes(k) })
		.keysValuesDo({|k, v|
			var val;
			if (v.warp.isKindOf(ExponentialWarp)) {
				if (v.minval > 0) {
					val = exprand(v.minval, v.maxval);
				} {
					val = rrand(v.minval, v.maxval);
				}
			}{
				val = rrand(v.minval, v.maxval);
			};

			this.set(k, val);
		});

		if (func.isNil.not) {
			func.value(this);
		}
	}

	reset {
		this.checkSpec
		.keysValuesDo({|k, v|
			var val = v.default;
			this.set(k, val);
		});
	}

	asPreset {
		^this.envir.asDict.reject({|v, k| v.isNumber.not and: v.isArray.not })
	}

	fromPreset {|preset|
		this.set(*preset.asPairs);
	}

	savePreset {|name|
		var node = this;
		var dir = App.librarydir ++ "synths/presets/";
		var synthDef = node.instrument;
		var path = dir ++ synthDef;
		var preset = node.asPreset.asCompileString;
		var file;
		if (File.exists(path).not) {
			File.mkdir(path);
		};
		path = path ++ "/" ++ name.asString ++ ".scd";
		path.postln;
		file = File(path, "w");
		file.write(preset);
		file.close;
	}

	loadPreset {|name|
		var node = this;
		var dir = App.librarydir ++ "/synths/presets/";
		var synthDef = node.instrument;
		var path = dir ++ synthDef ++ "/" ++ name.asString ++ ".scd";
		var dict = thisProcess.interpreter.executeFile(path);
		node.fromPreset(dict);
	}

	presetNames {
		var dir = App.librarydir ++ "/synths/presets/";
		var synthDef = node.instrument;
		var path = dir ++ synthDef;
		^PathName(path).entries.collect({|pn| pn.fileNameWithoutExtension})
	}

	// TODO: should clear and remove any lfo if being replaced
	pset {arg ...args;

		var pairs;
		if (args.size.even.not) {
			Error("args must be even number").throw;
		};

		pairs = args.collect({arg v, i;
			if (i.even) {
				v;
			}{
				var k = args[i-1];
				if (v.isKindOf(Function)) {
					var lfo;
					var lfokey = (this.key ++ '_' ++ k).asSymbol;
					"creating lfo node %".format(lfokey).debug(this.key);
					Ndef(lfokey, v);
				}{
					v
				}
			}
		});

		this.source = Pbind(*args)
		<>
		Pbind(\out, Pfunc({ node.bus.index }), \group, Pfunc({node.group}));
	}

	fx {arg index, func ...args;
		if (func.isNil) {
			node.put(index, func);
		}{
			if (func.isSymbol) {
				func = Library.at(\fx, func).performKeyValuePairs(\value, args);
			};
			node.put(index, \filter -> func);
		}
	}

	on {arg midinote, vel=1;
		this.prNoteOn(midinote, vel);
	}

	off {arg midinote;
		this.prNoteOff(midinote);
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

	prNoteOn {arg midinote, vel=1;

		var ignore = [\instrument,
			\root, \scale, \out, \group, \key, \dur, \legato,
			\delta, \freq, \degree, \octave, \gate, \fx, \vel];

		if (node.isPlaying) {

			var evt = this.envir
			.reject({arg v, k;
				ignore.includes(k) or: v.isKindOf(Function);
			});

			var args = [\out, node.bus.index, \gate, 1, \freq, midinote.midicps, \vel, vel] ++ evt.asPairs();

			if (debug) {
				args.postln;
			};

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

	prBuildSynth {arg inKey, inFunc;

		SynthDef(inKey, {

			var trig = Trig1.kr(\trig.tr(1), \sustain.kr(1));
			var gate = Select.kr(\retrig.kr(0), [\gate.kr(1), trig]);
			var in_freq = \freq.ar(261).lag(\glis.kr(0));
			var detune = \detunehz.kr(0.6) * PinkNoise.ar(0.007).range(0.9, 1.1);

			// bend by semitones...
			var bend = \bend.ar(0).midiratio;
			var freqbend = in_freq * bend;
			var freq = Vibrato.ar([freqbend + detune.neg, freqbend + detune], \vrate.ar(6), \vdepth.ar(0.0));

			var adsr = {
				var atk = \atk.kr(0.01);
				var dec = \dec.kr(0.1);
				var rel = \rel.kr(0.1);
				var suslevel = \suslevel.kr(1);
				var ts = \ts.kr(1);
				var curve = \curve.kr(-4);
				var env = Env.adsr(
					attackTime:atk,
					decayTime:dec,
					sustainLevel:suslevel,
					releaseTime:rel,
					curve:curve
				);
				var aeg = env.ar(doneAction:Done.none, gate:gate, timeScale:ts);
				// control life cycle of synth - this will work with both poly and mono synths
				env.ar(doneAction:Done.freeSelf, gate:\gate.kr, timeScale:ts);
				aeg;
			};

			var aeg = adsr.();
			var sig = inFunc.(freq, gate, aeg);

			sig = LeakDC.ar(sig);
			sig = sig * aeg * AmpCompA.ar(freq, 32) * \vel.kr(1);
			sig = Splay.ar(sig, \spread.kr(0), center:\center.kr(0));
			sig = sig * \amp.kr(-10.dbamp);
			Out.ar(\out.kr(0), sig);

		}).add;
	}

	*initClass {
		defaultTuning = \et12;
		defaultRoot = 4;
		defaultScale = \dorian;
		defaultQuant = 1;

		StartUp.add({
			Spec.add(\cutoff, ControlSpec(20, 20000, 'exp', 0, 100, units:"filter"));
			Spec.add(\hpf, ControlSpec(20, 20000, 'exp', 0, 20, units:"filter"));
			Spec.add(\lpf, ControlSpec(20, 20000, 'exp', 0, 20000, units:"filter"));
			Spec.add(\res, ControlSpec(0, 1.4, \lin, 0, 0.5, units:"filter"));
			Spec.add(\fvel, ControlSpec(0.001, 20, \lin, 0, 10, units:"filter"));
			Spec.add(\fatk, ControlSpec(0, 1, \lin, 0, 0.01, units:"filter"));
			Spec.add(\frel, ControlSpec(0, 8, \lin, 0, 0.29, units:"filter"));
			Spec.add(\fsuslevel, ControlSpec(0, 1, \lin, 0, 1, units:"filter"));
			Spec.add(\fcurve, ControlSpec(-8, 8, \lin, 0, -4, units:"filter"));

			Spec.add(\start, ControlSpec(0, 1, \lin, 0, 0, units:"buf"));
			Spec.add(\rate, ControlSpec(0.1, 4.0, \lin, 0, 1, units:"buf"));

			Spec.add(\atk, ControlSpec(0, 1, \lin, 0, 0.01, units:"aeg"));
			Spec.add(\dec, ControlSpec(0, 1, \lin, 0, 0.2, units:"aeg"));
			Spec.add(\rel, ControlSpec(0, 8, \lin, 0, 0.29, units:"aeg"));
			Spec.add(\suslevel, ControlSpec(0, 1, \lin, 0, 1, units:"aeg"));
			Spec.add(\curve, ControlSpec(-8, 8, \lin, 0, -4, units:"aeg"));
			Spec.add(\atkcurve, ControlSpec(-8, 8, \lin, 0, -4, units:"aeg"));
			Spec.add(\deccurve, ControlSpec(-8, 8, \lin, 0, -4, units:"aeg"));
			Spec.add(\relcurve, ControlSpec(-8, 8, \lin, 0, -4, units:"aeg"));
			Spec.add(\ts, ControlSpec(0.001, 100, \lin, 0, 1, units:"aeg"));

			Spec.add(\detunehz, ControlSpec(0, 10, \lin, 0, 0, units:"freq"));
			Spec.add(\bend, ControlSpec(-12, 12, \lin, 0, 0, units:"freq"));
			Spec.add(\vrate, ControlSpec(0, 440, \lin, 0, 6, units:"freq"));
			Spec.add(\vdepth, ControlSpec(0, 1, \lin, 0, 0, units:"freq"));
			Spec.add(\spread, ControlSpec(0, 1, \lin, 0, 1, units:"stereo"));
			Spec.add(\center, ControlSpec(-1, 1, \lin, 0, 0, units:"stereo"));
			Spec.add(\pan, ControlSpec(-1, 1, \lin, 0, 0, units:"stereo"));
			Spec.add(\vel, ControlSpec(0, 1, \lin, 0, 1, units:"vol"));
			Spec.add(\drive, ControlSpec(1, 100, \lin, 0, 1, units:"vol"));
			Spec.add(\amp, ControlSpec(0, 1, \lin, 0, -10.dbamp, units:"vol"));
		});
	}
}

B {
	classvar <all;

	*new {arg key;
		^all[key]
	}

	*doesNotUnderstand {|key|
		var res = all[key];
		if (res.isNil){
			"% does not exist".format(key).warn;
		};
		^res;
	}

	*read {arg key, path, channels=nil;
		if (channels.isNil) {
			channels = [0,1];
		}{
			channels = channels.asArray;
		};
		Buffer.readChannel(Server.default, path, channels:channels, action:{arg buf;
			all.put(key, buf);
			path.postln;
			"added buffer with key: %".format(key).inform;
		});
	}

	*open {|channels=0|
		var path = App.mediadir;
		Dialog.openPanel({|path|

			var id = PathName(path)
			.fileNameWithoutExtension
			.replace("-", "")
			.replace(" ", "")
			.replace("_", "")
			.toLower;

			B.read(id, path, channels);
		},{
			"cancelled".postln;
		}, path:path);
	}

	*initClass {
		all = IdentityDictionary();
	}
}

O : Ndef {

	var <phase;

	*new {arg key;
		var envir = this.dictFor(Server.default).envir;
		var res = envir[key];
		if (res.isNil) {
			res = super.new(key).prOInit();
		}
		^res;
	}

	*doesNotUnderstand {|key|
		var envir = this.dictFor(Server.default).envir;
		var res = envir[key];
		if (res.isNil){
			res = O(key);
		};
		^res;
	}

	phase_ {|func|
		phase = func;
		this.rebuildsynth;
	}

	prOInit {
		this.phase_({arg dur, freq, duty, rate;
			LFSaw.ar(freq, 1);
		});
		^this;
	}

	rebuildsynth {

		var func = this.phase;

		this.put(0, {

			var buf = \buf.kr(0);
			var rate = \rate.kr(1);
			var trig = \trig.tr(1);
			var replyid = \bufposreplyid.kr(-1);
			var startPos = \startPos.kr(0) * BufFrames.kr(buf);
			var endPos = \endPos.kr(1) * BufFrames.kr(buf);
			var updateFreq = 60;
			var sig;

			var dur = ( (endPos - startPos) / BufSampleRate.kr(buf) ) * rate.reciprocal;
			var duty = TDuty.ar(dur.abs, trig, 1);
			var index = Stepper.ar(duty, 0, 0, 1 );
			var phase = func.(dur, dur.reciprocal, duty, rate);
			phase = phase.range(startPos, endPos);

			/*
			var phase = Phasor.ar(duty, myrate, startPos, endPos, startPos);
			//var phase = LFSaw.ar(dur.reciprocal, 1).range(startPos, endPos);
			//var phase = LFPar.ar(dur.reciprocal * [-1, 2]).range(startPos, endPos);
			//var phase = Env([0, 0, 1], [0, dur], curve: 0).ar(gate:duty).linlin(0, 1, startPos, endPos);
			*/

			sig = BufRd.ar(1, buf, phase, 0);
			// try to remove any clicks
			//sig = SelectCF.ar(index, sig);

			SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, phase % BufFrames.kr(buf)], replyid);
			Splay.ar(sig, \spread.kr(1), center:\center.kr(0)) * \amp.kr(1);
		});

		this.wakeUp;
	}

	ngui {
		^U(\buf, this)
	}
}

// eq
Q : Ndef {

	var <guikey;

	*new {arg key;
		var envir = this.dictFor(Server.default).envir;
		var res = envir[key];
		if (res.isNil) {
			res = super.new(key).prQInit();
		}
		^res;
	}

	*doesNotUnderstand {|key|
		var envir = this.dictFor(Server.default).envir;
		var res = envir[key];
		if (res.isNil){
			"% does not exist".format(key).warn;
		};
		^res;
	}

	prQInit {

		var fromControl;

		fromControl = {arg controls;
			controls.clump(3).collect({arg item;
				[(item[0] + 1000.cpsmidi).midicps, item[1], 10**item[2]]
			});
		};

		guikey = \eq;
		this.wakeUp;
		this.play;

		this.put(100, \filter -> {arg in;

			var frdb, input = in;
			frdb = fromControl.(Control.names([\eq_controls]).kr(0!15));
			input = BLowShelf.ar(input, *frdb[0][[0,2,1]].lag(0.1));
			input = BPeakEQ.ar(input, *frdb[1][[0,2,1]].lag(0.1));
			input = BPeakEQ.ar(input, *frdb[2][[0,2,1]].lag(0.1));
			input = BPeakEQ.ar(input, *frdb[3][[0,2,1]].lag(0.1));
			input = BHiShelf.ar(input, *frdb[4][[0,2,1]].lag(0.1));
			input = RemoveBadValues.ar(input);
			input;
		});
	}
}

M : Ndef {

	var <map;
	var <slot;

	*new {arg key;
		var envir = this.dictFor(Server.default).envir;
		var res = envir[key];
		if (res.isNil) {
			res = super.new(key).prMInit();
		}
		^res;
	}

	*doesNotUnderstand {|key|
		var envir = this.dictFor(Server.default).envir;
		var res = envir[key];
		if (res.isNil){
			res = M(key);
		};
		^res;
	}

	prMInit {
		map = Order.new;
		slot = 0;
		this.wakeUp;
	}

	add {arg src, stop=false;

		var srcIndex = map.detectIndex({arg v; v == src});

		if (srcIndex.isNil) {
			srcIndex = slot;
			map.put(srcIndex, src);
			this.mix(srcIndex, Ndef(src));
			if (stop) {
				Ndef(src).stop;
			};
			slot = slot + 1;
		}
	}

	removeSrc {|src, clear=true|

		var ndef = Ndef(src);
		var index = map.indexOf(src);
		map.do({|key|
			Ndef(key).removeAt(index);
			Ndef(key).nodeMap.removeAt(src);
		});
		if (clear) {
			ndef.clear;
		};
		map.removeAt(index);
		this.removeAt(index);
	}

	mgui {
		^U(\matrix, this)
	}

	save {
		var settings = List.new;
		var parent = PathName(thisProcess.nowExecutingPath).parentPath;
		var ts = Date.getDate.asSortableString;
		var path = parent ++ this.key.asString ++ "_" ++ ts ++ ".txt";
		var file;

		this.map.do({arg val;
			var props = List.new;
			var node = Ndef(val.asSymbol);
			if (node.isKindOf(Vst) ) {
				props.add(\pdata -> node.pdata)
			}{
				node.controlNames.do({arg cn;
					props.add(cn.name.asSymbol -> node.get(cn.name.asSymbol));
				});
			};
			settings.add( val ->  props );
		});

		file = File(path, "w");
		file.write(settings.asCompileString);
		file.close;
		path.debug(\saving);
	}
}

N : Ndef {

	*new {arg key, fx;
		var envir = this.dictFor(Server.default).envir;
		var res = envir[key];
		if (res.isNil) {
			res = super.new(key).prNInit(fx);
		}
		^res;
	}

	*doesNotUnderstand {|key|
		var envir = this.dictFor(Server.default).envir;
		var res = envir[key];
		if (res.isNil){
			"% does not exist".format(key).warn;
		};
		^res;
	}

	prNInit {|argFx|

		var path = App.librarydir ++ "fx/" ++ argFx.asString ++ ".scd";
		var pathname = PathName(path.standardizePath);
		var fullpath = pathname.fullPath;

		if (File.exists(fullpath)) {

			var name = pathname.fileNameWithoutExtension;
			var obj = File.open(fullpath, "r").readAllString.interpret;
			var func = obj[\synth];
			var specs = obj[\specs];
			//this.numChannels = 2;
			//this.rate = \audio;
			this.ar(numChannels:2);
			this.wakeUp;
			this.filter(100, func);

			if (specs.isNil.not) {
				specs.do({arg assoc;
					Ndef(key).addSpec(assoc.key, assoc.value);
				});
			};
		} {
			Error("node not found").throw;
		}
		^this;
	}

	*ls {arg path;
		// this could be nicer
		var mypath = path ? App.librarydir ++ "fx/";
		PathName.new(mypath)
		.entries.do({arg e; e.fullPath.postln;});
	}
}

U {
	*new {arg key ...args;

		var path = App.librarydir ++ "ui/" ++ key.asString ++ ".scd";
		var pathname = PathName(path.standardizePath);
		var fullpath = pathname.fullPath;
		if (File.exists(fullpath)) {
			var name = pathname.fileNameWithoutExtension;
			File.open(fullpath, "r").readAllString.interpret;
			Fdef(key).value(*args);
		} {
			Error("node not found").throw;
		};
	}

	*ls {arg path;
		// this could be nicer
		var mypath = path ? App.librarydir ++ "ui/";
		PathName.new(mypath)
		.entries.do({arg e; e.fullPath.postln;});
	}
}

E {
	var <>events, <>duration;

	*new {
		^super.new.init();
	}

	*fromPattern {|pattern, duration|
		var seq = E();
		seq.events = E.order(pattern, duration);
		seq.duration = duration;
		^seq;
	}

	init {
		^this;
	}

	*order {|pattern, duration|
		var order = Order.new;
		var time = 0;
		var stream = pattern.asStream;
		var evt = stream.next(Event.default);
		while ( {evt.isNil.not and: (time < duration) }, {
			var dur = evt[\dur];
			if ((time + dur) > duration) {
				dur = duration - time;
				evt[\dur] = dur;
			};
			order.put(time, evt);
			time = time + dur;
			evt = stream.next(evt);
		});
		^order;
	}

	put {|time, event|
		// need to handle adding to beginning and end of sequence
		if (time > this.duration) {
			"time is greater than duration".error;
		} {
			var nextIndex = this.events.nextSlotFor(time);
			var prevIndex = nextIndex-1;
			var prevTime = this.events.indices[prevIndex];
			var prevEvent = this.events.array[prevIndex];
			var nextTime = this.events.indices[nextIndex];
			var dur = nextTime - time;
			prevEvent[\dur] = time - prevTime;
			event[\dur] = dur;
			this.events.put(time, event);
		}
	}

	remove {|time|
		var nextIndex = events.nextSlotFor(time);
		var prevIndex = nextIndex-2;
		var prevTime = events.indices[prevIndex];
		var prevEvent = events.array[prevIndex];
		var nextTime = events.indices[nextIndex];
		var dur = nextTime - prevTime;
		prevEvent[\dur] = dur;
		events.removeAt(time);
	}

	copy {
		var eventsCopy = this.events.collect({|evt| evt.copy});
		var seq = E();
		seq.events = eventsCopy;
		^seq;
	}

	perform {|selector ...args|
		var pseq, order;
		var array = this.events.array.perform(selector, *args);
		pseq = Pseq(array, inf);
		order = E.order(pseq, this.duration);
		this.events = order;
	}

	set {|pattern, duration|
		this.events = E.order(pattern, duration);
		this.duration = duration;
	}

	asArray {
		^events.array;
	}

	asStream {|repeats=inf|

		^Prout({|inevent|
			repeats.do({|i|
				var evts = this.asArray.collect({|evt| evt.copy});
				var seq = Pseq(evts, 1).asStream;
				var next = seq.next(inevent);
				while ({ next.isNil.not}, {
					next.yield;
					next = seq.next(inevent)
				})
			});
		})
	}
}


F {
	*morph {|node, from, to, numsteps=20, wait=0.1|
		Routine({
			var numsteps = 20;
			var fromCopy = from.copy;
			numsteps.do({|i|
				var blend = 1 + i / numsteps;
				fromCopy = fromCopy.blend(to, blend);
				node.set(*fromCopy.getPairs);
				wait.wait;
			});
			\morphdone.debug(node.key);
		}).play;
	}
}


W : Environment {

	classvar <all;

	var <key, <>daw;

	*new {|key|
		var res = all[key];
		if (res.isNil) {
			res = super.new(8, nil, nil, true).prWInit(key);
			all[key] = res;
		};
		^res;
	}

	*doesNotUnderstand {|key|
		var res = all[key];
		if (res.isNil){
			res = W(key);
		};
		^res;
	}

	prWInit {|argKey|
		var path = "%%/".format(App.workspacedir, key);
		if (File.exists(path).not) {
			"init workspace %".format(path).inform;
			File.makeDir(path);
		};
		key = argKey;
		daw = \bitwig;
		this.recdir;
		^this;
	}

	record {
		if (daw == \bitwig) {
			Bitwig.record;
		};
		if (daw == \reaper) {
			Reaper.record
		}
	}

	stopRecording {
		if (daw == \bitwig) {
			Bitwig.stop;
		};
		if (daw == \reaper) {
			Reaper.stopRecording;
		}
	}

	tempo {|bps=1|
		if (daw == \bitwig) {
			Bitwig.tempo(bps)
		};
		if (daw == \reaper) {
			Reaper.tempo(bps)
		}
	}

	time {|val=0|
		if (daw == \bitwig) {
			Bitwig.time(val)
		};
		if (daw == \reaper) {
			Reaper.time(val);
		}
	}

	recdir {
		var path = App.workspacedir ++ key;
		path.debug(\recordingsDir);
		thisProcess.platform.recordingsDir_(path);
	}

	save {|rec=true|

		var folder = App.workspacedir;
		var workspace = "%/%-%-%/%%".format(key,
			Date.getDate.year, Date.getDate.month, Date.getDate.day, Date.getDate.hour, Date.getDate.minute);
		var current_doc = Document.current;
		var current_path = folder.standardizePath ++ workspace;
		var dirname;

		if (File.exists(current_path).not) {
			File.mkdir(current_path);
		};

		Document.openDocuments.do({arg doc;
			var file_name = PathName(doc.title);
			var path = current_path ++ "/_wip_" ++ file_name.fileName;
			var content = doc.string;
			var file = File(path, "w");
			path.debug("writing...");
			file.write(content);
			file.close();
		});

		if (rec) {
			var tempo = TempoClock.default.tempo;
			Server.default.record(current_path ++ "/SC_" ++ Date.getDate.stamp ++ ".aiff");
		}
	}

	saveResource {|name, content|
		var file, path;
		var dir = "%%/%/".format(App.workspacedir, key.asString, "resources");
		if (File.exists(dir).not) {
			File.mkdir(dir);
		};
		path = "%%.scd".format(dir, name);
		\saving.debug(path);
		if (content.isString.not) {
			content = content.asCompileString;
		};
		file = File(path, "w");
		file.write(content);
		file.close;
	}

	loadResource {|name|
		var path = "%%/%/%.scd".format(App.workspacedir, key.asString, "resources", name);
		var obj = thisProcess.interpreter.executeFile(path);
		^obj
	}

	ls {
		var path = "%%%".format(App.workspacedir, key.asString, "/resources/");
		^PathName(path).entries.collect({|pn| pn.fileNameWithoutExtension})
	}

	*initClass {
		all = IdentityDictionary();
	}

}