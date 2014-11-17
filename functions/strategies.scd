(
~strategies = (

	fooId: 0,
	stats: Dictionary.new(),
	replaceEveryNth: {arg self, key, n, func, phrase;

		var cnt = 1;
		var pattern = phrase[key.asSymbol];
		var list = List.new();

		if (self.stats.at(key.asSymbol).isNil, {
			self.stats.put(key.asSymbol, list)
		}, {
			list = self.stats[key.asSymbol];
		});

		phrase[key.asSymbol] = Pcollect({arg val;
			var result = val;
			if (cnt % n == 0) {
				result = func.value(cnt, result);
			};
			cnt = cnt + 1;
			list.add(result);
			result;
		}, pattern);
		phrase;
	},
	onEveryNth: {arg self, n, func, phrase;

		var cnt = 1;
		var id = self.fooId = self.fooId + 1;

		id = "foo" ++ id;
		phrase[id.asSymbol] = Pfunc({arg pbind;

			if (cnt % n == 0) {
				func.value(cnt, pbind);
			};
			cnt = cnt + 1;
		});
		phrase;
	}
);
)