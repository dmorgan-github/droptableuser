
/*
(
16.collect({arg val;
	if (0.4.coin) {
		(-4..4).choose
	}{
		Rest()
	}
}).asCompileString
)
*/
Pddl {

	*new {arg seq;
		var durs, degrees, lag, vels, legs;
		var parse, result;
		parse = {arg seq, result=[[],[],0,[],[]], div=1, isstart=true;
			seq.do({arg val, i;
				if (val.isRest) {
					if(isstart) {
						// lag only matters if we start the whole phrase
						// with a rest. inner rests don't require anything
						// to do with lag
						result[2] = result[2] + 1;
					}{
						if (val == \r) {
							// a rest
							result[0] = result[0].add(Rest(div));
							// degree
							result[1] = result[1].add(Rest());
							// vel
							result[3] = result[3].add(Rest());
							// legato
							result[4] = result[4].add(Rest());
						} {
							// otherwise a tie
							var mydurs = result[0];
							mydurs[mydurs.lastIndex] = mydurs[mydurs.lastIndex] + div;
						}
					}
				} {
					isstart = false;
					if (val.isArray) {
						if ((val.size == 2) and: val[1].isArray) {
							var myseq = val[1];
							var mydiv = val[0]/myseq.size * div;
							result = parse.(myseq, result, mydiv, isstart);
						} {
							var obj = val.value;
							var mydegree = obj;
							var vel = 1;
							var legato = 1;
							if (obj.isKindOf(Event)) {
								mydegree = obj[\deg].asStream;
								mydegree = Pfuncn({mydegree.next}, 1);

								vel = obj[\vel].asStream ?? vel;
								vel = Pfuncn({vel.next}, 1);

								legato = obj[\leg].asStream ?? legato;
								legato = Pfuncn({legato.next}, 1);

							};
							result[0] = result[0].add(div);
							result[1] = result[1].add(mydegree);
							result[3] = result[3].add(vel);
							result[4] = result[4].add(legato);
						}
					} {
						var obj = val.value;
						var mydegree = obj;
						var vel = 1;
						var legato = 1;
						if (obj.isKindOf(Event)) {
							var dstream, vstream, lstream;
							dstream = obj[\deg].asStream;
							mydegree = Pfuncn({dstream.next}, 1);

							vstream = obj[\vel].asStream ?? vel;
							vel = Pfuncn({vstream.next}, 1);

							lstream = obj[\leg].asStream ?? legato;
							legato = Pfuncn({lstream.next}, 1);

						};
						result[0] = result[0].add(div);
						result[1] = result[1].add(mydegree);
						result[3] = result[3].add(vel);
						result[4] = result[4].add(legato);
					}
				}
			});
			result.postln;
		};
		result = parse.(seq);
		lag = result[2];
		durs = result[0];
		durs[durs.lastIndex] = durs[durs.lastIndex] + lag;
		degrees = result[1];
		vels = result[3];
		legs = result[4];
		^Pbind(
			\pddl_dur, Pfunc({arg evt; if (evt[\dur].isNil) {1}{evt[\dur]}}),
			\pddl_degree, Pfunc({arg evt; if (evt[\degree].isNil) {0}{evt[\degree]}}),
			\pddl_vel, Pfunc({arg evt; if (evt[\vel].isNil) {1}{evt[\vel]}}),
			\pddl_legato, Pfunc({arg evt; if (evt[\legato].isNil) {1}{evt[\legato]}}),
			\dur, Pseq(durs, inf) * Pkey(\pddl_dur),
			\degree, Pseq(degrees, inf) + Pkey(\pddl_degree),
			\lag, Pn(lag) * Pkey(\pddl_dur),
			\legato, Pseq(legs, inf) * Pkey(\pddl_legato),
			\vel, Pseq(vels, inf) * Pkey(\pddl_vel)
		);
	}
}

Pddl2 {

	*new {arg seq;
		var durs, degrees, lag, vels, legs;
		var parse, result;
		parse = {arg seq, result=[[],[],0,[],[]], div=1, isstart=true;
			seq.do({arg val, i;
				if (val.isRest) {
					if(isstart) {
						// lag only matters if we start the whole phrase
						// with a rest. inner rests don't require anything
						// to do with lag
						result[2] = result[2] + 1;
					}{
						if (val == \r) {
							// a rest
							result[0] = result[0].add(Rest(div));
							// degree
							result[1] = result[1].add(Rest());
							// vel
							result[3] = result[3].add(Rest());
							// legato
							result[4] = result[4].add(Rest());
						} {
							// otherwise a tie
							var mydurs = result[0];
							mydurs[mydurs.lastIndex] = mydurs[mydurs.lastIndex] + div;
						}
					}
				} {
					isstart = false;
					if (val.isArray) {
						if ((val.size == 2) and: val[1].isArray) {
							var myseq = val[1];
							var mydiv = val[0]/myseq.size * div;
							result = parse.(myseq, result, mydiv, isstart);
						} {
							var obj = val.value;
							var mydegree = obj;
							var vel = 1;
							var legato = 1;
							if (obj.isKindOf(Event)) {
								mydegree = obj[\deg].asStream;
								mydegree = Pfuncn({mydegree.next}, 1);

								vel = obj[\vel].asStream ?? vel;
								vel = Pfuncn({vel.next}, 1);

								legato = obj[\leg].asStream ?? legato;
								legato = Pfuncn({legato.next}, 1);

							};
							result[0] = result[0].add(div);
							result[1] = result[1].add(mydegree);
							result[3] = result[3].add(vel);
							result[4] = result[4].add(legato);
						}
					} {
						var obj = val.value;
						var mydegree = obj;
						var vel = 1;
						var legato = 1;
						if (obj.isKindOf(Event)) {
							var dstream, vstream, lstream;
							dstream = obj[\deg].asStream;
							mydegree = Pfuncn({dstream.next}, 1);

							vstream = obj[\vel].asStream ?? vel;
							vel = Pfuncn({vstream.next}, 1);

							lstream = obj[\leg].asStream ?? legato;
							legato = Pfuncn({lstream.next}, 1);

						};
						result[0] = result[0].add(div);
						result[1] = result[1].add(mydegree);
						result[3] = result[3].add(vel);
						result[4] = result[4].add(legato);
					}
				}
			});
			result.postln;
		};
		result = parse.(seq);
		lag = result[2];
		durs = result[0];
		durs[durs.lastIndex] = durs[durs.lastIndex] + lag;
		degrees = result[1];
		vels = result[3];
		legs = result[4];

		^[
			Pseq(degrees, inf),
			Pseq(durs, inf),
			Pn(lag)
		];
	}
}