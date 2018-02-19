
Pevery {
	*new {arg sync, dur, pattern, repeats = inf;

		^Pn(
			Psync(
				Pfindur(dur,
					pattern
				),
				sync, sync
			),
			repeats
		)
	}
}

PmonoPar2 : Plazy {
	*new { |setPatternPairs, defname = \default, offset = 1e-6|
		^super.new({
			var g = Group(), cleanup = EventStreamCleanup.new;
			Pseq([
				Pbind(
					\instrument, defname,
					\type, Pseq([\on]),
					\delta, offset,
					\group, g,
					\cleanup, Pfunc { |e| cleanup.addFunction(e, { g.release }) }
				),
				Ptpar(setPatternPairs.collect { |p, j|
					var pairs, keys = p.select { |x,i| i.even }, keysAfterDelta;
					keysAfterDelta = keys.copyToEnd(keys.indexOf(\delta) + 1);
					#[note, degree, midinote].any { |x| keysAfterDelta.includes(x) }.if {
						keysAfterDelta = keysAfterDelta.add(\freq)
					};
					pairs = [\type, \set] ++ p ++
						keys.includes(\args).not.if { [\args, keysAfterDelta] } ++
						[\id, g];
					[j * offset, Pbind(*pairs)]
				}.flatten),
				Pbind(\instrument, defname, \type, Pseq([\off]), \delta, offset, \group, g)
			])
		})
	}
}