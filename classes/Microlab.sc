Microlab : MidiCtrl {

    classvar id, <noteChan;

    *new {||
        ^super.new(id, "Arturia MicroLab");
    }


    note {|on, off|
        super.note(on, off, noteChan);
    }

    *initClass {
        noteChan = 3;
        id = ('microlab_' ++ UniqueID.next).asSymbol;
    }
}