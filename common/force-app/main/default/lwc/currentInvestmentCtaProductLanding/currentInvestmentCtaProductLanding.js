import { LightningElement, api } from 'lwc';
import GLObal_ASSET from '@salesforce/resourceUrl/VC_CF_GlobalAssets';
import VC_CF_CommonCSS from '@salesforce/resourceUrl/VC_CF_CommonCSS';
import VC_CF_AboutCSS from '@salesforce/resourceUrl/VC_CF_AboutCSS';
import VC_CF_CommonJS from '@salesforce/resourceUrl/VC_CF_CommonJS';
import VC_CF_PartnersCSS from '@salesforce/resourceUrl/VC_CF_PartnersCSS';
import {loadScript, loadStyle} from 'lightning/platformResourceLoader';


export default class CurrentInvestmentProductLanding extends LightningElement {

    connectedCallback() {
        console.log("In connectedCallback");
        Promise.all([
          loadStyle(this, GLObal_ASSET + '/css/bootstrap_min.css'),
          loadStyle(this, GLObal_ASSET + '/css/font_awesome_min.css'),
          loadStyle(this, GLObal_ASSET + '/css/fonts.css'),
          loadStyle(this,VC_CF_CommonCSS),
          loadStyle(this,VC_CF_PartnersCSS),
        ]).then(() => {
          console.log("style loaded succesfully");
    // initialize the library using a reference to the container element obtained from the DOM
     
        }).catch(error=>{
             console.log("error while loading jszip>>",error);
        });
    }

    @api strContentHeading;
    @api strBodyCopy;
    @api productLogoUrl;
    @api Investment_Tile_1_BGImageURL;
    @api Investment_Tile_1_Headline;
    @api Investment_Tile_1_Body;
    @api Investment_Tile_1_URL;
    @api Investment_Tile_2_BGImageURL;
    @api Investment_Tile_2_Headline;
    @api Investment_Tile_2_Body;
    @api Investment_Tile_2_URL;
    @api openInSameOrNew;
    @api secondaryLinkSameOrNew;
    @api linkSameOrNew;
    // Colours
    @api backgroundColor;
    anchorTarget = { 'Same Tab': '_self', 'New Tab': '_blank' };

    bgColorClass = { 'White': 'bg-white', 'Gray': 'bg-gray', 'Black': 'bg-black' };

    get getComponentStyleClasses() {
        return 'component-container ' + this.bgColorClass[this.backgroundColor];
    }

    get tile_1_Style() {
        return `background-image: url('${this.Investment_Tile_1_BGImageURL}')`;
    }

    get tile_2_Style() {
        return `background-image: url('${this.Investment_Tile_2_BGImageURL}')`;
    }

    get tile_1_url_Style() {
        let pointerEvent;
        if(this.Investment_Tile_1_URL){
            pointerEvent = 'auto';
        }
        else
        {
            pointerEvent = 'none';
        }
        return `pointer-events: ${pointerEvent}`;
    }

    get tile_2_url_Style() {
        let pointerEvent;
        if(this.Investment_Tile_2_URL){
            pointerEvent = 'auto';
        }
        else
        {
            pointerEvent = 'none';
        }
        return `pointer-events: ${pointerEvent}`;
    }
    get opensInSameOrNewTab() {
        return this.anchorTarget[this.openInSameOrNew];
    }
    get secondaryLinkTarget() {
        return this.anchorTarget[this.secondaryLinkSameOrNew];
    }
}