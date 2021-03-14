/*
basically stolen and adapted from https://github.com/scztt/OSequence.quark
*/
E {
    var <>events, <>duration;

    *new {
        ^super.new.init();
    }

    *fromPattern {|pattern, duration|
        var seq = E();
        seq.events = E.order(pattern, duration);
        seq.duration = duration;
        ^seq;
    }

    init {
        ^this;
    }

    *order {|pattern, duration|
        var order = Order.new;
        var time = 0;
        var stream = pattern.asStream;
        var evt = stream.next(Event.default);
        while ( {evt.isNil.not and: (time < duration) }, {
            var dur = evt[\dur];
            if ((time + dur) > duration) {
                dur = duration - time;
                evt[\dur] = dur;
            };
            order.put(time, evt);
            time = time + dur;
            evt = stream.next(evt);
        });
        ^order;
    }

    put {|time, event|
        // need to handle adding to beginning and end of sequence
        if (time > this.duration) {
            "time is greater than duration".error;
        } {
            var nextIndex = this.events.nextSlotFor(time);
            var prevIndex = nextIndex-1;
            var prevTime = this.events.indices[prevIndex];
            var prevEvent = this.events.array[prevIndex];
            var nextTime = this.events.indices[nextIndex];
            var dur = nextTime - time;
            prevEvent[\dur] = time - prevTime;
            event[\dur] = dur;
            this.events.put(time, event);
        }
    }

    remove {|time|
        var nextIndex = events.nextSlotFor(time);
        var prevIndex = nextIndex-2;
        var prevTime = events.indices[prevIndex];
        var prevEvent = events.array[prevIndex];
        var nextTime = events.indices[nextIndex];
        var dur = nextTime - prevTime;
        prevEvent[\dur] = dur;
        events.removeAt(time);
    }

    copy {
        var eventsCopy = this.events.collect({|evt| evt.copy});
        var seq = E();
        seq.events = eventsCopy;
        seq.duration = this.duration;
        ^seq;
    }

    perform {|selector ...args|
        var pseq, order;
        var array = this.events.array.perform(selector, *args);
        pseq = Pseq(array, inf);
        order = E.order(pseq, this.duration);
        this.events = order;
    }

    set {|pattern, duration|
        this.events = E.order(pattern, duration);
        this.duration = duration;
    }

    asArray {
        ^events.array;
    }

    asStream {|repeats=inf|

        ^Prout({|inevent|
            repeats.do({|i|
                var evts = this.asArray.collect({|evt| evt.copy});
                var seq = Pseq(evts, 1).asStream;
                var next = seq.next(inevent);
                while ({ next.isNil.not}, {
                    next.yield;
                    next = seq.next(inevent)
                })
            });
        })
    }
}