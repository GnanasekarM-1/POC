//Created by Soumyaranjan Pati 
// ServiceMax Inc 2020
import { LightningElement, api } from "lwc";
import l_First from '@salesforce/label/c.INVT001_TAG077';
import l_Previous from '@salesforce/label/c.INVT001_TAG078';
import l_Next from '@salesforce/label/c.INVT001_TAG079';
import l_Last from '@salesforce/label/c.INVT001_TAG080';

export default class PaginationButton extends LightningElement {
  label = {
    l_First,
    l_Previous,
    l_Next,
    l_Last
  };

  // Api considered as a reactive public property.
  @api totalrecords;
  @api currentpage;
  @api pagesize;
  paginationValue;
  // Following are the private properties to a class.
  lastpage = false;
  firstpage = false;
  // getter
  get showFirstButton() {
    if (this.currentpage === 1) {
      return true;
    }
    return false;
  }
  // getter
  get showLastButton() {
    if (Math.ceil(this.totalrecords / this.pagesize) === this.currentpage) {
      return true;
    }
    return false;
  }
  //Fire events based on the button actions
  handlePrevious() {
    this.dispatchEvent(new CustomEvent("previous"));
  }
  handleNext() {
    this.dispatchEvent(new CustomEvent("next"));
  }
  handleFirst() {
    this.dispatchEvent(new CustomEvent("first"));
  }
  handleLast() {
    this.dispatchEvent(new CustomEvent("last"));
  }
}