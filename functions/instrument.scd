(
~instrument = (

	inst_cnt: 0,
	inst_list: List.new(),
	inst_reset: {arg self;

		self.inst_cnt = 0;
		self.inst_list = List.new();
		Pdef.removeAll;
		Pdef.all;
	},
	inst_new: {arg self, pattern, repeats=inf, dur=4;

		self.inst_cnt = self.inst_cnt + 1;
		{
			var id = ("pb" ++ self.inst_cnt).asSymbol;
			var inst = (
				inst_id: id,
				inst_pattern: pattern,
				inst_start: {arg self;

					var id = self.inst_id.asSymbol;
					var cnt = 0;
					Pdef(id).clear();
					Pn(Plazy({
						if (self[\inst_onRepeat].isNil.not) {
							self.inst_onRepeat(cnt);
						};
						cnt = cnt + 1;
						Psync(Pdef(id, Pbind(*self.inst_pattern.getPairs())), dur, dur);
					}), repeats);

					/*
					Pn(
						Pfindur(dur,
							Pn(
								Plazy({

									if (self[\inst_onRepeat].isNil.not) {
										self.inst_onRepeat(cnt);
									};
									cnt = cnt + 1;
									Pdef(id, Pbind(*self.inst_pattern.getPairs()));
								})
							)
						),
						repeats
					);
					*/
				},
				inst_set: {arg self, parms;
					var id = self.inst_id.asSymbol;
					if (parms.isKindOf(Function)) {
						parms.value(self.inst_pattern);
					};
					if (parms.isKindOf(Event)) {
						parms.keysValuesDo({arg key, value;
							self.inst_pattern.put(key, value);
						});
					};
					Pdef(id, Pbind(*self.inst_pattern.getPairs()));
				},
				inst_stop: {arg self;
					var id = self.inst_id.asSymbol;
					Pdef(id).stop();
				},
				inst_asPattern: {
					Pdef(id);
				}
			);
			self.inst_list.add(inst);
			inst;
		}.value;
	}
);
)