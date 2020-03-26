M {
	classvar <all;

	var <key, <>node, <synths;

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
		node = Ndef(key);
		// play sets up the node for audio
		node.play;
	}

	fx {arg index, func;
		if (func.isNil) {
			node.put(index, func);
		}{
			node.put(index, \filter -> func);
		}
	}

	mix {arg synth;
		synth.asArray.do({arg val;
			var index = synths.detectIndex({arg obj; obj.key == val.key});
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

	set {arg ...args;

		if (args.size.even.not) {
			Error("args must be even number").throw;
		};

		forBy(0, args.size-1, 2, {arg i;

			var k = args[i];
			var v = args[i+1];
			var cn = node.controlNames.detect({arg cn; cn.name == k});

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
			{
				node.set(k, v);
				this.changed(k, v);
			}
		});
	}

	getVal {arg key;
		var val = node.get(key);
		^val;
	}

	play {arg fadeTime=0;
		node.play(fadeTime:fadeTime);
	}

	stop {arg fadeTime=0;
		node.stop(fadeTime:fadeTime);
	}

	doesNotUnderstand { arg selector ... args;
		var val = args[0];
		if (selector.isSetter) {
			selector = selector.asGetter;
			^this.set(selector.asSymbol, val);
		} {
			^this.getVal(selector.asSymbol)
		};
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



B : S {

	classvar <all;

	var <buf, recsynth;

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
				SendReply.kr(donetrig, '/\rec_infeedback_done', 1, 1905);
				Out.ar(\out.kr(0), in);
			}).add;
		};
	}
}

