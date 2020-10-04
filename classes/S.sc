/*
B = buffer
E = event sequencer
L = launcher
M = matrix
N = node
O = looper
P = presets
Q = eq
S = synth
U = ui
V = vst
W = workspace
*/

Device : Ndef {

	*new {|key|
		var envir = this.dictFor(Server.default).envir;
		var res = envir[key];
		if (res.isNil) {
			res = this.createNew(key).deviceInit();
			res.vol = 1;
		}
		^res;
	}

	*createNew {|...args|
		^super.new(*args);
	}

	*doesNotUnderstand {|selector|
		^this.new(selector);
	}

	deviceInit {
		// override to initialize
	}

	save {|path|

	}

	out_ {|bus=0|
		this.monitor.out = bus;
	}

	getSettings {
		^this.getKeysValues.flatten.asDict;
	}

	addPreset {|num|
		P.addPreset(this, num, this.getSettings);
	}

	loadPreset {|num|
		var preset = P.getPreset(this, num);
		this.set(*preset.getPairs);
	}

	getPresets {
		^P.getPresets(this);
	}

	morph {|from, to, numsteps=20, wait=0.1|
		P.morph(this, from, to, numsteps, wait);
	}

	/*
	NOTE: defined extension on NodeProxy for view
	override on subclass
	view {}
	*/
}

