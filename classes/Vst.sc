Vst : Ndef {

	var <fx, <pdata, <skipjack, <synth, <vst;

	*new {arg key, vst;
		^super.new(key).prVstInit(vst);
	}

	prVstInit {arg name;

		var func;
		var store = {
			if (fx.isNil.not) {
				//\store.debug(name);
				fx.getProgramData({ arg data; pdata = data;}, async:true);
			}
		};

		var index = 100;
		var synthdef = (name ++ '_' ++ UniqueID.next).asSymbol;

		SynthDef.new(synthdef, {arg in;
			var sig = In.ar(in, 2);
			var wet = ('wet' ++ index).asSymbol.kr(1);
			XOut.ar(in, wet, VSTPlugin.ar(sig, 2));
		}).add;

		Routine({
			1.wait;
			this.put(index, synthdef.debug(\synthdef));
		}).play;

		func = {

			Routine({

				2.wait;

				this.wakeUp;

				// FlowVar
				1.wait;
				synth = Synth.basicNew(synthdef, Server.default, this.objects[index].nodeID);
				synth.set(\in, this.bus.index);
				fx = VSTPluginController(synth);

				1.wait;
				// there can be a delay
				fx.open(name.asString, verbose:true, editor:true);
				name.debug(\loaded);

				1.wait;
				if (pdata.isNil.not) {
					fx.setProgramData(pdata);
				};

				this.wakeUp;

			}).play;
		};

		func.();
		skipjack = SkipJack(store, 60, name: key);
		CmdPeriod.add(func);

		vst = name;

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
		//^VSTPlugin.plugins[this.vst].printParameters;
	}

	clear {
		skipjack.stop;
		synth.free;
		fx.close;
		super.clear;
	}

	//set {arg key, val;
	//	fx.set(key, val)
	//}

	//map {arg key, val;
	//	fx.map(key, val)
	//}
}
