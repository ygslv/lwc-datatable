import { LightningElement, api } from "lwc";

export default class Illustration extends LightningElement {
  @api size = "small";
  @api illustration;
  @api
  set message(value) {
    if (typeof value === "object") {
      this._message = value;
    } else {
      this._message = { header: value, paragraph: "" };
    }
  }
  get message() {
    return this._message;
  }

  get illustrationClasses() {
    const classes = [];
    classes.push("slds-illustration");
    classes.push(`slds-illustration_${this.size}`);
    return classes.join(" ");
  }
}
