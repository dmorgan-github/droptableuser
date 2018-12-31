(
l= 1024;	//global window/buffer size in pixels/samples
s.latency= 0.05;
s.waitForBoot{

        //--variables
        var theta= 0;
        var fps= 60;
        var arr= Array.fill(l, 0);
        var cnt= 0;

        //--window setup
        var width= l, height= l;
        var w= Window("waveform", Rect(99, 99, width, height), false);
        var u= UserView(w, Rect(0, 0, width, height));
        var w2= width*0.5;
        var h2= height*0.5;

        //--buffer
        b= Buffer.alloc(s, l, 1);
        s.sync;

        //--interface
        ~trails= 1;
        ~speed= 0;
        ~amp= 0.5;
        ~version= 0;

        //--main loop
        u.drawFunc= {

                //uncomment framerate display in the two lines below to gain some speed
                Pen.color= Color.white;
                Pen.stringAtPoint(""++u.frameRate, Point(10, 10));


                //--
                b.getn(0, b.numFrames-1, {|data| arr= data});

                if(cnt==0, {
                        Pen.fillColor= Color.black;	//erase first time
                        Pen.fillRect(Rect(0, 0, width, height));
                });

                Pen.fillColor= Color.grey(0, ~trails);
                Pen.fillRect(u.bounds);	//manually clear
                Pen.strokeColor= Color.green;

                switch(~version,
                        0, {	//line
                                Pen.rotate(theta, w2, h2);
                                Pen.translate(0, h2);
                                arr.do{|y, x|
                                        var p= Point(x, y*(height*~amp));
                                        if(x==0, {Pen.moveTo(p)}, {Pen.lineTo(p)});
                                };
                                Pen.stroke;
                        },
                        1, {	//warp
                                Pen.rotate(theta, w2, h2);
                                Pen.translate(w2, h2);
                                arr.do{|y, x|
                                        var p= Point(x*~amp, y*~amp).rotate(y*2pi);
                                        if(x==0, {Pen.moveTo(p)}, {Pen.lineTo(p)});
                                };
                                Pen.stroke;
                        },
                        2, {	//flower
                                Pen.translate(w2, h2);
                                Pen.moveTo(Point(arr[0], 0)*arr[0]);
                                arr.do{|y, x|
                                        var p= Point(y, x)*y;
                                        var a= x%width/width*2pi+theta;
                                        Pen.lineTo(p.rotate(a));
                                };
                                Pen.stroke;
                        }
                );
                theta= theta+~speed;
                cnt= cnt+1;


        };

        //--window management
        u.clearOnRefresh= false;	//do not erase - just draw on top of
        w.onClose= {
                b.free;
        };
        w.front;
        CmdPeriod.doOnce({if(w.isClosed.not, {w.close})});
        u.animate= true;
};
)



//some synth that writes into the buffer
v= {RecordBuf.ar(Saw.ar, b)}.play

//change these while the program is running
~trails= 0.2;
~speed= 0.1;
~speed= -0.05;
~trails= 0.01;
~amp= 0.02;
~speed= pi*0.25;
~amp= 0.2;
~version= 1;
~trails= 0.2;
~version= 2;
~version= 1;
~speed= 2pi*1.001;
~amp= 0.5;
v.free;

v= {RecordBuf.ar(SinOsc.ar(0, BPF.ar(VarSaw.ar(MouseX.kr(1, 1000, 1)), MouseY.kr(50, 5000, 1), 0.5)), b)}.play
~version= 1;
~trails= 0.01;
~speed= -0.03;
~speed= -0.05;
~trails= 1;
~amp= 0.5;
~speed= 2pi*0.25;
~trails= 0.1
~amp= 0.2;
~version= 2;
~version= 0;
~speed= 2pi*1.001;
~amp= 10;
~speed= 0;
v.free 