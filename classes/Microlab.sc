Microlab : MidiCtrl {

    classvar id;

    classvar <>ccChan=3, <>noteChan=3;

    *new {
        ^super.new(id, ccChan:Microlab.ccChan, noteChan:Microlab.noteChan);
    }

    *initClass {
        id = ('microlab').asSymbol;
    }
}
