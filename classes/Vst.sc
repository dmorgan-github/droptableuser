Vst {

	classvar <all;
	var <key;
	var <outergrouop, <innergroup, <vstgroup;
	var <vstctrl, <node, <synth;

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

		Routine({

			var inbus;

			SynthDef.new(key, {
				var in = \in.kr(0);
				var bypass = \bypass.kr(0);
				var sig = VSTPlugin.ar(input:In.ar(in, 2), numOut:2, bypass:bypass, id:key) * \amp.kr(1);
				ReplaceOut.ar(\in.kr(0), sig);
			}).add;

			Server.default.sync;

			outergrouop = Group.new(Server.default).debug(\outergroup);
			innergroup = Group.new(outergrouop).debug(\innergroup);

			node = NodeProxy.audio(Server.default, 2);
			node.group_(innergroup).play;

			inbus = node.bus;
			vstgroup = Group.new(target:node.group.debug(\node), addAction:\addAfter);

			synth = Synth(key, [in: inbus], target:vstgroup.debug(\fx), addAction:\addToTail);
			vstctrl = VSTPluginController(synth, key);
			vstctrl.open(name, editor:true);

		}).play;
	}

	vol {arg amp=1;
		synth.set(\amp, amp)
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
		VSTPlugin.search;
		VSTPlugin.readPlugins.keysValuesDo({arg k, v; result.add(k)});
		^result.asArray;
	}

	*initClass {
		all = ();
	}
}