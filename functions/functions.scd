(
~synths = {

	SynthDescLib.global.synthDescs.do { |desc|
        if(desc.def.notNil) {
                "\nSynthDef %\n".postf(desc.name.asCompileString);
                desc.def.func.postcs;
        };
	};
};

~events = (

	on: {arg self, event, obj, func;
		NotificationCenter.register(self, event, obj, func);
	},

	trigger: {arg self, event, data = Dictionary.new(), defer = nil;

		if (defer.isNil, {
			NotificationCenter.notify(self, event, data);
		}, {
			{NotificationCenter.notify(self, event, data);}.defer(defer);
		});
	},

	drop: {
		NotificationCenter.clear;
	}
);

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

~toCps = {arg str;
	var degrees = (\c:0, \d:2, \e:4, \f:5, \g:7, \a:9, \b:11);
	var val = str.separate;
	var note = val[0].asSymbol;
	var octave = val[1].asInteger;
	var midinote = (24 + degrees[note]) + ((12 * octave) - 12);
	if (str.endsWith("#"), { midinote = midinote + 1});
	if (str.endsWith("b"), { midinote = midinote - 1});
	midinote.midicps;

	/*
	(
		// build a table of note names
		var table = ();
		value {
			var semitones = [0, 2, 4, 5, 7, 9, 11];
			var naturalNoteNames = ["c", "d", "e", "f", "g", "a", "b"];

			(0..9).do {|o|
				naturalNoteNames.do {|c, i|
					var n = (o + 1) * 12 + semitones[i];
					table[(c ++ o).asSymbol] = n;
					table[(c ++ "s"  ++ o).asSymbol] = n + 1;
					table[(c ++ "ss" ++ o).asSymbol] = n + 2;
					table[(c ++ "b"  ++ o).asSymbol] = n - 1;
					table[(c ++ "bb" ++ o).asSymbol] = n - 2;
				};
			};
		};

		// translate note names to midi keys
		table.atAll(#[c4, e4, gs4, c5, e5, gs5, c6])
	)
	*/
};

)