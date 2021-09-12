{|inKey, inFunc, specs|

    var metadata = if (specs.notNil) {(specs:specs.asDict)};
	
    SynthDef(inKey, {
		var sig = SynthDef.wrap(inFunc, prependArgs:[nil, 1, nil]);
		sig = LeakDC.ar(sig);
		sig = sig * \vel.kr(1);
		sig = Splay.ar(sig, \spread.kr(1), center:\pan.kr(0));
		sig = sig * \amp.kr(-6.dbamp);
		Out.ar(\out.kr(0), sig);
	}, 
    metadata: metadata
).add;
}
