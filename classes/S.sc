S : EventPatternProxy {

	classvar <>defaultRoot, <>defaultScale, <>defaultTuning, <>defaultQuant;

	var <key, <instrument, <node, <synths, <pdefset, synthdef;

	var listenerfunc, cmdperiodfunc, <>debug;

	*new {arg key, synth;
		var res;
		if (synth.isNil) {
			// support terser style by generating an id
			// if using a synthdef
			synth = key ? \default;
			key = (synth ++ '_' ++ UniqueID.next).asSymbol;
		};
		res = Pdef.all[key];
		if (res.isNil) {
			res = super.new(nil).prInit(key);
			Pdef.all.put(key, res);
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

		debug = false;
		key = inKey;
		pdefset = (key ++ '_set').asSymbol;
		Pdef(pdefset, Pbind());
		synths = Array.fill(127, {List.new});

		// this isn't doing anything
		listenerfunc = {arg obj, prop, params; [prop, params.asCompileString];};
		node = Ndef(key);
		node.mold(2, \audio);

		if (this.dependants.size == 0) {
			this.addDependant(listenerfunc);
		};

		cmdperiodfunc = { { \wakeup.debug(key); Ndef(key).wakeUp }.defer(0.5) };
		CmdPeriod.add(cmdperiodfunc);

		// wake sets up the node for audio
		node.wakeUp;
		this.source = this.prInitSource;
		this.set(\root, defaultRoot, \scale, Scale.at(defaultScale).copy.tuning_(defaultTuning));
		^this;
	}

	prInitSynth {arg inKey, inSynth;

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
			myspecs[key] = spec;
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
	}

	prInitSource {

		// TODO: support for Pmono and PmonoArtic
		var plazy = Plazy({arg evt;

			var pchain;
			var monitor = evt[\monitor] ?? true;
			var fadeTime = evt[\fadeTime] ?? 0;
			var mono = evt[\mono] ?? false;
			var out = evt[\outbus] ?? 0;

			if (monitor) {
				this.node.play(
					fadeTime:fadeTime,
					out:out
				);
			};

			pchain = if (mono) {
				Pchain(
					Pmono(this.instrument, \retrig, 1, \trig, 1),
					Pdef(this.pdefset)
				)
			}{
				Pdef(this.pdefset)
			};

			Pchain(
				pchain,
				Pbind(
					\instrument, Pfunc({instrument}),
					\out, Pfunc({node.bus.index}),
					\group, Pfunc({node.group})
				)
			);
		});

		^plazy;
	}

	// TODO: should clear and remove any lfo if being replaced
	value {arg ...args;

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

		Pdef(this.pdefset, Pbind(*pairs));
	}

	at {arg key;

		var val;
		var spec = this.getSpec(key);
		var cn = node.controlNames.detect({arg cn; cn.name == key});

		if (cn.isNil.not) {
			val = node.get(key);
			if (val.isNil) {
				val = cn.defaultValue;
			};
		}{
			var evt, index;
			if (spec.isNil.not) {
				val = spec.value.default;
			};
			evt = this.asStream.next((monitor:false));
			if (evt[key].isNil.not) {
				val = evt[key];
			}
		};
		^val;
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

	clear {
		// this should clear any lfos
		Ndef(this.key).clear;
		Ndef(this.pdefset).clear;
		this.clear;
		this.panic();
	}

	prNoteOn {arg midinote, vel=1;

		var ignore = [\instrument,
			\root, \scale, \out, \group, \key, \dur, \legato,
			\delta, \freq, \degree, \octave, \gate, \fx, \vel];

		if (node.isPlaying) {

			var evt = this.asStream
			.next((monitor:false))
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
					attackTime:atk, decayTime:dec, sustainLevel:suslevel, releaseTime:rel,
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
			Spec.add(\atkcurve, ControlSpec(-8, 8, \lin, 0, -4, units:"aeg"));
			Spec.add(\deccurve, ControlSpec(-8, 8, \lin, 0, -4, units:"aeg"));
			Spec.add(\relcurve, ControlSpec(-8, 8, \lin, 0, -4, units:"aeg"));
			Spec.add(\ts, ControlSpec(0.001, 100, \lin, 0, 1, units:"aeg"));

			Spec.add(\detunehz, ControlSpec(0, 10, \lin, 0, 0, units:"freq"));
			Spec.add(\bend, ControlSpec(-12, 12, \lin, 0, 0, units:"freq"));
			Spec.add(\vrate, ControlSpec(0, 440, \lin, 0, 6, units:"freq"));
			Spec.add(\vdepth, ControlSpec(0, 1, \lin, 0, 0, units:"freq"));
			Spec.add(\spread, ControlSpec(0, 1, \lin, 0, 1, units:"stereo"));
			Spec.add(\center, ControlSpec(0, 1, \lin, 0, 0, units:"stereo"));
			Spec.add(\pan, ControlSpec(-1, 1, \lin, 0, 0, units:"stereo"));
			Spec.add(\vel, ControlSpec(0, 1, \lin, 0, 1, units:"vol"));
			Spec.add(\drive, ControlSpec(1, 100, \lin, 0, 1, units:"vol"));
			Spec.add(\amp, ControlSpec(0, 1, \lin, 0, -10.dbamp, units:"vol"));
		});
	}
}


N {
	*new {arg key, fx;

		var path, pathname, fullpath;

		if (fx.isNil) {
			fx = key;
		};

		path = "~/projects/droptableuser/library/fx/" ++ fx.asString ++ ".scd";
		pathname = PathName(path.standardizePath);
		fullpath = pathname.fullPath;
		if (File.exists(fullpath)) {
			var name = pathname.fileNameWithoutExtension;
			var obj = File.open(fullpath, "r").readAllString.interpret;
			var func = obj[\synth];
			var specs = obj[\specs];
			if (fx == key) {
				key = (name ++ '_' ++ UniqueID.next).asSymbol;
			};
			Ndef.ar(key, 2);
			Ndef(key).filter(100, func);

			if (specs.isNil.not) {
				specs.do({arg assoc;
					Ndef(key).addSpec(assoc.key, assoc.value);
				});
			};
			^Ndef(key);
		} {
			Error("node not found").throw;
		};
	}

	*directory {arg path;
		// this could be nicer
		var mypath = path ? "/Users/david/projects/droptableuser/library/fx/";
		PathName.new(mypath)
		.entries.do({arg e; e.fullPath.postln;});
	}
}

U {
	*new {arg key ...args;

		var path = "~/projects/droptableuser/library/ui/" ++ key.asString ++ ".scd";
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

	*directory {arg path;
		// this could be nicer
		var mypath = path ? "/Users/david/projects/droptableuser/library/ui/";
		PathName.new(mypath)
		.entries.do({arg e; e.fullPath.postln;});
	}
}


/*
B : S {

	classvar <all;

	var <>buf, recsynth;

	*new {arg key, path;
		var res = all[key];
		if (res.isNil) {
			var synth = \smplr_1chan;
			res = super.new(key, synth).bInit(path);
			all.put(key, res);
		} {
			res.bInit(path);
		};
		^res;
	}

	bInit {arg inPath;

		if (inPath.isKindOf(Buffer)) {
			var bufnum = inPath.bufnum;
			buf = inPath;
			this.specs.add(\buf -> ControlSpec(bufnum, bufnum, \lin, 0, bufnum));
			this.value(\buf, buf);
			if (buf.numChannels == 2) {
				this.instrument = \smplr_2chan
			}
		}{
			if (inPath.isNumber) {
				var bufnum;
				buf = B.alloc(inPath);
				bufnum = buf.bufnum;
				this.specs.add(\buf -> ControlSpec(bufnum, bufnum, \lin, 0, bufnum));
				this.value(\buf, buf);
				this.instrument = \smplr_2chan;
			}{
				Buffer.read(Server.default, inPath, action:{arg mybuf;
					var bufnum;
					"buffer loaded; numchannels: %".format(mybuf.numChannels).debug(\b);
					bufnum = mybuf.bufnum;
					buf = mybuf;
					this.specs.add(\buf -> ControlSpec(bufnum, bufnum, \lin, 0, bufnum));
					this.value(\buf, buf);
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
		//Synth(\rec_soundin, [\buf, buf, \run, 1, \trig, 1, \reclevel, reclevel]);
		if (recsynth.isNil) {
			"Not armed!".warn
		}{
			"recording".debug(key);
			recsynth.set(\run, 1, \trig, 1);
		};

		OSCFunc({arg msg;
			msg.debug(key);
			recsynth = nil;
		}, '/rec_soundin_done', Server.default.addr)
		.oneShot;
	}

	armSoundIn {
		"recording armed".debug(key);
		recsynth = Synth(\rec_soundin, [\buf, buf, \run, 0, \trig, 0]);
	}

	recLoop {arg bus=0, quant=1;
		"recLoop".debug(key);
		Pbind(
			\instrument, \rec_infeedback,
			\type, \on,
			\run, 1,
			\trig, 1,
			\buf, Pseq([buf], 1),
			\bus, bus
		).play(quant:1);
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
			this.value(\dur, dur);
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
			this.value(\start, start, \dur, dur);
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
				var bus = \bus.kr([0, 1]);
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
				Out.ar(\out.kr(0), in);
			}).add;

			SynthDef(\rec_infeedback, {
				var bus = \bus.kr(0);
				var in = InFeedback.ar(bus, 2);
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
				SendReply.kr(donetrig, '/rec_infeedback_done', 1, 1905);
				Out.ar(\out.kr(0), in);
			}).add;
		};
	}
}
*/
