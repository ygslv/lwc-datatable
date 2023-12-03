import {LightningElement, api} from 'lwc';
import fishingDealsTmp from "./illustrations/fishingDeals.html";
import goneFishingTmp from "./illustrations/goneFishing.html";
import lakeMountainTmp from "./illustrations/lakeMountain.html";
import noEventsTmp from "./illustrations/noEvents.html";
import noTaskTmp from "./illustrations/noTask.html";
import setupTmp from "./illustrations/setup.html";

export default class Illustration extends LightningElement {
    @api size;
    @api illustration;
    render() {
        switch (this.illustration) {
            case "fishingDeals":
                return fishingDealsTmp;
            case "goneFishing":
                return goneFishingTmp;
            case "lakeMountain":
                return lakeMountainTmp;
            case "noEvents":
                return noEventsTmp;
            case "noTask":
                return noTaskTmp;
            case "setup":
                return setupTmp;
            default:
                return null;
        }
    }
}