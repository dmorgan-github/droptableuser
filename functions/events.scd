(
~events = (

	eventsDict: Dictionary.new(),

	on: {arg self, event, func;
		var ary = self.eventsDict.at(event);
		if (ary.isNil, {
			ary = Array.new(100);
			ary.add(func);
			self.eventsDict.put(event, ary);
		}, {
			ary.add(func);
		});
	},

	trigger: {arg self, event, data = Dictionary.new();
		var keys = self.eventsDict.keys();
		keys.do({arg item, i;
			if (item == event) {
				var ary = self.eventsDict.at(item);
				ary.do({arg f;
					f.value(data);
				});
			};
		});
	},

	off: {arg self;
		var keys = self.eventsDict.keys();
		keys.do({arg item, i;
			self.eventsDict.removeAt(item);
		});
	}
);
)

(
~events.off();
~events.on('a', {"a".postln;});
~events.trigger('a');
)




