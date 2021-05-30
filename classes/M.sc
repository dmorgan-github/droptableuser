/*
Matrix
*/
M : D {

    var <map;

    var <slot;

    var <outbus;

    deviceInit {
        map = Order.new;
        slot = 0;
        outbus = Bus.audio(Server.default, 2);
    }

    postInit {
        this.put(0, { InFeedback.ar(outbus.index, 2) });
    }

    view {
        ^U(\matrix, this)
    }

    addSrc {|srcNode|

        var srcIndex = map.detectIndex({|v|
            v.key == srcNode.key
        });
        if (srcIndex.isNil) {
            srcIndex = slot;
            //srcNode.parentGroup = this.group;
            srcNode.monitor.out = outbus.index;
            map.put(srcIndex, srcNode);
            slot = slot + 1;
            this.changed(\add, srcNode);
        };
    }

    removeSrc {|key|

        map.keysValuesDo({|k, v|
            if (v.key == key) {
                map.do({|obj|
                    if (obj.respondsTo(\removeAt)){
                        obj.removeAt(k);
                    };
                    if (obj.respondsTo(\nodeMap)) {
                        obj.nodeMap.removeAt(key);
                    }
                });
                v.clear;
                map.removeAt(k);
                this.changed(\remove, key);
            }
        });
    }


    /*

(
var indent = {|num|
    num.do({"\t".post;});
};

var func = {|matrix, index, key, depth=1|
     matrix.map.do({|j, k|
        if (j[index].notNil) {
            var vol = j.get(key);
            if (vol > 0) {
                indent.(depth);
                "%".format(j.key).postln;
                func.(matrix, k, j.key, depth+1);
            }
        }
    });
};

var printTree = {|matrix|
    var keys;
    var root = matrix.map[0];
    keys = matrix.map.array.collect({|obj| obj.key});
    root.key.postln;
    keys[1..].do({|key, i|
        var index = i+1;
        var vol = matrix.map[index].get(root.key);
        if (vol.notNil and: {vol > 0}) {
            indent.(1);
            key.postln;
            func.(matrix, index, key, 2);
        }
    });
};

D.all.keysValuesDo({|k,v|
    if (v.isKindOf(M)) {
        printTree.(v);
    };
});
nil;
)
    */
}
