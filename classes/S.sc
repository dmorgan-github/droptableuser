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
		Buffer.read(Server.default, inPath, action:{arg mybuf;
			"buffer loaded; numchannels: %".format(mybuf.numChannels).debug(\b);
			if (mybuf.numChannels == 2) {
				var bufnum = mybuf.bufnum;
				buf = mybuf;
				this.specs.add(\buf -> ControlSpec(bufnum, bufnum, \lin, 0, bufnum));
				this.set(\instrument, \smplr_2chan);
				this.set(\buf, mybuf);
			};
		});
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

	*initClass { all = () }
}
/*
(
OscCtrl.paths('/1/push', (1..12), {arg val, num;
	var note = 48 + (num-1);
	if (val == 1) {
		S(\synth1).on(note, 1);
	}{
		S(\synth1).off(note);
	}
});
)

OscCtrl.paths('/1/push', (1..12), nil);
*/
OscCtrl {

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
MidiCtrl(\synth1, \iac)
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
	/*
	(
	MIDIdef.bend(\bendTest, {
	arg val, chan, src;
	['bend', val, chan, src].postln;  // [ bend, 11888, 0, 1 ]
	~bend = val;
	// also update any notes currently in ~notes
	~notes.do{arg synth; synth.set(\bend, val.linlin(0, 16383, -2, 2))};
	}, chan: 0);
	)
	*/

	clear {
		this.note(nil, nil);
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

	var <key, <envir, <node, <specs, <synths, synthdef;

	*new {arg key, synth;
		var res = all[key];
		if (res.isNil or: synth.isNil.not) {
			res = super.new.sInit(key, synth);
			all.put(key, res);
		};
		^res;
	}

	sInit {arg inKey, inSynth;
		if (inKey.isNil) {
			Error("key not specified");
		};

		if (inSynth.isNil) {
			Error("synth not specified");
		};
		if (inSynth.isKindOf(Function)) {
			this.prBuildSynth(inKey, inSynth);
			inSynth = inKey;
		};
		// using a list as a queue for each note
		// because i'm a little uncertain about
		// the potential for race conditions
		// and possible having a synth floating
		// off in outer space
		synths = Array.fill(127, {List.new});
		key = inKey;
		envir = (
			\instrument: inSynth
		);
		node = Ndef(key);
		node.play;

		synthdef = SynthDescLib.global.at(inSynth);

		if (synthdef.isNil) {
			Error("synthdef not found").throw;
		};

		if (synthdef.metadata.isNil.not) {
			specs = synthdef.metadata[\specs];
		};

		^this;
	}

	set {arg ...args;
		args.as(Event).keysValuesDo({arg k, v;
			envir[k] = v;
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
		} {
			myspecs = synthdef.controls
			.reject({arg ctrl; [\out, \freq, \gate, \trig].includes(ctrl.name)})
			.collect({arg ctrl;
				var key = ctrl.name.asSymbol;
				if (envir[key].isNil) {
					envir[key] = ctrl.defaultValue;
				};
				[key, Pfunc({envir[key]})]
			}).flatten
		};

		myspecs = myspecs ++ [
			\instrument, envir[\instrument],
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

	prBuildSynth {arg inKey, inFunc;

		SynthDef(inKey, {
			var gate = \gate.kr(1);
			var numvoices = 2;
			var ddepth = \ddepth.kr(0.1);
			var drate = \drate.kr(0.1);
			var detune = [1, 1.01];//LFNoise2.ar(drate.dup(numvoices)).bipolar(ddepth).midiratio;
			var freq = Vibrato.ar(\freq.ar(261), \vrate.ar(6), \vdepth.ar(0.0));

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
			sig = sig * \amp.kr(-3.dbamp);
			Out.ar(\out.kr(0), sig);

		}).add;
	}


	prNoteOn {arg midinote, vel=1;
		// there should only be one synth per note
		if (node.isPlaying) {
			var evt = {
				envir.select({arg val; val.isKindOf(Pattern).not});
				envir[\vel] = vel;
				envir;
			}.();
			var args = [\out, node.bus.index, \gate, 1, \freq, midinote.midicps] ++ evt.asPairs();
			//synths[midinote].add( Synth(synth.asSymbol, args, target:node.nodeID) );
			//["lastsynth not nil", synths[midinote]].postln;
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

	*initClass { all = () }
}