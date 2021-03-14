(
synth: {arg sig_in;

	var in = sig_in * \input.kr(1);
	var buf = \buf.kr(0);
	var sig = Shaper.ar(buf, in);
	sig = LeakDC.ar(sig);

	Splay.ar(sig,
		spread:\spread.ar(1),
		center:\pan.ar(0)
    ) * \output.ar(1);

},
specs: [
	\spread -> ControlSpec(0,1,\lin,0, 1, units:"stereo"),
	\pan -> ControlSpec(-1,1,\lin,0,0, units:"stereo"),
    \input -> ControlSpec(0, 2, \lin, 0, 1, units:"vol"),
    \output -> ControlSpec(0, 2, \lin, 0, 1, units: "vol")
],
ui: {|node|

	var key = node.key;
	var harms = [1, 0, 0, 0, 0, 0, 0];
	var buf = {
		var buf = B(key);
		if (buf.isNil) {
			var sig;
			B.alloc(key, 1024, 1);
			sig = Signal.chebyFill(513, harms);
			B(key).sendCollection(sig.asWavetableNoWrap);
			buf = B(key);
		};
		buf;
	}.();

	var view;
	var fxview;
	var knob = {|num|

		var pkey = ('p' ++ num).asSymbol;
		var initval = node.get(pkey) ? harms[num-1];

		var view = View().layout_(VLayout(

			Knob().mode_(\vert)
			.action_({|ctrl|
				var sig;
				var val = ctrl.value;
				harms[num-1] = val;
				sig = Signal.chebyFill(513, harms);
				B(key).sendCollection(sig.asWavetableNoWrap);
				node.set(pkey, val)
			})
			.value_(initval),
			StaticText()
			.string_(pkey)
			.align_(\center)
		).margins_(0).spacing_(0));
		view;
	};

	node.set(\buf, buf);

	view = View().layout_(HLayout(
		*[1, 2, 3, 4, 5, 7].collect({|i|
			knob.(i)
		})
	));

	view.layout.add(Button().string_("plot").action_({ buf.plot }));

	Require(App.librarydir ++ "ui/fx.scd");
	fxview = Fdef(\fx).(node, view);
	fxview.front;
};
)
