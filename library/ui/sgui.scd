(

/*
SendPeakRMS
*/

Require("~/projects/droptableuser/library/ui/common.scd");
Fdef(\sgui, {arg synth;

	var view = View()
	.layout_(VLayout().margins_(0.5).spacing_(0.5));

	var baseview;
	var ctrlView = Fdef(\ctrlview);
	var baseViewFunc = Fdef(\baseview);
	var specs = Halo.at(synth, \spec);
	var key = synth.key;
	var server = Server.default;
	var decay = 60;
	var rate = 30;
	var bus = synth.node.bus.index;
	var addAction = \addToTail;
	var target = synth.node.group;

	var decayrate = {arg value;
		value.neg.dbamp ** server.sampleRate.reciprocal;
	};

	var osckey = "/%levels".format(key).asSymbol;

	var watcher = SynthDef((key ++ '_amps').asSymbol, {arg decay=0.99994, rate=20;
		var in = In.ar(bus, 2);
		var pf = PeakFollower.ar(in, decay);
		var imp = Impulse.kr(rate);
		SendReply.kr(imp, osckey, [pf, pf.lag(0, 3)].flatten, 1000.rand);
	}).play(target, addAction:addAction);

	var levelView = {

		var lileft = LevelIndicator()
		.warning_(-2.dbamp)
		.critical_(0.dbamp)
		.drawsPeak_(true)
		.warningColor_(Color.yellow)
		.criticalColor_(Color.red)
		.style_(\continuous);

		var liright = LevelIndicator()
		.warning_(-2.dbamp)
		.critical_(0.dbamp)
		.drawsPeak_(true)
		.warningColor_(Color.yellow)
		.criticalColor_(Color.red)
		.style_(\continuous);

		var view = View().layout_(VLayout().spacing_(1).margins_(0));
		var osc = OSCdef((key ++ 'oscdef').asSymbol, {arg msg;
			{
				lileft.value = msg[3].ampdb.linlin(-40, 0, 0, 1);
				liright.value = msg[4].ampdb.linlin(-40, 0, 0, 1);
				lileft.peakLevel = msg[5].ampdb.linlin(-40, 0, 0, 1);
				liright.peakLevel = msg[6].ampdb.linlin(-40, 0, 0, 1);
			}.defer;
		}, osckey, server.addr)
		.permanent_(true);

		view.layout.add(lileft);
		view.layout.add(liright);
		view.onClose_({
			osc.debug(\free);
			osc.permanent_(false);
			osc.free;
		})
		.minHeight_(15)
		.maxHeight_(15)
	};

	var freqScopeView = {
		var node = synth.node;
		var view = View()
		.layout_(VLayout().spacing_(0).margins_(0));

		var fsv = FreqScopeView()
		.active_(true)
		.freqMode_(1)
		.inBus_(node.bus.index);

		view.layout.add(fsv);
		view.onClose_({
			fsv.debug(\close);
			fsv.kill;
		});
		view.maxHeight_(50)
	};

	var scrollView = ScrollView();
	var cb = {arg key, val;
		synth.set(key, val)
	};

	view.layout.add(freqScopeView.());
	view.layout.add(levelView.());

	{
		// bit of a hack since the specs are configured
		// in a dictionary which doesn't retain order
		// so, we can overload the units prop of a controlspec
		// as a way to gruop related controls together
		var groups = ();
		var specgroups;
		specs.do({arg val; groups[val.asSpec.units.asSymbol] = 1});
		specgroups = groups.keys.asSortedList.collect({arg group;
			var returnval = List.new;
			specs.keysValuesDo({arg k, v;
				if (v.units == group.asString) {
					returnval.add(k -> v);
				}
			});
			returnval.quickSort({arg a, b; a.key < b.key})
		});

		specgroups.do({arg val;
			val.do({arg assoc;
				var k = assoc.key;
				var v = assoc.value;
				var ctrl = ctrlView.(k, v.asSpec, Color.rand, synth.get(k), cb);
				view.layout.add(ctrl);
			});
		});

	}.();

	view.layout.add(nil);
	view.onClose_({
		watcher.debug(\free);
		watcher.free;
	});
	scrollView.canvas = view.background_(Color.clear);
	scrollView.fixedSize = Size(150, 175);

	baseview = baseViewFunc.(scrollView, synth.key, 150, 175);
	baseview.front;
});
//Fdef(\sgui).(~etf);
)

