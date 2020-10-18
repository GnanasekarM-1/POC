//Created by Soumyaranjan Pati 
// ServiceMax Inc 2020
import { LightningElement, api } from "lwc";
export default class ProductStock extends LightningElement {
  @api page = 1;
  @api totalrecords;
 
  @api recordId;
  @api pagesize = 10;
  @api stockStatus;
  
  handlePrevious() {
    if (this.page > 1) {
      this.page = this.page - 1;
    }
  }
  handleNext() {
    if (this.page < this.totalPages) {
      this.page = this.page + 1;
    }
  }
  handleFirst() {
    this.page = 1;
  }
  handleLast() {
    this.page = this.totalPages;
  }
  handleRecordsLoad(event) {
    this.totalrecords = event.detail;
    if (this.totalrecords > 0 && this.pagesize > 0) {
      this.totalPages = Math.ceil(this.totalrecords / this.pagesize);
    }else{
      this.totalPages = 0;
    }
    
  }
  handlePageChange(event) {
    this.page = event.detail;
  }
}