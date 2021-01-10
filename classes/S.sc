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

			res.wakeUp;
			res.ar(numChannels:2);
			res.play;
			res.filter(200, {|in| LPF.ar(in, \lpf.kr(20000).lag(0.01) )});
			res.filter(300, {|in| HPF.ar(in, \hpf.kr(20).lag(0.01) )});
			res.filter(400, {|in|

				// adapted from https://github.com/21echoes/pedalboard/blob/master/lib/fx/Compressor.sc
				var sig = HPF.ar(in, 25);
				var drive = \compress.kr(0.5);
				var ratio = LinExp.kr(drive, 0, 1, 0.25, 0.05);
				var threshold = LinLin.kr(drive, 0, 1, 0.9, 0.5);
				var gain = 1/(((1.0-threshold) * ratio) + threshold);
				gain = Select.kr(drive > 0.9, [
					gain,
					gain * LinExp.kr(drive, 0.9, 1, 1, 1.2);
				]);

				sig = Compander.ar(
					sig, sig,
					threshold,
					1.0,
					ratio,
					\clamp.kr(0.005),
					\relax.kr(0.1),
					gain
				);
				sig;
			});

			res.filter(500, {|in| SoftClipAmp8.ar(in, \limit.kr(1) )});
			// use units to try to keep things together and provide sort hints
			res.addSpec(\lpf, ControlSpec(20, 20000, \lin, 0, 20000, "xxfilter"));
			res.addSpec(\wet200, ControlSpec(0, 1, \lin, 0, 1, "xxfilter"));

			res.addSpec(\hpf, ControlSpec(20, 10000, \lin, 0, 20, "xxfilter"));
			res.addSpec(\wet300, ControlSpec(0, 1, \lin, 0, 1, "xxfilter"));

			res.addSpec(\compress, ControlSpec(0, 1, \lin, 0, 0.5, "yycompress"));
			res.addSpec(\clamp, ControlSpec(0, 1, \lin, 0, 0.005, "yycompress"));
			res.addSpec(\relax, ControlSpec(0, 1, \lin, 0, 0.1, "yycompress"));
			res.addSpec(\wet400, ControlSpec(0, 1, \lin, 0, 0, "yycompress"));

			res.addSpec(\limit, ControlSpec(0, 1, \lin, 0, 1.0, "zzsoftclip"));
			res.addSpec(\wet500, ControlSpec(0, 1, \lin, 0, 1, "zzsoftclip"));

			res.set(\wet400, 0);
			res.set(\wet500, 1);
			res.vol = 1;

			res.postInit;

			ServerTree.add({
				\cmdperiod.debug(key);
				res.send;
			});
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

	postInit {
		// override to initialize after int
	}

	save {|path|

	}

	out_ {|bus=0|
		this.monitor.out = bus;
	}

	/*
	should come from NodeProxy extension
	getSettings {
		^this.getKeysValues.flatten.asDict;
	}
	*/

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

	*free {
		all.keys.do({|k|
			all[k].free;
			all.removeAt(k);
		});
	}

	*dirMono {|path|
		var paths = "%/*.wav".format(path).pathMatch ++ "%/*.aif".format(path).pathMatch;
		var obj = ();
		paths.do({|path|
			var pn = PathName(path);
			var key = pn.fileNameWithoutExtension.replace(" ", "").toLower().asSymbol;
			Buffer.readChannel(Server.default, path, channels:[0], action:{arg buf;
				obj[key] = buf;
			});
		});
		^obj
	}

	dirWt {|path|
		var obj = (
			bufs: (),
			nums: List[]
		);
		var wtsize = 4096;
		var wtpaths = "%/**.wtable".format(path).pathMatch;
		var wtbuffers = Buffer.allocConsecutive(wtpaths.size, Server.default, wtsize * 2, 1);
		wtpaths.do {|it i|
			wtbuffers[i].read(wtpaths[i])
		};
		wtpaths.do {|it i|
			var name = wtbuffers[i].path.basename.findRegexp(".*\.wav")[0][1].splitext[0];
			var buffer = wtbuffers[i].bufnum;
			obj[\bufs][name.asSymbol] = buffer;
			obj[\nums].add(buffer);
		};
		obj
	}

	// adapted from here:
	//https://github.com/alikthename/Musical-Design-in-Supercollider/blob/master/5_wavetables.sc
	// run once to convert and resample wavetable files
	convertWt {|path|
		var paths, file, data, n, newData, outFile;
		paths = "%/*.wav".format(path).pathMatch;

		Routine({
			paths.do { |it i|
				// 'protect' guarantees the file objects will be closed in case of error
				protect {

					var path;
					// Read original size of data
					file = SoundFile.openRead(paths[i]);
					data = Signal.newClear(file.numFrames);
					file.readData(data);
					0.1.wait;
					// Convert to n = some power of 2 samples.
					// n = data.size.nextPowerOfTwo;
					n = 4096;
					newData = data.resamp1(n);
					0.1.wait;
					// Convert the resampled signal into a Wavetable.
					// resamp1 outputs an Array, so we have to reconvert to Signal
					newData = newData.as(Signal).asWavetable;
					0.1.wait;

					// save to disk.
					path = paths[i].replace("media/AKWF", "media/AKWF-converted");
					path.postln;
					outFile = SoundFile(path ++ "_4096.wtable")
					.headerFormat_("WAV")
					.sampleFormat_("float")
					.numChannels_(1)
					.sampleRate_(44100);
					if(outFile.openWrite.notNil) {
						outFile.writeData(newData);
						0.1.wait;
					} {
						"Couldn't write output file".warn;
					};
				} {
					file.close;
					if(outFile.notNil) { outFile.close };
				};
			}
		}).play
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
	*new {|patterns, clock|
		^U(\launch, patterns, clock);
	}
}

