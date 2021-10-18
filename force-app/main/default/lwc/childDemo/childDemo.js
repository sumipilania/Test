import { LightningElement, api } from 'lwc';

export default class ChildDemo extends LightningElement {
    //First Test
    // connectedCallback() {
    //     console.log("child Constructor");
    // }

    // previousHandler() {
    //     console.log("child previousHandler");

    //     this.dispatchEvent(new CustomEvent('previouss'));
    // }

    // nextHandler() {
    //     console.log("child nextHandler");

    //     this.dispatchEvent(new CustomEvent('next'));
    // }

    //Second Test

    @api videoUrl;

    @api
    get isPlaying() {
        const player = this.template.querySelector('video');
        return player !== null && player.paused === false;
    }

    @api
    play() {
        console.log('Child Play');
        const player = this.template.querySelector('video');
        // the player might not be in the DOM just yet
        if (player) {
            player.play();
        }
        return 123;
    }

    @api
    pause(par) {
        console.log('Child Pause');
        console.log('Child par='+par);
        const player = this.template.querySelector('video');
        if (player) {
            // the player might not be in the DOM just yet
            player.pause();
        }
    }

    // private method for computed value
    get videoType() {
        return 'video/' + this.videoUrl.split('.').pop();
    }
}