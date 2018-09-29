(
~grid_player = {

	var obj = (
		events: [],
		dur: 1,
		matrix: [],
		process: {arg self, count, time;

			//Plazy({

			var rows = self.matrix;
			var evts = rows.collect({arg item, row;

				var x = (count % item.size).asInt;
				var myEvent = self.events.wrapAt(row).value;
				var val = item.wrapAt(count).value;
				var event = (note:Rest());

				case
				{val.isKindOf(Event)} {
					val.keysValuesDo({arg k, v;
						myEvent[k] = v;
					});
					event = myEvent;
				}
				{val.isKindOf(Collection)}{

					var wtf;
					if (val.size == 2) {
						if (val[1].size > 1) {
							val = val.convertRhythm;
						}
					};

					event = myEvent;
					// why wont' this work????
					//myEvent[\dur] = Pseq(val.asArray, 1);
					//event = Pbind(*myEvent.getPairs());
				}
				{val.isNumber} {
					if (val.coin) {
						event = myEvent;
					};
				};

				Pn(event, 1);
			});

			Ppar(evts);
		},
		player: {arg self;

			var player = Pspawner({arg ps;

				inf.do({arg i;

					var time = self.dur.next;
					var evt = self.process(i.asInt, time);
					ps.par(evt);
					ps.wait(time);
				});
			});
			player;
		}
	);
	obj;
};
)

(
var event = ();
event[\dur] = Pseq([1].asArray, inf);
Ppar([
	Pn(Pbind(*event.getPairs()), 1)
]).play
)