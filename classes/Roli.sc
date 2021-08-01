Roli : MidiCtrl {

    classvar id, instance;

    // bend semitones
    classvar <>bendst;

    var <bendMap;

    *new {
        if (instance.isNil) {
            instance = super.new(id, ccChan:2, noteChan:2).roliInit
        };
        ^instance;
    }

    roliInit {
        bendMap = Ndef((this.key ++ '_bend').asSymbol, {\val.kr(0).lag(0.5) });
        this.bend({|val|
            var bend = val.linlin(0, 16383, bendst.neg, bendst);
            bendMap.set(\val, bend);
        });
    }

    note {|on, off|
        var bendoff = {|note, chan|
            off.(note, chan);
            bendMap.set(\val, 0);
        };
        super.note(on, bendoff);
    }


    *initClass {
        id = ('roli').asSymbol;
        bendst = 12;
    }
}
