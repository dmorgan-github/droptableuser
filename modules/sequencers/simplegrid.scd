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

			var grid = Pdefn(\grid).asStream;
			var div = Pdefn(\div).asStream;

			inf.do({arg i;

				var vals = grid.next.collect({arg row;
					if (row.isKindOf(Integer)) {
						if (i.mod(row) == 0) {1} {1}
					} {
						if (row.wrapAt(i).coin) {1} {0};
					};
				});

				var data = (count:i, trigs:vals, ps:ps);

				vals.do({arg val, j;
					if (val.coin) {
						var key = ('e' ++ j.asInt).asSymbol;
						Evt.trigger(key, data);
					};
				});

				Evt.trigger(\clock, data);
				ps.wait(div.next);
			});
		})
	});
});
)