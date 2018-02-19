// Deprecated
Dloopr {

	var < key;

	var < pattern;

	var < events;

	var <> grid;

	var <> rowSelector;

	var <> dur;

	classvar <>all;

	*initClass {
		all = IdentityDictionary.new;
	}

	*new {arg key, dur;

		var res = all.at(key);

		if (res.isNil) {
			res = super.new.prInit(key);
		};

		if (dur.isNil.not) {
			res.dur = dur;
		};

		^res;
	}

	*postGrid {

		// to have some place to start
		var grid = "[\n";
		grid = grid + "[0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0],\n";
		grid = grid + "[0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0],\n";
		grid = grid + "[0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0],\n";
		grid = grid + "[0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0],\n";
		grid = grid + "[0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0],\n";
		grid = grid + "[0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0],\n";
		grid = grid + "[0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0],\n";
		grid = grid + "[0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0]\n";
		grid = grid + "];\n";

		grid.postln;
	}

	prInit {arg prKey;

		events = Order.new;
		this.grid = [];
		this.rowSelector = {arg grid;
			grid;
		};

		pattern = Pdef(prKey.asSymbol,

			Pspawner({arg sp;

				var seq = this.dur.asStream;
				inf.do({arg i;
					sp.par(this.prProcess(i.asInt));
					sp.wait(seq.next);
				});
			})
		);

		key = prKey.asSymbol;
		all.put(key, this);
		^this;
	}

	prProcess  {arg count;

		^Plazy({

			var rows = this.rowSelector.value(this.grid);
			var evts = rows.collect({arg item, row;

				var val;
				var event;
				var x = (count % item.size).asInt;
				val = item.wrapAt(count);

				if ( val.isKindOf(Symbol) ) {
					Evt.trigger(val, (x: x, y: row, cols: item.size, rows: rows.size, count: count) );
				};

				event = this.events[val].value(x, row, item.size, rows.size, count);
				if (event.isKindOf(Event).not and: event.isKindOf(Pattern).not) {
					event = (isRest:true);
				};

				Pn( event, 1);
			});

			Ppar(evts);
		});
	}
}

