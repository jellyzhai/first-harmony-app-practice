"use strict";
struct WidgetCard extends   {
    constructor() { }
    build() {
            .height(this.FULL_HEIGHT_PERCENT)
            .onClick(() => {
            postCardAction(this, {
                "action": this.ACTION_TYPE,
                "abilityName": this.ABILITY_NAME,
                "params": {
                    "message": this.MESSAGE
                }
            });
        });
    }
}
//# sourceMappingURL=WidgetCard.js.map