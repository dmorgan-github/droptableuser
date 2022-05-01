import * as Tone from 'tone'

//create a synth and connect it to the main output (your speakers)


export default function test() {
    //play a middle 'C' for the duration of an 8th note
    const synth = new Tone.Synth().toDestination();
    synth.triggerAttackRelease("C4", "8n");
}





