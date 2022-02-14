/*
Matrix
*/
Mtrx : D {

    var <map;

    var <slot;

    var <outbus;

    deviceInit {
        map = Order.new;
        slot = 0;
        //outbus = Bus.audio(Server.default, 2);
    }

    postInit {
        //this.put(0, { InFeedback.ar(outbus.index, 2) });
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
            //srcNode.monitor.out = outbus.index;
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
}
