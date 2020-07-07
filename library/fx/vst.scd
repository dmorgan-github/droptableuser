/*
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
*/



(
view: {arg objName, envir, components;

	var in_node, node, vstcntrl, view, synth;
	var parentGroup = Group.new(Server.default).debug(\parent);
	var innerGroup = Group.new(parentGroup).debug(\inner);
	var fxGroup;
	var vsts, func;

	SynthDef.new(objName, {
		var in = \in.kr(0);
		var sig = VSTPlugin.ar(input:In.ar(in, 2), numOut:2, id:objName) * \amp.kr(1);
		ReplaceOut.ar(\in.kr(0), sig);
	}).add;

	node = NodeProxy.audio(s, 2);
	node.group_(innerGroup).play;

	func = {arg path;
		var inbus = node.bus;
		fxGroup = Group.new(target:node.group.debug(\node), addAction:\addAfter);

		synth = Synth(objName, [in: inbus], target:fxGroup.debug(\fx), addAction:\addToTail);
		vstcntrl = VSTPluginController(synth, objName);
		vstcntrl.open(path, editor:true);
	};

	vsts = PathName("/Library/Audio/Plug-Ins/VST").entries.collect({arg pn;
		var fp = pn.fullPath.asString;
		var name = fp[0..(fp.size-2)];
		var path = PathName(name).pathOnly;
		name = PathName(name).fileNameWithoutExtension;
		path = path ++ name;
	});

	view = View().layout_(VLayout());
	view.layout.add(HLayout(
		PopUpMenu().items_([""] ++ vsts).action_({arg ctrl;
			var item = ctrl.item;
			if (item != "") {
				func.(item);
			}
		}),
		Button().action_({ vstcntrl.editor; })
	));
	envir[objName] = node;

	NotificationCenter.register(view, \close, view, {arg msg;
		msg.debug("clean up");
		// not sure why this needs to be deferred
		// otherwise it crashes the server
		{
			synth.release;
			synth.free;
			fxGroup.free;
			innerGroup.free;
			parentGroup.free;
		}.defer(2);
	});

	view;
}
)