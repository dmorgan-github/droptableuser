Vst {

	classvar <all;
	var <key;
	var <outergroup, <innergroup, <vstgroup;
	var <vstctrl, <node, <synth;
	var func;

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
		^this;
	}

	load {arg name;

		func = {

			Routine({

				var inbus;

				SynthDef.new(key, {
					var in = \in.kr(0);
					var bypass = \bypass.kr(0);
					var sig = VSTPlugin.ar(input:In.ar(in, 2), numOut:2, bypass:bypass, id:key) * \amp.kr(1);
					ReplaceOut.ar(\in.kr(0), sig);
				}).add;

				Server.default.sync;

				outergroup = Group.new(Server.default).debug(\outergroup);
				innergroup = Group.new(outergroup).debug(\innergroup);

				if (node.isNil) {
					// TODO: still have to reset the source
					// after cmdperiod in order for sound to contine
					// but i'm not sure why
					"initialize nodeproxy".postln;
					node = NodeProxy.audio(Server.default, 2);
				};
				node.group_(innergroup);//.play;

				inbus = node.bus;
				vstgroup = Group.new(target:node.group.debug(\node), addAction:\addAfter);

				synth = Synth(key, [in: inbus], target:vstgroup.debug(\fx), addAction:\addToTail);
				vstctrl = VSTPluginController(synth, key);
				vstctrl.open(name, editor:true);

			}).play;
		};

		func.value;

		// TODO: is this the right way to do this?
		CmdPeriod.add(func);
	}

	bypass {arg bypass=0;
		synth.set(\bypass, bypass)
	}

	set {arg key, val;
		vstctrl.set(key, val)
	}

	map {arg key, val;
		vstctrl.map(key, val)
	}

	get {arg key, cb={arg v; v.postln;};
		vstctrl.get(key, cb);
	}

	editor {
		vstctrl.editor;
	}

	gui {
		vstctrl.gui;
	}

	keys {
		var result = List.new;
		VSTPlugin.search(verbose:false);
		VSTPlugin.readPlugins.keysValuesDo({arg k, v; result.add(k)});
		^result.asArray;
	}

	free {
		synth.free;
		vstgroup.free;
		innergroup.free;
		outergroup.free;
		node.clear;
		CmdPeriod.remove(func);
	}

	*initClass {
		all = ();
	}
}