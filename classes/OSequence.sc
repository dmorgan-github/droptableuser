OSequence {
	var <>events;
	var <>extend=true, <>modifyEvents=true, <>duration = 0;

	*new {
		|... args|
		var obj = super.new.init;
		args.pairsDo {
			|time, value|
			obj.put(time, value)
		};
		^obj
	}

	*from {
		|streamable, duration, trim=true, protoEvent|
		^this.fromStream(streamable.asStream, duration, trim, protoEvent);
	}

	*fromStream {
		|stream, duration, trim=true, protoEvent|
		var seq = OSequence();
		var startTime = 0;
		var endTime = startTime + (duration ? 1000);
		var time = startTime;
		var oldTime = thisThread.beats;

		thisThread.beats = startTime;

		protect {
			protoEvent = protoEvent ?? { Event.default };
			while {
				var dur, outEvent;

				outEvent = stream.next(protoEvent.copy);

				if (outEvent.notNil) {
					if (outEvent.isRest) {
						dur = outEvent.dur.value();
					} {
						seq.put(time, outEvent);
						dur = outEvent.dur.value();

						if (trim && ((time + dur) > endTime)) {
							dur = endTime - time;
							outEvent.dur = dur;
						};
					};

					if (dur.notNil) {
						thisThread.beats = time = time + dur;
					}
				};

				(dur.notNil && outEvent.notNil && (time < endTime));
			};

			if (duration.notNil) {
				seq.duration = duration;
			} {
				seq.duration = 0;
				seq.events.do {
					|eventList, t|
					eventList.do {
						|e|
						seq.duration = max(seq.duration, t + seq.prGetDur(e))
					}
				}
			};
		} {
			thisThread.beats = oldTime;
		};

		^seq
	}

	copy {
		var seqCopy, eventsCopy;

		eventsCopy = events.collect {
			|eventList|
			eventList.collect {
				|e|
				e.copy;
			}
		};

		seqCopy = OSequence();
		seqCopy.events = eventsCopy;
		seqCopy.extend = this.extend;
		seqCopy.modifyEvents = this.modifyEvents;
		seqCopy.duration = this.duration;
		^seqCopy
	}

	init {
		events = Order();
	}

	at {
		|time|
		^events[time] ?? {
			var newList;
			events[time] = newList = List();
			newList;
		};
	}

	do {
		|func|
		var i = 0;
		events.do {
			|eventList, t|
			eventList.do {
				|event|
				func.value(event, t, i);
				i = i + 1;
			}
		}
	}

	collect {
		|func|
		var newSeq = OSequence();
		this.do {
			|e, t|
			newSeq.put(t, func.value(e, t));
		};
		^newSeq
	}

	collectAs {
		|func, class|
		var newSeq = class.new();
		this.do {
			|e, t|
			newSeq = newSeq.add(func.value(e));
		};

		^newSeq;
	}

	doTimes {
		|func|

		events.do {
			|eventList, time|
			func.value(eventList.shallowCopy, time);
		}
	}

	pairsDo {
		|func|
		var indexA, indexB;
		if (events.indices.size > 1) {
			(1..(events.indices.size-1)).do {
				|i|
				indexA = events.indices[i - 1];
				indexB = events.indices[i];
				func.value(
					events.array[i - 1],
					events.array[i],
					indexA, indexB,
					i
				)
			}
		}
	}

	doReplaceTimes {
		|func|

		events = events.collect({
			|eventList, time|
			func.value(eventList, time)
		}).reject(_.isEmpty)
	}

	put {
		|time, value|
		if (value.notNil) {
			if (extend) {
				duration = max(
					duration,
					time + this.prGetDur(value)
				);
			};
			this.at(time).add(value);
		}
	}

	putAll {
		|time, valueArray|
		if (valueArray.notNil) {
			if (extend) {
				duration = max(
					duration,
					time + valueArray.maxValue({
						|e|
						this.prGetDur(e)
					})
				)
			};
			this.at(time).addAll(valueArray);
		}
	}

	putSeq {
		|baseTime, seq|
		seq.do {
			|event, time|
			this.put(baseTime + time, event)
		}
	}

	delete {
		|start, end, ripple=false|
		start = max(start, 0);
		end = end ?? duration;

		events = events.reject {
			|event, t|
			(t >= start) && (t < end)
		};

		if (ripple) {
			var range = end - start;
			this.warp({
				|t|
				if (t >= start) {
					if (t < end) {
						start.max(0)
					} {
						// >end
						t - range;
					}
				} { t }
			}, ripple);
		} {
			if (modifyEvents) {
				this.warp({
					|t|
					if ((t >= start) && (t < end)) {
						start
					} { t }
				}, false)
			}
		}
	}

	trim {
		|start=0, end=inf|
		this.delete(end, inf, true);
		if (start > 0) {
			this.delete(0, start, true);
		}
	}

	warp {
		|func, warpDuration=true|
		var oldEvents = events;
		events = Order();

		oldEvents.do {
			|eventList, time|
			eventList.do {
				|event|
				var newStart = func.value(time, event);

				if (modifyEvents) {
					var newEnd = this.prGetSustain(event).asArray.maxItem;
					newEnd = func.value(time + newEnd, event);
					if (newEnd < newStart) {
						var e = newEnd;
						newEnd = newStart;
						newStart = e;
					};
					this.put(newStart, event);
					this.prSetSustain(event, newEnd - newStart);
				} {
					this.put(newStart, event);
				}
			}
		};

		if (warpDuration) {
			duration = func.value(duration);
		}
	}

	envWarp {
		|env, warpDuration=true|
		env = env.copy.duration_(duration);
		this.warp({
			|time|
			env.at(time);
		}, warpDuration)
	}

	stretch {
		|newDuration|
		var ratio = newDuration / duration;
		this.warp({ |t| t * ratio }, true);
	}

	stretchBy {
		|factor=1|
		this.warp({ |t| t * factor }, true);
	}

	reverse {
		this.warp({
			|t|
			duration - t
		}, false);
	}

	filter {
		|func|
		this.doReplace {
			|e, t|
			if (func.(e, t)) {
				e
			} {
				nil
			}
		}
	}

	doPutSeq {
		|func|
		events.copy.do {
			|eventList, time|
			eventList.copy.do {
				|event|
				this.putSeq(time, func.value(event, time))
			}
		}
	}

	doReplace {
		|func|
		events = events.collect({
			|eventList, time|
			eventList.collect({
				|event|
				func.value(event, time)
			}).reject(_.isNil)
		}).reject(_.isEmpty)
	}

	doReplaceSeq {
		|func|
		var oldEvents = events;
		events = Order();
		oldEvents.do {
			|eventList, time|
			eventList.do {
				|event|
				this.putSeq(time, func.value(event, time));
			};
		}
	}

	sub {
		|start = 0, end|
		^this.copy.trim(start, end);
	}

	overwrite {
		|start, seq|
		var end = start + seq.duration;
		this.delete(start, end, false);
		this.putSeq(start, seq);
	}

	insert {
		|time, seq|
		this.warp({
			|t|
			if (t > time) {
				t = t + seq.duration
			} {
				t
			}
		}, true);
		this.putSeq(time, seq);
	}

	collectKey {
		|keys|
		var result;
		keys = keys.asArray;
		result = this.collectAs({
			|e|
			keys.collect {
				|key|
				e[key]
			}
		}, Array).flop;
		if (keys.size == 1) {
			result = result[0]
		};
		^result
	}

	setKey {
		|keys, values, at=\wrapAt|
		if (values.isFunction) {
			^this.prSetKeyFn(keys, values, at)
		} {
			if (keys.isCollection.not) {
				keys = [keys];
				values = [values];
			};
			values = values.collect(_.asArray);
			this.do {
				|e, t, i|
				keys.do {
					|key, j|
					e[key] = values.perform(at, j).perform(at, i);
				}
			}
		}
	}

	prSetKeyFn {
		|keys, valueFunc, at=\wrapAt|
		keys = keys.asArray;
		this.do {
			|e, t|
			valueFunc.value(e.atAll(keys), t).do {
				|value, i|
				e[keys[i]] = value;
			}
		}
	}

	++ {
		|other|
		var newDuration = this.duration + other.duration;
		^this.copy.putSeq(this.duration, other).duration_(newDuration);
	}

	times { ^events.indices }

	indices { ^events.indices }

	replaceSub {
		|start=0, end, func, ripple=false|
		var sub;

		if (func.isKindOf(OSequence)) {
			sub = func;
		} {
			sub = this.sub(start, end);
			sub = func.value(sub);
		};

		if (ripple) {
			this.delete(start, end, ripple).insert(start, sub);
		} {
			this.overwrite(start, sub);
		}
	}

	prGetDur {
		|e|
		^try({
			e[\dur] ?? 0
		}, {
			0
		})
	}

	prSetDur {
		|e, dur=0|
		try {
			e[\dur] = dur
		}
	}

	prGetSustain {
		|e|
		var dur;
		^try({
			e.use({ e[\sustain].value }) ?? {
				e.use({ e[\dur].value })
			} ?? {
				0
			};
		}, {
			0
		})
	}

	prSetSustain {
		|e, dur=0|
		try {
			e[\sustain] !? {
				e[\sustain] = dur
			} ?? {
				e[\dur] = dur;
			}
		}
	}

	prUpdateEventDurs {
		var lastTime = 0;
		var lastEvents, duration;
		events.do {
			|eventList, time|
			// "% - %".format(time, lastTime).postln;
			if (lastEvents.notNil) {
				duration = time - lastTime;
				lastEvents.do {
					|e|
					if (e.isKindOf(Event)) {
						this.prSetSustain(e, duration)
					}
				}
			};
			lastEvents = eventList;
			lastTime = time;
		};
		duration = max(0, this.duration - lastTime);
		lastEvents.do {
			|e|
			if (e.isKindOf(Event)) {
				this.prSetSustain(e, duration);
			}
		}
	}

	play {
		|event=(Event.default), repeats=1|
		EventStreamPlayer(this.asStream(repeats), event).play
	}

	embedInStream {
		|inEvent, repeats|
		repeats.do {
			var lastEvents;
			var lastTime = 0;
			var playEvents = {
				|time|
				lastEvents.do {
					|event, i|
					event = inEvent.composeEvents(event);

					if (i < (lastEvents.size - 1)) {
						event[\delta] = 0;
					} {
						event[\delta] = time - lastTime;
					};

					inEvent = event.yield;
					if (inEvent.isNil) {
						nil.yield;
					}
				}
			};

			events.do {
				|eventList, time|

				if (lastEvents.isNil) {
					if (time > 0) {
						Event.silent(time).yield;
					}
				} {
					playEvents.value(time);
				};

				lastEvents = eventList;
				lastTime = time;
			};

			playEvents.value(duration);
		}
	}

	asStream {
		|repeats=1|
		^Routine({ arg inval; this.embedInStream(inval, repeats) })
	}
}