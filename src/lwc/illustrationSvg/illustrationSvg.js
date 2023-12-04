import {LightningElement, api} from 'lwc';

import fishingDealsTmp from "./illustrations/fishingDeals.html";
import goneFishingTmp from "./illustrations/goneFishing.html";
import lakeMountainTmp from "./illustrations/lakeMountain.html";
import noEventsTmp from "./illustrations/noEvents.html";
import noTaskTmp from "./illustrations/noTask.html";
import setupTmp from "./illustrations/setup.html";

export default class IllustrationSvg extends LightningElement {

    @api illustration;

    illustrations = {
        fishingDeals:fishingDealsTmp,
        goneFishing:goneFishingTmp,
        lakeMountain:lakeMountainTmp,
        noEvents:noEventsTmp,
        noTask:noTaskTmp,
        setup:setupTmp,
    }

    render() {
        return this.illustrations[this.illustration]
    }
}