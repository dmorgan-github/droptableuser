I : D {

    deviceInit {
        this.put(0, {
            var l = \left.kr(0);
            var r = \right.kr(1);
            SoundIn.ar([l, r]);
        });
    }


    *stereo0_1 {
        ^I('stereo0_1').set(\left, 0, \right, 1);
    }

    *stereo2_3 {
        ^I('stereo2_3').set(\left, 2, \right, 3);
    }
}