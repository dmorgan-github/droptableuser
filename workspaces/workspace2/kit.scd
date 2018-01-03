~kit = ProxySpace.new;
~kit.quant = 1.0;

~kit_bufs = ();
~kit_bufs[\kik] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/2channel/Korga_Volca_Beats/Korg Volca Beats-Kick 01.aif");
~kit_bufs[\sn] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/2channel/Korga_Volca_Beats/Korg Volca Beats-Snare 12.aif");
~kit_bufs[\ch] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/2channel/Korga_Volca_Beats/Korg Volca Beats-Closed Hat 04.aif");
~kit_bufs[\oh] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/2channel/Korga_Volca_Beats/Korg Volca Beats-Open Hat 06.aif");
~kit_bufs[\lt] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/2channel/Korga_Volca_Beats/Korg Volca Beats-Lo Tom 17.aif");
~kit_bufs[\ht] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/2channel/Korga_Volca_Beats/Korg Volca Beats-Hi Tom 01.aif");


(
~kit[\seq] = {

	var kik_trig = \kik_trig.tr;
	var sn_trig = \sn_trig.tr;
	var ch_trig = \ch_trig.tr;
	var oh_trig = \oh_trig.tr;
	var lt_trig = \lt_trig.tr;
	var ht_trig = \ht_trig.tr;

	[kik_trig * (1-sn_trig),sn_trig,ch_trig];
};
)
~kit[\seq][2] = \set -> Pbind(\kik_trig, 1, \delta, Pxrand([0.5,1,0.25], inf));
~kit[\seq][4] = \set -> Pbind(\sn_trig, 1, \delta, 2);
~kit[\seq][6] = \set -> Pbind(\ch_trig, 1, \delta, Pseq([ 4, [ [1, [1,1,1]], 1,1,1,1,1,1, [2,[1,1,1]] ] ].convertRhythm, inf) );

~kit[\seq].numChannels;

~kit[\kik_trig] = {~kit[\seq].kr[0]};
~kit[\sd_trig] = {~kit[\seq].kr[1]};
~kit[\ch_trig] = {~kit[\seq].kr[2]};

//~kit[\seq][8] = \set -> Pbind(\oh_trig, 1, \delta, 1/3);
//~kit[\seq][10] = \set -> Pbind(\lt_trig, 1, \delta, 1/4);
//~kit[\seq][12] = \set -> Pbind(\ht_trig, 1, \delta, Prand([0.25, 0.5], inf), \isRest, Prand([false, true], inf));
//~kit[\seq].play


//////////////////////
// kik
~kit[\kik] = ~smplr.(buf: ~kit_bufs[\kik]);
~kit[\kik].play;
~kit[\kik].stop
~kit[\kik].set(\trig, ~kit[\kik_trig]);

//////////////////////
// sn
~kit[\sn] = ~smplr.(buf: ~kit_bufs[\sn]);
~kit[\sn].play;
~kit[\sn].stop
~kit[\sn].set(\trig, ~kit[\sd_trig])

/////////////////////
// ch
~kit[\ch] = ~smplr.(buf: ~kit_bufs[\ch]);
~kit[\ch].play;
~kit[\ch].stop;
~kit[\ch].set(\trig, ~kit[\ch_trig])

////////////////////
/// oh
~kit[\oh] = ~smplr.(buf: ~kit_bufs[\oh], chans:2);
~kit[\oh].play;
~kit[\oh].stop
~kit[\oh].set(\trig, ~kit[\oh_trig])

////////////////////
// lt
~kit[\lt] = ~smplr.(buf: ~kit_bufs[\lt], chans:2);
~kit[\lt].play;
~kit[\lt].stop;
~kit[\lt].set(\trig, ~kit[\lt_trig]);

////////////////////
// ht
~kit[\ht] = ~smplr.(buf: ~kit_bufs[\ht], chans:2);
~kit[\ht].play;
~kit[\ht].stop;
~kit[\ht].set(\trig, ~kit[\ht_trig]);

///////////////////
// mix
~kit[\mix].play;
~kit[\mix][0] = ~kit[\kik];
~kit[\mix][1] = ~kit[\sn];
~kit[\mix][2] = ~kit[\ch];
~kit[\mix][3] = nil~kit[\oh] * 0;
~kit[\mix][4] = nil~kit[\lt] * 0;
~kit[\mix][5] = nil~kit[\ht]

~kit[\mix][18] = \filter -> {arg in; JPverb.ar(in)}
~kit[\mix].set(\wet18, 0.2)


