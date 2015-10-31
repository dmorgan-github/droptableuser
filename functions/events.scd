(
~events = (

	on: {arg self, event, listener, func;
		NotificationCenter.register(self, event, listener, func);
	},

	trigger: {arg self, event, data = Dictionary.new();
		NotificationCenter.notify(self, event, data);
	},

	drop: {
		NotificationCenter.clear;
	}
);
)

(
~events.on('a', "a", {"a".postln;});
~events.on('a', "b", {"b".postln;});
~events.trigger('a');
)




