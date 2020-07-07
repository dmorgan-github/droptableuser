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

		listenerfunc = {arg obj, prop, params; [prop, params.asCompileString].debug(key);};
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
					//\root, Pfunc({defaultRoot}),
					//\scale, Pfunc({Scale.at(defaultScale).copy.tuning_(defaultTuning)}),
					\out, Pfunc({node.bus.index}),
					\group, Pfunc({node.group}),
					\key, key
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
			evt = this.asStream.next(Event.default);
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

			/*
			//for some reason this causes a werid click which i can't figure out
			var evt = this.asStream
			.next(Event.default)
			.reject({arg v, k;
				ignore.includes(k) or: v.isKindOf(Function);
			});
			*/

			// may run into issues with resolving Pkey
			var evt = Pdef(this.pdefset).asStream.next(Event.default);
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
			Spec.add(\cutoff, [20, 20000, 'exp', 0, 100]);
			Spec.add(\res, [0, 1, \lin, 0, 0.5]);
			Spec.add(\start, [0, 1, \lin, 0, 0]);
			Spec.add(\rate, [0.1, 4.0, \lin, 0, 1]);

			Spec.add(\atk, [0, 1, \lin, 0, 0.01]);
			Spec.add(\dec, [0, 1, \lin, 0, 0.2]);
			Spec.add(\rel, [0, 8, \lin, 0, 0.29]);
			Spec.add(\suslevel, [0, 1, \lin, 0, 1]);
			Spec.add(\atkcurve, [-8, 8, \lin, 0, -4]);
			Spec.add(\deccurve, [-8, 8, \lin, 0, -4]);
			Spec.add(\relcurve, [-8, 8, \lin, 0, -4]);
			Spec.add(\ts, [0.001, 100, \lin, 0, 1]);

			Spec.add(\detunehz, [0, 10, \lin, 0, 0]);
			Spec.add(\bend, [-12, 12, \lin, 0, 0]);
			Spec.add(\vrate, [0, 440, \lin, 0, 6]);
			Spec.add(\vdepth, [0, 1, \lin, 0, 0]);
			Spec.add(\vel, [0, 1, \lin, 0, 1]);
			Spec.add(\spread, [0, 1, \lin, 0, 1]);
			Spec.add(\center, [0, 1, \lin, 0, 0]);
			Spec.add(\pan, [-1, 1, \lin, 0, 0]);
			Spec.add(\amp, [0, 1, \lin, 0, -10.dbamp]);
		});
	}
}


