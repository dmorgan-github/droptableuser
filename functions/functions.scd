(
~sawAmps = {arg topPartial = 20;
	(1..topPartial).reciprocal;
};
~squareAmps = {arg topPartial = 20;
	[(1, 3 .. topPartial).reciprocal, 0].lace(topPartial);
};
~triangleAmps = {arg topPartial = 20;
	[(1, 3 .. topPartial).reciprocal.squared * #[1, -1], 0].lace(topPartial)
};
~sawSignal = {arg size, topPartial = 20;
	Signal.sineFill(size, ~sawAmps.(topPartial:topPartial));
};
~squareSignal = {arg size, topPartial = 20;
	Signal.sineFill(size, ~squareAmps.(topPartial:topPartial));
};
~triangleSignal = {arg size, topPartial = 20;
	Signal.sineFill(size, ~triangleAmps.(topPartial:topPartial));
};

SynthDef.new(\mix, {arg out, pan = 0, amp = 0.5;
	var audio = NumChannels.ar(In.ar(out), 1);
	Out.ar(0, Pan2.ar(audio * amp, pan));
}).add;

/*************************************************
~samples
*************************************************/
~samples = (

	default_dir: "/Users/david/projects/droptableuser/samples/",
	samples_list: nil,
	ls: {arg self, path;

		var folder;
		if (path.isNil, {
			path = self.default_dir;
		});

		self.samples_list = List.new;
		folder = PathName.new(path);
		"---------------------------".postln;
		folder.filesDo {arg path;
			path.fullPath.postln;
			self.samples_list.add(path.fullPath);
        };
		"---------------------------".postln;
	},

	load: {arg self, name, action;

		var len = 0;
		var i = 0;
		var path = nil;
		var found = false;
		var buf = nil;

		if (self.samples_list.isNil, {
			self.ls();
		});

		len = self.samples_list.size();
		while( {(found == false) && (i < len)}, {
			var p = self.samples_list.at(i);
			if ( p.containsi(name), {
				path = p;
				found = true;
			});
			i = i + 1;
		});

		if (self.at(name.asSymbol).isNil, {
			if (path.notNil, {
				if (action.notNil, {
					format("loading %", name).postln;
					Buffer.read(s, path:path, action:action);
				}, {
					format("loading %", name).postln;
					buf = Buffer.read(s, path:path);
					self.put(name.asSymbol, buf);
				});
			}, {
				"Sample not found".error;
			});
		},{
			format("Sample already loaded -> %", name).postln;
			buf = self[name.asSymbol];
		});
		buf;
	}
);

//s.freeAll;
//s.queryAllNodes;
//s.newBusAllocators;
//grp.deepFree;
/*************************************************
~synth factory method
*************************************************/
~synth = {arg id, func;
	var synthId = id.asSymbol;
	SynthDef(synthId, {arg out;
		var sig = SynthDef.wrap(func);
		OffsetOut.ar(out, NumChannels.ar(sig,1));
	}).add;
};

/*************************************************
~filter factory method
*************************************************/
~filter = {arg id, func;
	var synthId = id.asSymbol;
	SynthDef.new(synthId, {arg out, dryWet = 0;
		var in = In.ar(out);
		var fx = in;
		var env = EnvGate.new;

		fx = SynthDef.wrap(func, nil, fx);
		in = XFade2.ar(in, fx, dryWet); // -1, 1
		XOut.ar(out, env, in);
	}).add;
};

~ctrls = ();
~ctrl = {arg synth, prop, func;

	var id = (synth.defName ++ prop ++ synth.nodeID.asString).asSymbol;
	var bus, ctrl;

	if (~ctrls[id].isNil, {
		~ctrls[id] = ();
		~ctrls[id].bus = Bus.control(s, 1);
	}, {
		if (~ctrls[id].ctrl.isPlaying, {
			~ctrls[id].ctrl.free;
		});
	});

	bus = ~ctrls[id].bus;
	ctrl = SynthDef.new(id, {arg out;
		var sig = SynthDef.wrap(func);
		Out.kr(out, sig);
	}).play(args:[\out, bus]);

	NodeWatcher.register(ctrl);
	~ctrls[id].ctrl = ctrl;

	synth.map(prop, bus.index);
	ctrl;
};

/*************************************************
~instr
*************************************************/
~instrs = ();
~instr = {arg id ... synths;

	var grp, bus, instr;
	id = id.asSymbol;

	if (~instrs[id].notNil, {
		if (~instrs[id].grp.isPlaying, {
			~instrs[id].grp.deepFree;
			~instrs[id].grp = Group.new;
		}, {
			~instrs[id].grp = Group.new;
		});
		NodeWatcher.register(~instrs[id].grp);
		instr = ~instrs[id];
	}, {
		instr = (
			id: id,
			grp: Group.new,
			bus: Bus.audio(s,2)
		);
		~instrs[id] = instr;
		NodeWatcher.register(~instrs[id].grp);
	});

	grp = instr.grp;
	bus = instr.bus;

	synths.do({arg synth, i;
		var name = synth.asSymbol;
		if (i == 0, {
			instr.plays = {arg self ... args;
				var list = args.asList;
				list.add(\out);
				list.add(bus.index);
				Synth.head(grp, name, list.flatten);
			};
		}, {
			instr[name] = Synth.tail(grp, name, [\out, bus]);
		});
	});

	instr[\mix] = Synth.tail(grp, \mix, [\out, bus]);
	instr;
};

~toCps = {arg str;
	var degrees = (\c:0, \d:2, \e:4, \f:5, \g:7, \a:9, \b:11);
	var val = str.separate;
	var note = val[0].asSymbol;
	var octave = val[1].asInteger;
	var midinote = (24 + degrees[note]) + ((12 * octave) - 12);
	if (str.endsWith("#"), { midinote = midinote + 1});
	if (str.endsWith("b"), { midinote = midinote - 1});
	midinote.midicps;
};

~toSeq = {arg str;
	str.split($ ).collect({arg item;
		var result = nil;
		if ( (item == "").not, {
			result = ~toCps.(item);
		} );
		result;
	});
};

/*************************************************
~stepper
*************************************************/
~stepper = {arg id, init, steps = 16, waitBefore = false, repeat = inf;

	var tdefId = id.asSymbol;
	Tdef(tdefId).envir = (
		dur: {1;},
		steps: List.newClear(steps)
	);

	waitBefore = ((waitBefore == \waitBefore).or(waitBefore));
	if ((repeat == inf).not, {
		repeat = steps * repeat;
	});
	Tdef(tdefId).quant = 1;
	Tdef(tdefId, {arg envir;

		init.(envir);
		repeat.do({arg i;
			var index = i%envir.steps.size();
			var func = envir.steps[index];

			var w = envir.dur();
			w = w + [rrand(0.0001, 0.0008), 0, rrand(0.0001, 0.0008).neg].choose;

			if (waitBefore,{w.wait;});
			if (func.notNil, {
				func.();
			});
			if (waitBefore.not,{w.wait;});
		});
	});
};

~phrase = {arg id, instr, steps, dur = 1 ... args;

	if (dur.isNumber, {
		var num = dur;
		dur = {num};
	});

	~stepper.(id, {arg envir;
		args.do({arg item;
			var index = item.key;
			var funcArgs = item.value;
			envir.dur = dur;
			envir.steps[index] = {instr.plays(funcArgs)};
		});
	}, steps, false, inf);
};

~freqGrid = {arg id, instr, dur, seq;

	id = id.asSymbol;
	Tdef(id, {arg envir;
		var index = 0;
		envir.seq = seq;
		envir.dur = dur;
		inf.do({arg i;
			var freq;
			var size = envir.seq.size();
			var w = envir.dur();
			w = w + [rrand(0.0001, 0.0008), 0, rrand(0.0001, 0.0008).neg].choose;

			if ((index >= size), {index = 0});
			freq = envir.seq[index];

			if (freq.notNil, {
				instr.plays(\freq, freq);
			});
			index = index + 1;
			w.wait;
		});
	});
};

)