/*
Matrix
*/
M : Device {

	var <map;

	var <slot;

	var <outbus;

	deviceInit {
		map = Order.new;
		slot = 0;
		outbus = Bus.audio(Server.default, 2);
	}

	postInit {
		this.put(0, { InFeedback.ar(outbus.index, 2) });
	}

	view {
		^U(\matrix, this)
	}

	addSrc {|srcNode|

		var srcIndex = map.detectIndex({|v|
			//[\v, v, \srcNode, srcNode].debug(\m_addsrc);
			v.key == srcNode.key
		});
		if (srcIndex.isNil) {
			srcIndex = slot;
			//srcNode.parentGroup = this.group;
			srcNode.monitor.out = outbus.index;
			map.put(srcIndex, srcNode);
			slot = slot + 1;
		};
		this.changed(\add, srcNode);
	}

	removeSrc {|key|

		// TODO: does this destroy the node?
		map.keysValuesDo({|k, v|
			if (v.key == key) {
				map.do({|obj|
					if (obj.respondsTo(\removeAt)){
						obj.removeAt(k);
					};
					if (obj.respondsTo(\nodeMap)) {
						obj.nodeMap.removeAt(key);
					}
				});
				map.removeAt(k);
				this.changed(\remove, key);
			}
		});
	}

	/*
	*initClass {
		all = IdentityDictionary();
	}
	*/

	/*
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
	*/
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

	view {
		^U(\ngui, this, uifunc.(this));
	}

	*loadFx {|fx|
		var path = App.librarydir ++ "fx/" ++ fx.asString ++ ".scd";
		var pathname = PathName(path.standardizePath);
		var fullpath = pathname.fullPath;

		if (File.exists(fullpath)) {
			var name = pathname.fileNameWithoutExtension;
			var obj = File.open(fullpath, "r").readAllString.interpret;
			^obj
		} {
			Error("node not found").throw;
		}
	}

	prBuild {
		var obj = N.loadFx(fx);
		var func = obj[\synth];
		var specs = obj[\specs];
		uifunc = obj[\ui];
		this.filter(100, func);
		if (specs.isNil.not) {
			specs.do({arg assoc;
				this.addSpec(assoc.key, assoc.value);
			});
		};
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

	/*
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
	*/

	deviceInit {

		this.put(0, {

			var updateFreq = 10;
			var replyid = \bufposreplyid.kr(-1);
			var buf = \buf.kr(0);
			var lag = \lag.kr(1);
			var rate = \rate.kr(1).lag(lag);
			var startPos = \startPos.kr(0).lag(0.01);
			var endPos = \endPos.kr(1).lag(0.01);

			var cuePos = \cuePos.kr(0);
			var trig = \trig.tr(0);

			var phase, sig;
			#sig, phase = LoopBufCF.ar(numChannels:1,
				bufnum:buf,
				rate:rate,
				trigger:trig,
				startPos:startPos,
				endPos:endPos,
				resetPos:cuePos,
				ft:\ft.kr(0.05));

			SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, phase % BufFrames.kr(buf)], replyid);
			Splay.ar(sig, \spread.kr(1), center:\pan.kr(0)) * \amp.kr(1);
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

	classvar <>defaultRoot, <>defaultScale, <>defaultTuning;

	var <key, <instrument, <node, <synths;

	var <>hasGate, <synthdef;

	var listenerfunc, cmdperiodfunc, <>debug, <out;

	*new {arg key, synth, template=\adsr;
		var res;
		res = Pdef.all[key];
		if (res.isNil) {
			res = super.new(nil).prInit(key);
			Pdef.all.put(key, res);
		};
		if (synth.isNil.not) {
			res.prInitSynth(key, synth, template);
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

	*def {|inKey, inFunc, inTemplate=\adsr|
		var path = App.librarydir ++  "templates/" ++ inTemplate.asString ++ ".scd";
		var pathname = PathName(path.standardizePath);
		var fullpath = pathname.fullPath;
		if (File.exists(fullpath)) {
			var template = File.open(fullpath, "r").readAllString.interpret;
			template.(inKey, inFunc);
		} {
			Error("synth template not found").throw;
		}
	}

	*loadSynths {
		var path = App.librarydir.standardizePath ++ "synths/*.scd";
		"loading synths: %".format(path).debug;
		path.loadPaths;
	}

	synth {|synth, template=\adsr|
		this.prInitSynth(key, synth, template);
		^this;
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

		var monitor = this.envir[\monitor];
		if (monitor.isNil.not and: {monitor.not}) {
			this.node.stop;
		}{
			if (this.node.isMonitoring.not) {
				this.node.play(fadeTime:fadeTime);
			};
		};
		super.embedInStream(inval, embed, default);
	}

	play {|fadeTime=0.02, argClock, protoEvent, quant, doReset=false|

		var monitor = this.envir[\monitor];
		if (monitor.isNil.not and: {monitor.not}) {
			this.node.stop;
		}{
			if (this.node.isMonitoring.not) {
				this.node.play(fadeTime:fadeTime);
			};
		};
		super.play(argClock, protoEvent, quant, doReset);
	}

	/*
	stop {|fadeTime=0.02|
		this.node.stop(fadeTime:fadeTime);
		super.stop;
	}
	*/

	getSettings {
		^this.envir.asDict;
	}

	postSettings {
		var str = "(\nvar settings = " ++ this.getSettings.asCompileString ++ ";\nS.%.set(*settings.getPairs);\n)".format(this.key);
		str.postln;
	}

	/*
	addPreset {|num|
		P.addPreset(this, num, this.getSettings);
	}

	loadPreset {|num|
		var preset = P.getPreset(this, num);
		this.set(*preset.getPairs);
	}

	removePreset {|num|
		var presets = P.getPresets(this);
		if (presets.isNil.not) {
			presets.removeAt(num)
		};
	}

	getPresets {
		^P.getPresets(this);
	}

	getPreset {|num|
		^P.getPreset(this, num);
	}
	*/

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

		this.source = Pbind(*pairs)
		<>
		Pbind(\out, Pfunc({node.bus.index}), \group, Pfunc({node.group}));
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
		//if (node.group.isNil.not) {
		//	node.group.free;
		//}
	}

	prInit {arg inKey;

		if (inKey.isNil) {
			Error("key not specified");
		};

		debug = false;
		key = inKey;
		synths = Array.fill(127, {List.new});

		node = Device(key);
		node.mold(2, \audio);
		node.play;

		cmdperiodfunc = {
			{
				\cmdperiod.debug(key);
				Ndef(key).wakeUp
			}.defer(0.5)
		};
		ServerTree.add(cmdperiodfunc);

		// adding to envir just doesn't seem to work
		this.source = Pbind(
			\out, Pfunc({node.bus.index}),
			\group, Pfunc({node.group})
		);

		this.set(
			\root, defaultRoot,
			\scale, Scale.at(defaultScale).copy.tuning_(defaultTuning),
			\amp, -10.dbamp
		);

		^this;
	}

	prInitSynth {arg inKey, inSynth, inTemplate=\adsr;

		//var synthdef;
		var myspecs = ();
		var ignore = [\out, \freq, \gate, \trig, \retrig, \sustain, \bend];

		instrument = inSynth;

		if (inSynth.isKindOf(Function)) {
			instrument = inKey;
			S.def(instrument, inSynth, inTemplate);
		};

		synthdef = SynthDescLib.global.at(instrument);

		if (synthdef.isNil) {
			var path = App.librarydir ++  "synths/" ++ instrument.asString ++ ".scd";
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

		hasGate = synthdef.hasGate;
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
			// this sets all the properties in the environment
			// so they can be read from the ui
			this.set(k, v.default)
		});

		this.set(\instrument, instrument);
	}

	prNoteOn {arg midinote, vel=1;


		/*
1. "I want instantaneous, zero-latency transitions: when I hit the button on my controller, I want my playing event to immediately end and the next one to start. I don’t care about note durs / deltas at all."

This case is addressed in the linked question, and some other places. If you want full manual control simply pull notes from your event stream and play them yourself:

~stream = Pdef(\notes).asStream;

~stream.next(()).play; // next event
~stream.next(()).play; // next event
~stream.next(()).play; // next event
One gotcha: you must have (\sendGate, false) in your event, else Event:play will automatically end the Event after \dur beats.
		*/

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

			if (hasGate) {
				if (synths[midinote].last.isNil) {
					synths[midinote].add( Synth(instrument, args, target:node.nodeID) );
				}
			} {
				Synth(instrument, args, target:node.nodeID)
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

	/*
	prBuildSynth {arg inKey, inFunc, inTemplate=\adsr;
		var path = App.librarydir ++  "templates/" ++ inTemplate.asString ++ ".scd";
		var pathname = PathName(path.standardizePath);
		var fullpath = pathname.fullPath;
		if (File.exists(fullpath)) {
			var template = File.open(fullpath, "r").readAllString.interpret;
			template.(inKey, inFunc);
		} {
			Error("synth template not found").throw;
		}
	}
	*/

	*initClass {
		defaultTuning = \et12;
		defaultRoot = 4;
		defaultScale = \dorian;
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


V : Device {

	var <>fx, <>synth, <vst;

	var <onload;

	load {|name, func|
		var index = 100;
		vst = name;
		onload = func;
		V.prFunc(index, this, vst, {|fx, synth| this.fx = fx; this.synth = synth;}, onload);
	}

	*prFunc {|index, node, vst, cb, onload|

		var fx, synth;

		var func = {

			Routine({
				node.wakeUp;
				node.send;
				node[index] = \vst.debug(\synthdef);
				synth = Synth.basicNew(\vst, Server.default, node.objects[index].nodeID);
				Server.default.latency.wait;
				synth.set(\in, node.bus.index);
				fx = VSTPluginController(synth);
				Server.default.latency.wait;
				fx.open(vst.asString, verbose:true, editor:true);
				//Server.default.latency.wait;
				// don't understand this but it is necessary
				// to get the paramcache populated
				fx.addDependant(node);
				cb.(fx, synth);
				if (onload.isNil.not) {
					{ onload.(fx) }.defer(2);
				};

			}).play;
		};

		func.();
		ServerTree.add(func);
	}

	*ls {
		var result = List.new;
		VSTPlugin.search(verbose:false);
		VSTPlugin.readPlugins.keysValuesDo({arg k, v; result.add(k) });
		result.sort.do({|val| val.postln;});
		^result;
	}

	set {|key, val|

		if ( fx.isNil.not and: { fx.info.parameters
			.collect({|dict| dict['name'].asSymbol })
			.includes(key) }
		) {
			fx.set(key, val);
		}{
			super.set(key, val);
		}
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

	/*
	snapshot {
		fx.getProgramData({ arg data; pdata = data;});
	}
	*/

	/*
	restore {
		fx.setProgramData(pdata);
	}
	*/

	bypass {arg bypass=0;
		synth.set(\bypass, bypass)
	}

	parameters {
		^fx.info.printParameters
	}

	settings {|cb|
		var vals = ();
		var parms = fx.info.parameters;
		fx.getn(action: {arg v;
			v.do({|val, i|
				var name = parms[i][\name];
				vals[name] = val;
			});
			cb.(vals);
		});
	}

	getSettings {
		var params = fx.info.parameters;
		var cache = fx.paramCache;
		var vals = ();
		params.do({|p, i|
			vals[p['name'].asSymbol] = cache[i][0];
		});
		vals = vals ++ this.getKeysValues.flatten.asDict;
		^vals;
	}

	clear {
		//skipjack.stop;
		//SkipJack.stop(key);
		synth.free;
		synth.release;
		fx.close;
		fx = nil;
		fx.removeDependant(this);
		super.clear;
	}

	*initClass {
		StartUp.add({
			SynthDef.new(\vst, {arg in;
				var sig = In.ar(in, 2);
				//var wet = ('wet100').asSymbol.kr(1);
				//XOut.ar(in, wet, VSTPlugin.ar(sig, 2));
				ReplaceOut.ar(in, VSTPlugin.ar(sig, 2));
			}).add;
		});
	}
}

/*
Workspace
*/
W : Environment {

	classvar <all, <>clock;

	var <key, <>daw;

	var <matrix;

	var <node;

	var <group, <bus;

	var cmdperiod;

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

	prSetTree {
		var me = this;
		{
			\prSetTree.debug(me.key);
			me.keysValuesDo({|k, v|
				if (v.respondsTo(\parentGroup)) {
					v.parentGroup = me.node.group;
					v.monitor.out = me.node.bus.index;
				}{
					v.node.parentGroup = me.node.group;
					v.node.monitor.out = me.node.bus.index;
				}
			})
		}.defer(2);
		//TODO: Trying to gracefully handle a cmdperiod
		// two seconds is a long time to wait but need to provide
		// time for VSTs to be reloaded before setting
		// their tree structure. I'm not sure what events
		// to wait for to make this a bit more robust
	}

	put {|key, value|
		super.put(key, value);
		this.prSetTree;
		this.changed(\add, key -> value);
		this.matrix.addSrc(value);
	}

	removeAt {|key|
		super.removeAt(key);
		this.changed(\remove, key);
		this.matrix.removeSrc(key);
	}

	init {|cb|
		var me = this;
		this.use(cb);
		this.prSetTree;
		this.keysValuesDo({|k, v|
			me.matrix.addSrc(v);
		})
	}

	view {
		^U(\workspace, this);
	}

	sends {
		^U(\matrix, matrix);
	}

	mixer {
		var m = ProxyMixer(this.as(ProxySpace));
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
		matrix = M((argKey ++ '_matrix').asSymbol);
		node = Ndef((argKey ++ '_group').asSymbol);
		node.play;
		//group = Group.new;
		//group.isPlaying = true;
		//bus = Bus.audio(Server.default, 2);

		//TODO: need to handle clear and clean up
		cmdperiod = {
			\cmdperiod.debug(argKey);
			node.play;
			this.prSetTree;
		};
		ServerTree.add(cmdperiod);

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
		clock = LinkClock.new.latency_(Server.default.latency).permanent_(true);
	}
}