S {
	classvar <all;

	classvar <>defaultRoot, <>defaultScale, <>defaultTuning;

	var <key, <instrument, <node, <specs, <synths, synthdef, <scenes, <currentScene;

	var <props, <psetkey, <vsts;

	var listenerfunc, setbuttonfunc;

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
		specs = ();
		scenes = Order.new;
		vsts = Order.new;
		props = ();
		psetkey = (key ++ '_pset').asSymbol;
		Pbindef(psetkey, key, 1); // initialize the pbindef;
		listenerfunc = {arg obj, prop, params; [obj, prop, params].postln;};
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

	getSpec {arg key;
		var spec = this.specs[key];
		if (spec.isNil.not) {
			spec = spec.value;
		};
		^spec;
	}

	getVal {arg key, default;
		var val;
		var spec = this.specs[key];
		var prop = this.props[key];
		var cn = node.controlNames.detect({arg cn; cn.name == key});

		if (cn.isNil.not) {
			val = node.get(key);
			if (val.isNil) {
				val = cn.defaultValue;
			};
		}{
			if (spec.isNil.not) {
				val = spec.value.default;
			};
			if (prop.isNil.not) {
				val = prop.value;
			};
		};
		if (val.isNil) {
			val = default;
		};
		^val;
	}

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
				if (isnodeprop) {
					node.set(k, lfo);
				}{
					props.put(k, lfo);
					Pbindef(psetkey, k, lfo);
				};
				this.changed(k, lfo);
			}
			{v.isNil} {
				if (isnodeprop){
					node.set(k, v);
				}{
					props.removeAt(args[i-1]);
					Pbindef(psetkey, k, v);
				};
				this.changed(k, v);
			}
			{
				// can accept patterns
				var val = v.asStream;
				if (isnodeprop){
					// can't use pattern or routine as value
					// for a node property so just get
					// the first value from the stream
					node.set(k, val.value);
				}{
					props.put(k, val);
					Pbindef(psetkey, k, v);
				};
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
			^this.getVal(selector.asSymbol)
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

					1.wait;
					node.put(index, synthdef);

					1.wait;
					synth = Synth.basicNew(synthdef, Server.default, node.objects[index].nodeID);
					synth.set(\in, node.bus.index);
					fx = VSTPluginController(synth);

					1.wait;
					// there can be a delay
					fx.open(name.asString, verbose:true, editor:true);
					vsts.put(index, fx);
					name.debug(\loaded);

					1.wait;

					fx.editor;

				}).play;

			}{
				vsts[index].editor;
				^vsts[index];
			}
		};
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

	ddl {arg seq;
		var func = {arg seq;
			var durs, degrees, lag;
			var parse, result;
			parse = {arg seq, result=[[],[],0], div=1, isstart=true;
				seq.do({arg val, i;
					if (val.isRest) {
						if(isstart) {
							// lag only matters if we start the whole phrase
							// with a rest. inner rests don't require anything
							// to do with lag
							result[2] = result[2] + 1;
						}{
							if (val == \r) {
								// a rest
								result[0] = result[0].add(Rest(div));
								// degree
								result[1] = result[1].add(Rest());
							} {
								// otherwise a tie
								var mydurs = result[0];
								mydurs[mydurs.lastIndex] = mydurs[mydurs.lastIndex] + div;
							}
						}
					} {
						isstart = false;
						if (val.isArray) {
							var myseq = val;
							var mydiv = 1/myseq.size * div;
							result = parse.(myseq, result, mydiv, isstart);
						} {
							var obj = val.value;
							var mydegree = obj;
							result[0] = result[0].add(div);
							result[1] = result[1].add(mydegree);
						}
					}
				});
				result.postln;
			};
			result = parse.(seq);
		};
		var ptrn = func.(seq);
		this.set(\dur, Pseq(ptrn[0], inf), \degree, Pseq(ptrn[1], inf), \lag, Pn(ptrn[2]));
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

	stop {arg fadeTime=0;
		if (fadeTime > 0) {
			this.node.stop(fadeTime:fadeTime);
			{
				Pdef(this.key).stop;
			}.defer(fadeTime + 1);
		}{
			Pdef(this.key).stop;
		};
	}

	pdef {arg monitor=true, fadeTime=0, out=0, mono=false;

		var chain;

		if (monitor) {
			node.play(fadeTime:fadeTime, out:out);
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
				\group, Pfunc({node.group})
			)
		)
	}

	tolist {arg size=16;
		var list = List.new;
		var stream = this.pdef.asStream;
		size.do({arg i;
			var evt = stream.next(Event.default);
			list.add(evt);
		});
		^list;
	}

	viz {arg num=7, start=60;

		var root = this.props[\root] ?? defaultRoot;
		var size = num * num;
		var grid;
		var black = [1,3,6,8,10];
		var view = View();

		var buttons = size.collect({arg i;
			var color = Color.grey;
			var num = i;
			if (black.includes(num.mod(12))) {
				color = Color.black.alpha_(0.7);
			} {
				if (num.mod(12) == 0) {
					color = Color.grey.alpha_(0.5);
				}
			};
			Button().maxWidth_(20).states_([ ["", nil, color], ["", nil, Color.white] ])
		});

		grid = num.collect({arg i;
			var row = num-i-1 * num;
			var btns = buttons[row..(row + num-1)];
			row.postln;
			btns;
		});

		setbuttonfunc = {arg index;
			var val;
			buttons.do({arg btn;
				btn.value = 0;
			});
			val = 12 * 2 + (index+root);
			buttons[val].value = 1;
		};

		this.set(\viz,
			Pfunc({arg event;
				var fr = event.use { ~freq.value };
				var note = fr.cpsmidi.round(1).asInteger;
				var val = note - (start+root);
				{
					setbuttonfunc.(val);
				}.defer;
				1;
			})
		);

		view
		.layout_(GridLayout.rows(*grid).spacing_(0).margins_(0))
		.name_(key)
		.onClose_({
			\viz.debug(\clear);
			this.set(\viz, nil)
		})
		.front;
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

	gui {
		var func = {arg k, v; this.set(k, v) };
		^Sui(this.key, this.specs, this)
		.handler_(func)
		.view.front;
	}

	prBuildSynth {arg inKey, inFunc;

		SynthDef(inKey, {
			var trig = Trig1.kr(\trig.tr(1), \sustain.kr(1));
			var gate = Select.kr(\retrig.kr(0), [\gate.kr(1), trig]);
			var in_freq = \freq.ar(261).lag(\glis.kr(0));
			var detune = \detunehz.kr(0);// * PinkNoise.ar.range(0.8, 1.2);

			// bend by semitones...
			var bend = \bend.ar(0).midiratio;
			var freqbend = in_freq * bend;
			var freq = Vibrato.ar([freqbend, freqbend + detune], \vrate.ar(6), \vdepth.ar(0.0));

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

		StartUp.add({
			Spec.add(\cutoff, [20, 20000, 'exp', 0, 100]);
			Spec.add(\res, [0, 1, \lin, 0, 0.5]);
			Spec.add(\start, [0, 1, \lin, 0, 0]);
			Spec.add(\rate, [0.1, 4.0, \lin, 0, 1]);

			Spec.add(\atk, [0, 1, \lin, 0, 0.01]);
			Spec.add(\dec, [0, 1, \lin, 0, 0.2]);
			Spec.add(\rel, [0, 8, \lin, 0, 0.29]);
			Spec.add(\suslevel, [0, 1, \lin, 0, 0.7]);
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