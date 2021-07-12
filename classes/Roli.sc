Roli : MidiCtrl {

    classvar id;

    // bend semitones
    classvar <>bendst;

    classvar instance;

    var <>ccChan, <>noteChan;

    var <bendMap;


    *new {
        if (instance.isNil) {
            instance = super.new(id, "Lightpad BLOCK");
        }
        ^instance;
    }

    *doesNotUnderstand {|selector ...args|
        var res = this.new();
        ^res.perform(selector, *args);
    }

    init {|inKey, inSrcKey|
        super.init(inKey, inSrcKey);
        bendMap = Ndef((inKey ++ '_bend').asSymbol, {\val.kr(0).lag(0.5) });
        this.ccChan = 2;
        this.noteChan = 2;
        this.bend({|val|
            var bend = val.linlin(0, 16383, bendst.neg, bendst);
            bendMap.set(\val, bend);
        }, this.ccChan);
    }

    note {|on, off|
        var bendoff = {|note, chan|
            off.(note, chan);
            bendMap.set(\val, 0);
        };
        super.note(on, bendoff, noteChan);
    }


    *initClass {
        id = ('roli_' ++ UniqueID.next).asSymbol;
        bendst = 12;
    }
}