/*
Buffer
*/
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
			"added buffer with key: %; %".format(key, path).inform;
		});
	}

	*mono {|key, path|
		B.read(key, path, 0);
	}

	*alloc {|key, numFrames, numChannels=1|
		var buf = Buffer.alloc(Server.default, numFrames, numChannels);
		all.put(key, buf);
		"allocated buffer with key: %".format(key).inform;
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

/*
basically stolen and adapted from https://github.com/scztt/OSequence.quark
*/
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
		seq.duration = this.duration;
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

/*
Launcher
*/
L {
	*new {|...args|
		^U(\launch, args);
	}
}

/*
Matrix
*/
M : Device {

	var <map;
	var <slot;

	deviceInit {
		map = Order.new;
		slot = 0;
		this.wakeUp;
	}

	view {
		^U(\matrix, this)
	}

	addSrc {arg src, stop=false;

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

	save {
		var settings = List.new;
		var parent = PathName(thisProcess.nowExecutingPath).parentPath;
		var ts = Date.getDate.asSortableString;
		var path = parent ++ this.key.asString ++ "_" ++ ts ++ ".txt";
		var file;

		this.map.do({arg val;

			//var node = Ndef(val.asSymbol);
			//var path = "";
			//node.save(path);

			/*
			var props = List.new;
			if (node.isKindOf(V) ) {
				props.add(\pdata -> node.pdata)
			}{
				node.controlNames.do({arg cn;
					props.add(cn.name.asSymbol -> node.get(cn.name.asSymbol));
				});
			};
			settings.add( val ->  props );
			*/
		});

		/*
		file = File(path, "w");
		file.write(settings.asCompileString);
		file.close;
		path.debug(\saving);
		*/
	}
}

/*
Node
*/
N : Device {

	var <uifunc, fx;

	fx_ {|name|
		fx = name;
		this.prBuild;
	}

	ui {
		if (uifunc.isNil.not) {
			^uifunc.(this);
		} {
			^U(\ngui, this);
		}
	}

	prBuild {
		var path = App.librarydir ++ "fx/" ++ fx.asString ++ ".scd";
		var pathname = PathName(path.standardizePath);
		var fullpath = pathname.fullPath;

		if (File.exists(fullpath)) {

			var name = pathname.fileNameWithoutExtension;
			var obj = File.open(fullpath, "r").readAllString.interpret;
			var func = obj[\synth];
			var specs = obj[\specs];
			uifunc = obj[\ui].debug(\ui);
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
	}

	*ls {arg dir;
		var path = App.librarydir ++ dir;
		PathName.new(path.asString)
		.entries.do({arg e; e.fullPath.postln;});
	}
}

/*
Looper
*/
O : Device {

	var <phase;

	phase_ {|func|
		phase = func;
		this.prBuild;
	}

	deviceInit {
		// this will call rebuild
		this.phase_({arg dur, freq, duty, rate;
			LFSaw.ar(freq, 1);
		});
	}

	prBuild {

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

	view {
		^U(\buf, this)
	}
}

/*
Presets
*/
P {
	*addPreset {|node, num, preset|
		var key = node.key;
		var presets = Halo.at(key);
		if (presets.isNil) {
			presets = Order.new;
			Halo.put(key, presets);
		};
		presets.put(num, preset);
	}

	*getPresets {|node|
		var key = node.key;
		var presets = Halo.at(key);
		if (presets.isNil) {
			presets = Order.new;
			Halo.put(key, presets);
		}
		^presets
	}

	*getPreset {|node, num|
		var key = node.key;
		var presets = P.getPresets(node);
		^presets[num];
	}

	*morph {|node, from, to, numsteps=20, wait=0.1|
		var key = node.key;
		Routine({
			var presets = P.getPresets(node);
			var numsteps = 20;
			var fromCopy = presets[from].copy;
			var toPreset = presets[to];
			numsteps.do({|i|
				var blend = 1 + i / numsteps;
				fromCopy = fromCopy.blend(toPreset, blend);
				node.set(*fromCopy.getPairs);
				wait.wait;
			});
			\morph_done.debug(key);
		}).play;
	}
}

/*
EQ
*/
Q : Device {

	var <guikey;

	deviceInit {

		var fromControl;
		fromControl = {arg controls;
			controls.clump(3).collect({arg item;
				[(item[0] + 1000.cpsmidi).midicps, item[1], 10**item[2]]
			});
		};

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

	view {
		^U(\eq, this)
	}
}

/*
Synth
*/
S : EventPatternProxy {

	classvar <>defaultRoot, <>defaultScale, <>defaultTuning, <>defaultQuant;

	var <key, <instrument, <node, <synths;

	var listenerfunc, cmdperiodfunc, <>debug, <out;

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

	out_ {|bus=0|
		out = bus;
		this.node.monitor.out = out;
	}

	monitor {|fadeTime=0.02|
		this.node.play(fadeTime:fadeTime);
	}

	mute {|fadeTime=0.02|
		this.node.stop(fadeTime:fadeTime)
	}

	embedInStream {|inval, embed = true, default|

		if (this.node.isMonitoring.not) {
			this.node.play(fadeTime:fadeTime);
		};
		super.embedInStream(inval, embed, default);
	}

	play {|fadeTime=0.02, argClock, protoEvent, quant, doReset=false|

		if (this.node.isMonitoring.not) {
			this.node.play(fadeTime:fadeTime);
		};
		super.play(argClock, protoEvent, quant, doReset);
	}

	stop {|fadeTime=0.02|
		this.node.stop(fadeTime:fadeTime);
		super.stop;
	}

	getSettings {
		^this.envir.asDict;
	}

	addPreset {|num|
		P.addPreset(this, num, this.getSettings);
	}

	loadPreset {|num|
		var preset = P.getPreset(this, num);
		this.set(*preset.getPairs);
	}

	getPresets {
		^P.getPresets(this);
	}

	getPreset {|num|
		^P.getPreset(this, num);
	}

	prInit {arg inKey;

		if (inKey.isNil) {
			Error("key not specified");
		};

		debug = false;
		key = inKey;
		synths = Array.fill(127, {List.new});

		// this isn't doing anything
		//listenerfunc = {arg obj, prop, params; [prop, params.asCompileString];};
		node = Ndef(key);
		node.mold(2, \audio);
		node.play;

		//if (this.dependants.size == 0) {
		//	this.addDependant(listenerfunc);
		//};

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
			\root, defaultRoot,
			\scale, Scale.at(defaultScale).copy.tuning_(defaultTuning),
			\amp, 0.3
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
			this.set(k, v.default)
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
		Pbind(\out, Pfunc({node.bus.index}), \group, Pfunc({node.group}));
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
			sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
			sig = sig * \amp.kr(-6.dbamp);
			Out.ar(\out.kr(0), sig);

		}).add;
	}

	*initClass {
		defaultTuning = \et12;
		defaultRoot = 4;
		defaultScale = \dorian;
		defaultQuant = 1;
	}
}

/*
UI
*/
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

	*ls {arg dir;
		var path = App.librarydir ++ "ui/" ++ dir;
		PathName.new(path)
		.entries.do({arg e; e.fullPath.postln;});
	}
}

/*
Vst
*/
V : Device {

	var <fx, <pdata, <synth, <vst;

	var <skipjack;

	vst_ {|name|
		vst = name;
		this.prBuild;
	}

	prBuild {

		var func;
		var store = {
			if (fx.isNil.not) {
				//\store.debug(name);
				fx.getProgramData({ arg data; pdata = data;}, async:true);
			}
		};

		var index = 100;
		var synthdef = (vst ++ UniqueID.next).asSymbol;

		/*
		Routine({
			Server.default.sync;
			this.put(index, synthdef.debug(\synthdef));
		}).play;
		*/

		func = {

			Routine({

				SynthDef.new(synthdef, {arg in;
					var sig = In.ar(in, 2);
					var wet = ('wet' ++ index).asSymbol.kr(1);
					XOut.ar(in, wet, VSTPlugin.ar(sig, 2));
				}).add;

				Server.default.sync;
				this.put(index, synthdef.debug(\synthdef));

				// this seems necessary, but not sure why
				//this.wakeUp;
				synth = Synth.basicNew(synthdef, Server.default, this.objects[index].nodeID);
				synth.set(\in, this.bus.index);
				fx = VSTPluginController(synth);

				1.wait;
				// there can be a delay
				fx.open(vst.asString, verbose:true, editor:true);
				vst.debug(\loaded);

				//1.wait;
				//if (pdata.isNil.not) {
				//	fx.setProgramData(pdata);
				//};

				this.wakeUp;

			}).play;
		};

		func.();
		//skipjack = SkipJack(store, 60, { fx == nil }, name: key);
		CmdPeriod.add(func);
		^this;
	}

	*directory {
		var result = List.new;
		VSTPlugin.search(verbose:false);
		VSTPlugin.readPlugins.keysValuesDo({arg k, v; result.add(k)});
		^result.asArray;
	}

	editor {
		^fx.editor;
	}

	vgui {
		^fx.gui;
	}

	browse {
		fx.browse;
	}

	snapshot {
		fx.getProgramData({ arg data; pdata = data;});
	}

	restore {
		fx.setProgramData(pdata);
	}

	bypass {arg bypass=0;
		synth.set(\bypass, bypass)
	}

	parameters {
		^fx.info.printParameters
	}

	settings {|cb|
		var vals = ();
		var parms = fx.info.parameters;
		this.fx.getn(action: {arg v;
			v.do({|val, i|
				var name = parms[i][\name];
				vals[name] = val;
			});
			cb.(vals);
		});
	}

	clear {
		//skipjack.stop;
		//SkipJack.stop(key);
		synth.free;
		fx.close;
		fx = nil;
		super.clear;
	}
}

/*
Workspace
*/
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

	*recdir {
		var path = Document.current.dir;
		thisProcess.platform.recordingsDir_(path.debug(\recdir));
	}

	*mixer {
		var m = NdefMixer(Server.default);
		ProxyMeter.addMixer(m);
		m.switchSize(0);
		^m;
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
			var ext = Server.default.recHeaderFormat;
			Server.default.record(current_path ++ "/SC_" ++ Date.getDate.stamp ++ "." ++ ext);
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

/*

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
*/