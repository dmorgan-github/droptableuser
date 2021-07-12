Microlab : MidiCtrl {

    classvar id;

    var <>ccChan, <>noteChan;

    *new {|chan=2|
        ^super.new(id, "Arturia MicroLab");
    }

    *initClass {
        id = ('microlab_' ++ UniqueID.next).asSymbol;
    }
}