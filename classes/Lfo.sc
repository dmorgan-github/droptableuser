Lfo {

    classvar <order;

    *new {
        ^super.new.init
    }

    put {|index, val|
        var node = order[index];
        if (node.isNil) {
            node = NodeProxy();
            order.put(index, node);
            node.source = val;
        };
    }

    at {|index|
        ^order[index]    
    }

    init {
        ^this
    }

    *initClass {
        order = Order()
    }

}