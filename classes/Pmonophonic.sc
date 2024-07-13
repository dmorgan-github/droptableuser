
// https://gist.github.com/scztt/eef6f74c01d4fb670fd6b02da920ff03
Pmonophonic : Pattern {
    embedInStream {
        |inEvent|
        var id, offEvent;
        var event = inEvent.copy;
        var cleanup = EventStreamCleanup();
        
        cleanup.addFunction(event, {
            offEvent.play;
        });
        
        event.putAll((
            gate: 1,
            sendGate: false,
            callback: event[\callback].addFunc({
                id = ~id;
                offEvent = (
                    type:               \off,
                    id:                 ~id, 
                    server:             ~server, 
                    hasGate:            ~hasGate,
                    schedBundleArray:   ~schedBundleArray,
                    schedBundle:        ~schedBundle
                );
            })
        ));
        
        inEvent = event.yield;
        
        while {inEvent.notNil} {
            event = inEvent.copy;
            cleanup.update(event);
            
            event.putAll((
                id:     id,
                gate:   1,
                type:   \set,
                args:   event[\args] ?? {[]} // get args from synthdef
            ));
            
            inEvent = event.yield;
        };
        
        ^cleanup.exit(inEvent);
    }
}

+Pbind {
    *mono { 
        |...pairs|
        ^Pmonophonic() <> Pbind(*pairs)
    }
    
    mono {
        |...pairs|
        ^Pmonophonic() <> Pbind(*pairs)
    }
}