N {
	*new {arg key;
		var path = "~/projects/droptableuser/library/fx/" ++ key.asString ++ ".scd";
		var pathname = PathName(path.standardizePath);
		var fullpath = pathname.fullPath;
		if (File.exists(fullpath)) {
			var name = pathname.fileNameWithoutExtension;
			var obj = File.open(fullpath.postln, "r").readAllString.interpret;
			var func = obj[\synth];
			var specs = obj[\specs];
			var key = (name ++ '_' ++ UniqueID.next).asSymbol;
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

	*list {arg path;
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
			File.open(fullpath.postln, "r").readAllString.interpret;
			Fdef(key).value(*args);
		} {
			Error("node not found").throw;
		};
	}

	*list {arg path;
		// this could be nicer
		var mypath = path ? "/Users/david/projects/droptableuser/library/ui/";
		PathName.new(mypath)
		.entries.do({arg e; e.fullPath.postln;});
	}
}

/*
/*
probably best to split out the noteon/noteoff to a separate class
so essentially we can have a midi player and pattern player
with the same interface but different implementations
*/
S : EventPatternProxy {

	classvar <>defaultRoot, <>defaultScale, <>defaultTuning, <>defaultQuant;

	var <key, <instrument, <node, <specs, <synths, synthdef;

	var <props, <psetkey, <vsts;

	var listenerfunc;

	var cmdperiodfunc;

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
		key = inKey;
		// using a list as a queue for each note
		// because i'm a little uncertain about
		// the potential for race conditions
		// and possibly having a synth floating
		// off in outer space
		synths = Array.fill(127, {List.new});
		// TODO: move specs to Halo
		specs = ();
		vsts = Order.new;
		props = ();
		psetkey = (key ++ '_pset').asSymbol;
		// need to  initialize with one key defined
		// otherwise the empty pbindef will halt the entire pattern
		Pbindef(psetkey, key, 1).quant_(defaultQuant); // initialize the pbindef;
		listenerfunc = {arg obj, prop, params; [prop, params.asCompileString].debug(key);};
		node = Ndef(key);
		node.mold(2, \audio);
		//if (node.dependants.size == 0) {
		//	node.addDependant(listenerfunc);
		//};
		if (this.dependants.size == 0) {
			this.addDependant(listenerfunc);
		};

		cmdperiodfunc = { { \wakeup.debug(key); Ndef(key).wakeUp }.defer(0.5) };
		CmdPeriod.add(cmdperiodfunc);

		// wake sets up the node for audio
		node.wakeUp;

		this.source = this.prInitSource;

		^this;
	}

	prInitSynth {arg inKey, inSynth;

		var blacklist = [\out, \freq, \gate, \trig, \retrig, \sustain, \bend];

		instrument = inSynth;

		if (inSynth.isKindOf(Function)) {
			instrument = inKey;
			this.prBuildSynth(instrument, inSynth);
		};

		synthdef = SynthDescLib.global.at(instrument);
		if (synthdef.isNil) {
			Error("synthdef not found").throw;
		};

		// check the synthdef
		if (synthdef.metadata.isNil.not) {
			if (synthdef.metadata[\specs].isNil.not) {
				specs = synthdef.metadata[\specs]
			}
		};

		// add specs from the synth controls
		synthdef.controls
		.reject({arg ctrl;
			specs[ctrl.name.asSymbol].isNil.not;
		})
		.do({arg ctrl;
			// check for a matching default spec
			var key = ctrl.name.asSymbol;
			var spec = Spec.specs[key];
			if (spec.isNil) {
				var max = if (ctrl.defaultValue < 1) {1} { min(20000, ctrl.defaultValue * 2) };
				spec = [0, max, \lin, 0, ctrl.defaultValue].asSpec;
			};
			specs[key] = spec;
		});

		specs.keys.do({arg k;
			if (blacklist.includes(k)) {
				specs.removeAt(k);
			};
			if (k.asString.endsWith("lfo")) {
				specs.removeAt(k);
			};
		});
	}

	prInitSource {

		/*
		the envir property can be used to pass argument values
		to the pattern
		~a = S(\subtractr);
		~a.envir = (monitor:false);
		*/
		var plazy = Plazy({arg evt;
			var monitor = evt[\monitor] ?? true;
			var mono = evt[\mono] ?? false;
			var fadeTime = evt[\fadeTime] ?? 0;
			var out = evt[\outbus] ?? 0;

			if (monitor) {
				this.node.play(
					fadeTime:fadeTime,
					out:out
				);
			};

			if (mono) {
				Pchain(
					Pmono(this.instrument, \retrig, 1, \trig, 1),
					Pbind(\fx, Pfunc({arg evt;
						this.node.controlKeys.do({|key|
							if (evt[key].isNil.not) {
								this.node.set(key, evt[key]);
							}
						});
						1
					})),
					Pbindef(this.psetkey, key, 1));
			}{
				Pchain(
					Pbind(\fx, Pfunc({arg evt;
						this.node.controlKeys.do({|key|
							if (evt[key].isNil.not) {
								this.node.set(key, evt[key]);
							}
						});
						1
					})),
					// need to  initialize with one key defined
					// otherwise the empty pbindef will halt the entire pattern
					Pbindef(this.psetkey, key, 1)
				);
			}
		});

		^Pchain(
			plazy,
			Pbind(
				\instrument, Pfunc({instrument}),
				\root, Pfunc({defaultRoot}),
				\scale, Pfunc({Scale.at(defaultScale).copy.tuning_(defaultTuning)}),
				\out, Pfunc({node.bus.index}),
				\group, Pfunc({node.group}),
				\key, key
			)
		);
	}

	doesNotUnderstand { arg selector ... args;
		var val = args[0];
		if (selector.isSetter) {
			selector = selector.asGetter;
			^this.value(selector.asSymbol, val);
		} {
			^this.at(selector.asSymbol)
		};
	}

	at {arg key;

		var val;
		var spec = this.specs[key];
		var cn = node.controlNames.detect({arg cn; cn.name == key});

		if (cn.isNil.not) {
			val = node.get(key);
			if (val.isNil) {
				val = cn.defaultValue;
			};
		}{
			var pairs, index;
			if (spec.isNil.not) {
				val = spec.value.default;
			};
			pairs = this.getPairs;
			index = pairs.detectIndex({arg item; item == key});
			if (index.isNil.not) {
				val = pairs[index+1];
			}
		};
		^val;
	}

	rec {arg name, seconds=30, play=true;

		App.saveWorkspace(name, rec:true);
		if (play and: this.isPlaying.not) {
			this.play;
		};
		if (seconds.isNil.not) {
			{Server.default.stopRecording}.defer(seconds);
		}
	}

	// TODO: should clear and remove any lfo if being replaced
	value {arg ...args;

		var pairs, clearpairs;
		if (args.size.even.not) {
			Error("args must be even number").throw;
		};

		clearpairs = args.collect({arg v, i;
			if (i.even) {v}{nil}
		});

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
					v;
				}
			}
		});

		// this is to support noteon/noteoff midi
		props = props ++ pairs.collect({arg v, i;
			if (i.odd) {
				var myval = v.asStream;
				myval;
			} {
				v;
			}
		}).asDict;

		// try to ensure intended order
		Pbindef(this.psetkey, *clearpairs);
		Pbindef(this.psetkey, *pairs);
	}

	getPairs {
		^Pbindef(this.psetkey)
		.source
		.pairs
		.collect({arg val; if (val.class == PatternProxy) { val.pattern }{val}});
	}

	getSpec {arg key;
		var spec = this.specs[key];
		if (spec.isNil.not) {
			spec = spec.value;
		};
		^spec;
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

	vset {arg index ...args;

		forBy(0, args.size-1, 2, {arg i;
			var k = args[i];
			var v = args[i+1];

			if (v.isKindOf(Function)) {
				var lfo;
				var lfokey = (this.key ++ k ++ index).asSymbol;
				"creating lfo node %".format(lfokey).debug(this.key);
				lfo = Ndef(lfokey, v);
				this.vsts[index].map(k, lfo.asBus);
				this.changed(k, lfo);
			}{
				if (v.isKindOf(NodeProxy)) {
					this.vsts[index].map(k, v.asBus);
					this.changed(k, v);
				}{
					this.vsts[index].set(k, v);
					this.changed(k, v);
				}
			}
		});
	}

	vst {arg index, name;

		if (name.isNil) {
			vsts.removeAt(index);
		}{
			if (vsts[index].isNil) {

				// need to make sure each step completes
				Routine({
					var synthdef = (key ++ name ++ index).asSymbol;
					var synth, fx;

					SynthDef.new(synthdef, {arg in;
						var sig = In.ar(in, 2);
						var wet = ('wet' ++ index).asSymbol.kr(1);
						XOut.ar(in, wet, VSTPlugin.ar(sig, 2));
						//ReplaceOut.ar(in, VSTPlugin.ar(In.ar(in, 2), 2)) * ('wet' ++ index).asSymbol.kr(1);
					}).add;

					// FlowVar
					1.wait;
					node.put(index, synthdef);

					// FlowVar
					1.wait;
					synth = Synth.basicNew(synthdef, Server.default, node.objects[index].nodeID);
					synth.set(\in, node.bus.index);
					fx = VSTPluginController(synth);

					// FlowVar
					1.wait;
					// there can be a delay
					fx.open(name.asString, verbose:true, editor:true);
					vsts.put(index, fx);
					name.debug(\loaded);

					// FlowVar
					1.wait;

					fx.editor;

				}).play;

			}{
				vsts[index].editor;
				^vsts[index];
			}
		};
	}

	on {arg midinote, vel=1;
		this.prNoteOn(midinote, vel);
	}

	off {arg midinote;
		this.prNoteOff(midinote);
	}

	clearPattern {
		Pbindef(this.psetkey).clear;
	}

	clear {
		Ndef(key).clear;
		Pdef(key).clear;
		Pbindef(psetkey).clear;
		// need to  initialize with one key defined
		// otherwise the empty pbindef will halt the entire pattern
		Pbindef(psetkey, key, 1).quant_(defaultQuant);
		this.panic();
	}

	tolist {arg size=16;
		var list = List.new;
		var stream = this.asStream;
		size.do({arg i;
			var evt = stream.next(Event.default);
			list.add(evt);
		});
		^list;
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

	prNoteOn {arg midinote, vel=1;

		// there should only be one synth per note
		if (node.isPlaying) {
			var evt = props.keys.collect({arg k;
				[k, props.at(k).value]
			}).asArray.flatten;

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
		//all = ();
		defaultTuning = \et12;
		defaultRoot = 4;
		defaultScale = \dorian;
		defaultQuant = 1;

		StartUp.add({
			Spec.add(\cutoff, [20, 20000, 'exp', 0, 100]);
			Spec.add(\res, [0, 1, \lin, 0, 0.5]);
			Spec.add(\start, [0, 1, \lin, 0, 0]);
			Spec.add(\rate, [0.1, 4.0, \lin, 0, 1]);

			Spec.add(\atk, [0, 1, \lin, 0, 0.01]);
			Spec.add(\dec, [0, 1, \lin, 0, 0.2]);
			Spec.add(\rel, [0, 8, \lin, 0, 0.29]);
			Spec.add(\suslevel, [0, 1, \lin, 0, 1]);
			Spec.add(\atkcurve, [-8, 8, \lin, 0, -4]);
			Spec.add(\deccurve, [-8, 8, \lin, 0, -4]);
			Spec.add(\relcurve, [-8, 8, \lin, 0, -4]);
			Spec.add(\ts, [0.001, 100, \lin, 0, 1]);

			Spec.add(\detunehz, [0, 10, \lin, 0, 0]);
			Spec.add(\bend, [-12, 12, \lin, 0, 0]);
			Spec.add(\vrate, [0, 440, \lin, 0, 6]);
			Spec.add(\vdepth, [0, 1, \lin, 0, 0]);
			Spec.add(\vel, [0, 1, \lin, 0, 1]);
			Spec.add(\spread, [0, 1, \lin, 0, 1]);
			Spec.add(\center, [0, 1, \lin, 0, 0]);
			Spec.add(\pan, [-1, 1, \lin, 0, 0]);
			Spec.add(\amp, [0, 1, \lin, 0, -10.dbamp]);
		});
	}
}
*/

/*
TODO: refactor to reduce duplicate code
*/
/*
M {
	classvar <all;

	var <key, <>node, <synths, <vsts;

	var listenerfunc;

	*new {arg key;
		var res = all[key];
		if (res.isNil) {
			res = super.new.prInit(key);
			all.put(key, res);
		};
		^res;
	}

	prInit {arg inKey;
		key = inKey;
		synths = Order.new;
		vsts = Order.new;
		listenerfunc = {arg obj, prop, params; [prop, params.asCompileString].debug(obj.key);};
		node = Ndef(key);
		node.mold(2, \audio);
		if (node.dependants.size == 0) {
			node.addDependant(listenerfunc);
		};
		if (this.dependants.size == 0) {
			this.addDependant(listenerfunc);
		};
		// wake sets up the node for audio
		node.wakeUp;
	}

	// TODO: should clear and remove any lfo if being replaced
	set {arg ...args;

		if (args.size.even.not) {
			Error("args must be even number").throw;
		};

		forBy(0, args.size-1, 2, {arg i;

			var k = args[i];
			var v = args[i+1];
			var cn = node.controlNames.detect({arg cn; cn.name == k});
			var isnodeprop = cn.isNil.not;

			// we have to keep two copies of the keys
			// one for patterns and one for synth args.
			// an event can't really be used directly
			// within a pattern as keys like \dur when
			// provided a pattern for their value do not
			// resolve to the underlying primitive correctly
			case
			{v.isKindOf(Function)} {
				var lfo;
				var lfokey = (this.key ++ '_' ++ k).asSymbol;
				"creating lfo node %".format(lfokey).debug(this.key);
				lfo = Ndef(lfokey, v);
				node.set(k, lfo);
				this.changed(k, lfo);
			}
			{v.isNil} {
				node.set(k, v);
				this.changed(k, v);
			}
			{
				var val = v.asStream;
				node.set(k, val.value);
				this.changed(k, v);
			}
		});
	}

	vset {arg index ...args;

		forBy(0, args.size-1, 2, {arg i;
			var k = args[i];
			var v = args[i+1];

			if (v.isKindOf(Function)) {
				var lfo;
				var lfokey = (this.key ++ k ++ index).asSymbol;
				"creating lfo node %".format(lfokey).debug(this.key);
				lfo = Ndef(lfokey, v);
				this.vsts[index].map(k, lfo.asBus);
				this.changed(k, lfo);
			}{
				if (v.isKindOf(NodeProxy)) {
					this.vsts[index].map(k, v.asBus);
					this.changed(k, v);
				}{
					this.vsts[index].set(k, v);
					this.changed(k, v);
				}
			}
		});
	}

	doesNotUnderstand { arg selector ... args;
		var val = args[0];
		if (selector.isSetter) {
			selector = selector.asGetter;
			^this.set(selector.asSymbol, val);
		} {
			^this.at(selector.asSymbol)
		};
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

	vst {arg index, name;

		if (name.isNil) {
			vsts.removeAt(index);
		}{
			if (vsts[index].isNil) {

				// need to make sure each step completes
				Routine({
					var synthdef = (key ++ name ++ index).asSymbol;
					var synth, fx;

					SynthDef.new(synthdef, {arg in;
						var sig = In.ar(in, 2);
						var wet = ('wet' ++ index).asSymbol.kr(1);
						XOut.ar(in, wet, VSTPlugin.ar(sig, 2));
						//ReplaceOut.ar(in, VSTPlugin.ar(In.ar(in, 2), 2)) * ('wet' ++ index).asSymbol.kr(1);
					}).add;

					// FlowVar
					1.wait;
					node.put(index, synthdef);

					// FlowVar
					1.wait;
					synth = Synth.basicNew(synthdef, Server.default, node.objects[index].nodeID);
					synth.set(\in, node.bus.index);
					fx = VSTPluginController(synth);

					// FlowVar
					1.wait;
					// there can be a delay
					fx.open(name.asString, verbose:true, editor:true);
					vsts.put(index, fx);
					name.debug(\loaded);

					// FlowVar
					1.wait;

					fx.editor;

				}).play;

			}{
				vsts[index].editor;
				^vsts[index];
			}
		};
	}

	mix {arg synth;
		synth.asArray.do({arg val;
			var index = synths.detectIndex({arg obj; obj.key == val.key});
			val.node.stop;
			if (index.isNil) {
				synths.add(val);
				node[synths.lastIndex] = \mix -> {val.node.ar};
			} {
				// re-apply
				node[index] = \mix -> {val.node.ar};
			}
		});
	}

	removeAt {arg num;
		var index = synths.indices[num];
		synths.removeAt(index);
		node.removeAt(index);
	}

	play {arg fadeTime=0;
		node.play(fadeTime:fadeTime);
	}

	stop {arg fadeTime=0;
		node.stop(fadeTime:fadeTime);
	}

	*initClass {
		all = ();
		StartUp.add {
			10.do({arg i;
				var key = ('mix' ++ i).asSymbol;
				Spec.add(key, [0, 1, \lin, 0, 1]);
			});
		}
	}
}
*/

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
