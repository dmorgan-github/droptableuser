(
/*
Event based sequencer
Depends on:
Pdefn(\grid) as 2D array or pattern of 2D arrays
e.g.
Pdefn(\grid, [
	[1,0,0,0,0,0,0],
	[1,0,0,0,0]
]);

Pdefn(\div) as float or pattern
e.g.
Pdefn(\div, 0.25);
*/
Fdef(\simplegrid, {arg key = \seq;

	Pdef(key, {

		Pspawner({arg ps;

			inf.do({arg i;

				var grid = Pdefn((key ++ '_grid').asSymbol).pattern;
				var div = Pdefn((key ++ '_div').asSymbol).pattern;

				var vals = grid.collect({arg row;
					if (row.isKindOf(Integer)) {
						if (i.mod(row) == 0) {1} {1}
					} {
						if (row.wrapAt(i).coin) {1} {0};
					};
				});

				var data = (count:i, trigs:vals, ps:ps);

				Evt.trigger((key ++ '_clock_pre').asSymbol, data);
				vals.do({arg val, j;
					if (val.coin) {
						var mykey = (key ++ '_e' ++ j.asInt).asSymbol;
						Evt.trigger(mykey, data);
					};
				});

				Evt.trigger((key ++ '_clock').asSymbol, data);
				ps.wait(div);
			});
		})
	});
});
)