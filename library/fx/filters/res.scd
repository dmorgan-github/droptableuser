(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);

	var sig = DynKlank.ar(`[
		[
			\f1.kr(82.406889228217),
			\f2.kr(164.81377845643),
			\f3.kr(195.99771799087),
			\f4.kr(493.88330125612),
			\f5.kr(659.25511382574),
			\f6.kr(1318.5102276515)
		] * \f.kr(1),

		[
			\f1amp.kr(0.39),
			\f2amp.kr(0.17),
			\f3amp.kr(0.26),
			\f4amp.kr(0.25),
			\f5amp.kr(0.25),
			\f6amp.kr(0.78)
		] * \a.kr(0.1),

		[
			\f1ring.kr(0.5),
			\f2ring.kr(0.24),
			\f3ring.kr(0.3),
			\f4ring.kr(0.51),
			\f5ring.kr(0.49),
			\f6ring.kr(0.53)
		] * \r.kr(0.5)
	], in);

	sig
},
specs: [
	\f1 -> ControlSpec(20, 20000, \lin, 0, 82.406889228217),
	\f2 -> ControlSpec(0.1, 12, \lin, 0, 164.81377845643),
	\f3 -> ControlSpec(0.1, 12, \lin, 0, 195.99771799087),
	\f4 -> ControlSpec(0.1, 12, \lin, 0, 493.88330125612),
	\f5 -> ControlSpec(0.1, 12, \lin, 0, 659.25511382574),
	\f6 -> ControlSpec(0.1, 12, \lin, 0, 1318.5102276515),
	\f1ring -> ControlSpec(0, 1, \lin, 0, 0.5),
	\f2ring -> ControlSpec(0, 1, \lin, 0, 0.24),
	\f3ring -> ControlSpec(0, 1, \lin, 0, 0.51),
	\f4ring -> ControlSpec(0, 1, \lin, 0, 0.5),
	\f5ring -> ControlSpec(0, 1, \lin, 0, 0.49),
	\f6ring -> ControlSpec(0, 1, \lin, 0, 0.53),
	\f1amp -> ControlSpec(0, 1, \lin, 0, 0.39),
	\f2mp -> ControlSpec(0, 1, \lin, 0, 0.17),
	\f3amp -> ControlSpec(0, 1, \lin, 0, 0.26),
	\f4amp -> ControlSpec(0, 1, \lin, 0, 0.25),
	\f5amp -> ControlSpec(0, 1, \lin, 0, 0.25),
	\f6amp -> ControlSpec(0, 1, \lin, 0, 0.78),
	\f -> ControlSpec(0, 1, \lin, 0, 1),
	\a -> ControlSpec(0, 1, \lin, 0, 1),
	\r -> ControlSpec(0, 1, \lin, 0, 1),
	\input -> [0, 10, \lin, 0, 1]
],
ui: {|node|
	var view = View().layout_(
		GridLayout.rows(
			6.collect({|i|
				var num = i+1;
				var key = ('f' ++ num).asSymbol;
				var val = node.get(key);
				Knob().action_({|ctrl|
					node.set(key, ctrl.value.linlin(0, 1, 80, 10000));
				})
				.value_(val.linlin(80, 10000, 0, 1))
				.mode_(\vert)
			}),
			6.collect({|i|
				var num = i+1;
				var key = ('f' ++ num ++ 'amp').asSymbol;
				var val = node.get(key);
				Knob().action_({|ctrl|
					node.set(key, ctrl.value);
				})
				.value_(val)
				.mode_(\vert)
			}),
			6.collect({|i|
				var num = i+1;
				var key = ('f' ++ num ++ 'ring').asSymbol;
				var val = node.get(key);
				Knob().action_({|ctrl|
					node.set(key, ctrl.value);
				})
				.value_(val)
				.mode_(\vert)
			})
		)
		.margins_(1)
		.spacing_(0)
	);
	view;
}
)