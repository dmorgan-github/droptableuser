Spawner2 : Pattern {
	var genStream;
	var priorityQ;
	var now;
	var <event;

	*new { | func, stackSize=64 |
		^super.new.init( func, stackSize)
	}

	suspend { | stream |
		priorityQ.removeValue(stream);
	}

	suspendAll {
		priorityQ.clear
	}

	init { | func, stackSize |
		priorityQ = PriorityQueue.new;
		genStream = Routine({func.value(this) }, stackSize);
		now = 0;
		priorityQ.put(now, genStream);
	}

	par { | pattern, delta = 0 |
		var stream = pattern.asStream;
		priorityQ.put(now + delta, stream);
		^stream;
	}

	seq { | pattern |
		pattern.embedInStream(event)
	}

	wait { | dur |
		Event.silent(dur, event).yield
	}

	embedInStream { | inevent|

		var outevent, stream, nexttime, cleanup;
		event = inevent;					// gives genStream access to the event
		cleanup = EventStreamCleanup.new;

		while({
			priorityQ.notEmpty
		},{
			stream = priorityQ.pop;
			outevent = stream.next(event).asEvent;

			if (outevent.isNil, {
				nexttime = priorityQ.topPriority;
				if (nexttime.notNil, {
					// that child stream ended, so rest until next one
					outevent = Event.silent(nexttime - now, event);
					cleanup.update(outevent);
					event = outevent.yield;
					now = nexttime;
				},{
					priorityQ.clear;
					^cleanup.exit(event);
				});
			},{
				cleanup.update(outevent);
				// requeue stream
				priorityQ.put(now + outevent.delta, stream);
				nexttime = priorityQ.topPriority;
				outevent.put(\delta, nexttime - now);

				event = outevent.yield;
				now = nexttime;
			});
		});
		^event;
	}
}

Pspawner2 : Prout {

	asStream {
		^Routine({ | inval |
			this.embedInStream(inval)
		})
	}

	embedInStream { | inevent |
		^Spawner2(routineFunc).embedInStream(inevent)
	}

}