import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Error from "@salesforce/label/c.Error";
import Success from "@salesforce/label/c.Success";
import UnknownError from "@salesforce/label/c.UnknownError";
import Warning from "@salesforce/label/c.Warning";


class Toast {
    static labels = {
        error: Error,
        success: Success,
        unknownError: UnknownError,
        warning: Warning
    };

    static variants = {
        error: "error",
        warning: "warning",
        success: "success",
        info: "info"
    };

    static emptyString = ""; // \u200b

    constructor(
        title = "",
        message = "",
        variant = Toast.variants.success)
    {
        this.title = title;
        this.variant = variant;
        this.message = this._getMessage(message);
    }

    _getMessage(message) {
        if (typeof message === 'string') return message
        if (this.variant === Toast.variants.error) {
            let errorMessage;
            if ('body' in message) {
                if (typeof message.body.message === 'string') {
                    errorMessage = message.body.message
                }
            } else if ('message' in message) {
                errorMessage = message.message
            }

            if (!errorMessage) errorMessage = Toast.labels.unknownError
            return errorMessage
        }
    }

    dispatch() {
        dispatchEvent(this.buildToastEvent());
    }

    buildToastEvent() {
        const { title, message, variant } = this;
        return new ShowToastEvent({ title, message, variant });
    }
}

const debounce = (fn, delay = 500) => {
    let timer;
    return function (...args) {
        clearTimeout(timer);
        timer = setTimeout(() => {
            fn(...args);
        }, delay);
    };
};

export {Toast, debounce}