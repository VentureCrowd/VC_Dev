import { LightningElement, api } from 'lwc';
import GLObal_ASSET from '@salesforce/resourceUrl/VC_CF_GlobalAssets';
import VC_CF_CommonCSS from '@salesforce/resourceUrl/VC_CF_CommonCSS';
import VC_CF_HomeCSS from '@salesforce/resourceUrl/VC_CF_HomeCSS';
import overrideSLDSvfp from '@salesforce/resourceUrl/overrideSLDSvfp';

export default class VcBgImageWithText extends LightningElement {

    @api backgroundimageurl;
    @api titleText;
    @api IntroText;
    @api primaryButtonLabel;
    @api primaryButtonColor;
    @api primaryButtonLink;
    @api primaryButtonSameOrNew;

    isTitleRendered = false;
    isIntroRendered = false;

    anchorTarget = {'Same Tab' : '_self', 'New Tab' : '_blank' };
    colorCombination = { 'Teal' : 'accent-teal', 'Pink' : 'accent-pink', 'Purple':'accent-purple', 'Ghost' : 'accent-ghost', 'Black': 'accent-black' };

    renderedCallback() {
        if(!this.isTitleRendered) {
            this.template.querySelector('.titleTextSec').innerHTML = this.titleText;
            this.isTitleRendered = true;
        }
        if(!this.isIntroRendered) {
            this.template.querySelector('.IntroTextSec').innerHTML = this.IntroText;
            this.isIntroRendered = true;
        }
    }

    get getbackgroundImgStyling() {
        return `background-image:url('${this.backgroundimageurl}')`;
    }

    get primaryButtonHref() {
        return this.primaryButtonLink;
    }

    get primaryButtonStyle(){
        return this.colorCombination[this.primaryButtonColor];
    }
}