
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

	var <key, <>instrument, <>node, <specs, <synths, synthdef, <scenes, <currentScene;

	var <>props, <>psetkey;

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
		key = inKey;
		// using a list as a queue for each note
		// because i'm a little uncertain about
		// the potential for race conditions
		// and possibly having a synth floating
		// off in outer space
		synths = Array.fill(127, {List.new});
		specs = List.new;
		scenes = Order.new;
		preset = ();
		props = ();
		psetkey = (key ++ '_pset').asSymbol;
		Pbindef(psetkey, key, 1); // initialize the pbindef;
		node = Ndef(key);
		// play sets up the node for audio
		node.play;

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

		// if we haven't already added the specs
		if (specs.size == 0) {

			// check the synthdef
			if (synthdef.metadata.isNil.not) {
				if (synthdef.metadata[\specs].isNil.not) {
					specs = synthdef.metadata[\specs].asList;
				}
			};

			if (specs.size == 0) {
				// no specs defined with the synthdef
				// construct the specs from the synth controls
				specs = (
					synthdef.controls
					.reject({arg ctrl;
						[
							\out, \freq, \gate, \trig, \retrig, \sustain, \bend
						].includes(ctrl.name)
					})
					.collect({arg ctrl;
						// check for a match default spec
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
				props.put(k, lfo);
				Pbindef(psetkey, k, lfo);
			}
			{v.isNil} {
				props.removeAt(args[i-1]);
				Pbindef(psetkey, k, v);
			}
			{
				var val = v.asStream;
				props.put(k, val);
				Pbindef(psetkey, k, v);
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

	play {arg monitor=true, fadeTime=0, out=0, mono=false;
		this.pdef(monitor, fadeTime, out, mono).play;
	}

	stop {
		Pdef(this.key).stop;
	}

	pdef {arg monitor=true, fadeTime=0, out=0, mono=false;

		var chain;

		if (monitor) {
			if (node.isMonitoring.not) {
				node.play(fadeTime:fadeTime, out:out);
			};
		} {
			node.stop;
		};

		if (mono) {
			chain = Pchain(Pmono(this.instrument, \retrig, 1, \trig, 1), Pbindef(this.psetkey));
		}{
			chain = Pbindef(this.psetkey);
		};

		^Pdef(key,
			chain
			<> Pbind(
				\instrument, Pfunc({instrument}),
				\root, Pfunc({defaultRoot}),
				\scale, Pfunc({Scale.at(defaultScale).copy.tuning_(defaultTuning)}),
				\out, Pif(Pfunc({node.bus.isNil}), 0, Pfunc({node.bus.index})),
				\group, Pfunc({node.group}),
				\beatdur, Pfunc({thisThread.clock.beatDur}),
				\elapsedbeats, Pfunc({thisThread.clock.elapsedBeats}),
				\bar, Pfunc({thisThread.clock.bar}),
				\beatinbar, Pfunc({thisThread.clock.beatInBar}),
				\hit, Pseries(0, 1, inf)
			)
		)
	}

	clear {
		Ndef(key).clear;
		Pdef(key).clear;
		Pbindef(psetkey).clear;
		Pbindef(psetkey, key, 1);
		scenes.do({arg pdef;
			pdef.clear;
		});
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

	/*
	copy {arg toKey;
		var obj;
		if(toKey.isNil){
			toKey = App.idgen.asSymbol;
		};
	~muauim.set(*~itof.props.asPairs);
		obj = S(toKey, instrument);
		Pbindef(this.psetkey).copy(obj.psetkey);
		obj.props = props.copy;
		obj.node = node.copy(toKey);
		^obj;
	}
	*/

	gui {arg func={};
		^Sui(this.key, this.specs, this.preset)
		.handler_(func)
		.view.front;
	}

	prBuildSynth {arg inKey, inFunc;

		SynthDef(inKey, {
			var trig = Trig1.kr(\trig.tr(1), \sustain.kr(1));
			var gate = Select.kr(\retrig.kr(0), [\gate.kr(1), trig]);
			var in_freq = \freq.ar(261).lag(\glis.kr(0));
			var detune = \detunehz.kr(0.6) * PinkNoise.ar.range(0.8, 1.2);

			// bend by semitones...
			var bend = \bend.ar(0).midiratio;
			var freqbend = in_freq * bend;
			var freq = Vibrato.ar([freqbend + detune.neg, freqbend + detune], \vrate.ar(6), \vdepth.ar(0.0));

			var adsr = {
				var da = Done.none;
				var atk = \atk.kr(0.01);
				var dec = \dec.kr(0.1);
				var rel = \rel.kr(0.1);
				var suslevel = \suslevel.kr(0.5);
				var ts = \ts.kr(1);
				var atkcurve = \atkcurve.kr(-4);
				var deccurve = \deccurve.kr(-4);
				var relcurve = \relcurve.kr(-4);
				var env = Env.adsr(
					attackTime:atk, decayTime:dec, sustainLevel:suslevel, releaseTime:rel,
					curve:[atkcurve, deccurve, relcurve]
				);
				var aeg = env.kr(doneAction:da, gate:gate, timeScale:ts);
				aeg = aeg * \aeglfo.kr(1);
				// control life cycle of synth
				env.kr(doneAction:Done.freeSelf, gate:\gate.kr, timeScale:ts);

				aeg;
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

			\atk -> [0, 30, \lin, 0, 0.01],
			\dec -> [0, 30, \lin, 0, 0.2],
			\rel -> [0, 30, \lin, 0, 0.29],
			\suslevel -> [0, 1, \lin, 0, 0.7],
			\atkcurve -> [-24, 24, \lin, 0, -4],
			\deccurve -> [-24, 24, \lin, 0, -4],
			\relcurve -> [-24, 24, \lin, 0, -4],
			\ts -> [0, 100, \lin, 0, 1],
			\aeglfo -> [1, 1, \lin, 1, 1],
			\ts -> [0, 100, \lin, 0, 1],

			\detunehz -> [0, 100, \lin, 0, 0],
			\bend -> [-12, 12, \lin, 0, 0], // semitones
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