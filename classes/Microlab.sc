Microlab : MidiCtrl {

    classvar id;

    *new {
        ^super.new(id, ccChan:3, noteChan:3);
    }

    *initClass {
        id = ('microlab').asSymbol;
    }
}