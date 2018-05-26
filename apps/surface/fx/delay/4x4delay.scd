(
func: {arg in;

	var durs = [6, 6, 6];
	var sigs = Array.fill(durs.size, {0});
	var nodes = Array.fill(durs.size, {arg i; FbNode(1, durs[i])});
	var sig, amps;


	// this is wrong

	nodes.do({arg node, k;
		var sig = if (k > 0) {sigs[k-1]} {Mix.ar(in)};
		sig = (sig * 1/3)
		+ (0..nodes.size-1).collect({arg i;
			var del = ('del' ++ k ++ '_' ++ i).asSymbol;
			var fb = ('fb' ++ k ++ '_' ++ i).asSymbol;
			node.delay(del.kr(0.5.rand)) * fb.kr(0.5.rand);
		}).sum;
		sigs[k] = sig;
		node.write(sigs[k]);
	});

	amps = durs.collect({arg dur, i; ('amp' ++ i).asSymbol.kr(1)});
	sig = Splay.ar( sigs * amps);
	sig;
},
specs: (
	del0_0: [0, 6, \lin, 0, 6.0.rand],
	del0_1: [0, 6, \lin, 0, 6.0.rand],
	del0_2: [0, 6, \lin, 0, 6.0.rand],

	del1_0: [0, 6, \lin, 0, 6.0.rand],
	del1_1: [0, 6, \lin, 0, 6.0.rand],
	del1_2: [0, 6, \lin, 0, 6.0.rand],

	del2_0: [0, 6, \lin, 0, 6.0.rand],
	del2_1: [0, 6, \lin, 0, 6.0.rand],
	del2_2: [0, 6, \lin, 0, 6.0.rand],

	fb0_0: [0, 1, \lin, 0, 0.3.rand],
	fb0_1: [0, 1, \lin, 0, 0.3.rand],
	fb0_2: [0, 1, \lin, 0, 0.3.rand],

	fb1_0: [0, 1, \lin, 0, 0.3.rand],
	fb1_1: [0, 1, \lin, 0, 0.3.rand],
	fb1_2: [0, 1, \lin, 0, 0.3.rand],

	fb2_0: [0, 1, \lin, 0, 0.3.rand],
	fb2_1: [0, 1, \lin, 0, 0.3.rand],
	fb2_2: [0, 1, \lin, 0, 0.3.rand]
)
)