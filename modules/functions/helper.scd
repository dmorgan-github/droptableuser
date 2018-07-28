(
~find_id = {arg key;

	var envir = currentEnvironment;
	var count = 0;

	envir.keysValuesDo({arg k,v;
		if (v.class == NodeProxy and: k.asString.beginsWith(key.asString) )  {
			count = count + 1;
		}
	});

	(key ++ count.asString).asSymbol;
};

~ps_helper = {arg ps;

	var obj = (
		ps: ps,
		route: {arg self, src, dest, wet = 1;

			var node = self.ps[src.asSymbol];
			var id = dest.key.asSymbol;//~find_id.(dest);
			var func = currentEnvironment[dest.value.asSymbol];

			if (dest.class == Symbol) {
				id = dest.key.asSymbol;//~find_id.(dest);
				func = currentEnvironment[dest.value.asSymbol];
			} {
				func = dest;
			};

			self.ps[id.asSymbol] = func.(chans:node.numChannels);
			self.ps[id.asSymbol].set(\in, node, \wet, wet);
			self.ps[id.asSymbol].play;
			node.stop;
			self.ps[id.asSymbol];
		},
		stop_all: {arg self, fadeTime = 1;
			self.ps.arProxyNames.do({arg name; self.ps[name].stop(fadeTime:fadeTime)})
		},
		edit_all: {arg self;
			self.ps.arProxyNames.do({arg name; self.ps[name].edit})
		},
		ls_monitor: {arg self;
			self.ps.arProxyNames.do({arg name; self.ps[name].isMonitoring.if({ name.postln; }) })
		},
		structure: {arg self, keys;
			self.ps.getStructure(keys);
		}
	);
	obj;
};
)