//Created by Soumyaranjan Pati 
// ServiceMax Inc 2020
import { LightningElement, track, api, wire } from "lwc";
import getProductsList from "@salesforce/apex/COMM_ProductStockUtils.getProductsList";
import getProductsCount from "@salesforce/apex/COMM_ProductStockUtils.getProductsCount";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import l_TotalPage from '@salesforce/label/c.INVT001_TAG075';
import l_Page from '@salesforce/label/c.INVT001_TAG076';
import l_message1 from '@salesforce/label/c.INVT001_TAG081';
import l_message2 from '@salesforce/label/c.INVT001_TAG082';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PRODUCT_STOCK_OBJECT from '@salesforce/schema/Product_Stock__c';
const COLS = [
  {
    label: "Product Name",
    fieldName: "productRecordURL",
    type: "text",
    sortable: true,
    type: "url",
    typeAttributes: { label: { fieldName: 'ProductName' }, target: '_blank' }
  },
  {
    label: "Status",
    fieldName: "ProductStatus",
    type: "text"
  },
  {
    label: "Available Qty",
    fieldName: "AvailableQty",
    type: "number",
    cellAttributes: { alignment: 'left' },
    sortable: true
  },
  {
    label: "Qty",
    fieldName: "ProductQty",
    type: "number",
    cellAttributes: { alignment: 'left' },
    sortable: true
  },
  {
    label: "Stock Number",
    fieldName: "ProductStockURL",
    type: "url",
    typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
  }
];

export default class ProductList extends LightningElement {
  label = {
    l_TotalPage,
    l_Page,
    l_message1,
    l_message2
  };
  //@track columns = COLS;
  get columns() {
    let clos = [];
    for (let key in COLS) {
      let internalVal = COLS[key].label;
      switch (internalVal) {
        case "Product Name": {
          internalVal = this.productStockLabels.fields.SVMXC__Product__c.label;
        }
          break;
        case "Status": {
          internalVal = this.productStockLabels.fields.SVMXC__Status__c.label;
        }
          break;
        case "Available Qty": {
          internalVal = this.productStockLabels.fields.SVMXC__Available_Qty__c.label;
        }
          break;
        case "Qty": {
          internalVal = this.productStockLabels.fields.SVMXC__Quantity2__c.label;
        }
          break;
        case "Stock Number": {
          internalVal = "Stock Number";
        }
          break;
      }
      COLS[key].label = internalVal;
      clos.push(COLS[key]);
    }
    return clos;
  }
  @track toggleCheckBox;
  @track productvar;
  @track error;
  @track searchProduct;
  @track searchQty;
  @track searchAvlQty;
  @track searchReqQty;
  @track searchReordQty;
  @track searchStockName;
  @track sortBy = "Id";
  @track sortDirection = "asc";
  @track defaultSortDirection = "asc";
  @track productvalue;
  @track qtyvalue;
  @track availblevalue;
  @track requiredvalue;
  @track reordervalue;
  @track stocknumbervalue;
  @track areDetailsVisible = false;
  productStockObjectlLabel;
  //@track draftValues;

  @api currentpage;
  @api pagesize;
  @api recordid; //Current Object Id
  @api stockstatus;//Get from parents
  @api productStockLabels;

  enableSpinner = true;
  totalpages;
  localCurrentPage = null;
  isSearchChangeExecuted = false;
  comboBoxEventName = "";
  comboBoxEventValue;
  constructSearchValue = "";
  productQtyLabel = "";

  comboBoxEventValueProduct;
  comboBoxEventValueQty;
  comboBoxEventValueAvlQty;
  comboBoxEventValueStock;

  constructProductSearchValue = "";
  constructQtySearchValue = "";
  constructAvlQtySearchValue = "";
  constructStockSearchValue = "";

  @wire(getObjectInfo, { objectApiName: PRODUCT_STOCK_OBJECT })
  wiredCustomObjectInfo({ error, data }) {
    if (data) {
      this.productStockLabels = data;
      this.productStockObjectlLabel = data.label;
    } else if (error) {
      console.log("Getting error during Product Stock Object describe " + error);
    }
  }

  get optionsforString() {
    return [
      { label: "Equals", value: "Equals" },
      { label: "Not Equals", value: "Not Equals" },
      { label: "Starts with", value: "Starts with" },
      { label: "Ends with", value: "Ends with" },
      { label: "Contains", value: "Contains" },
      { label: "Not Contains", value: "Not Contains" }
    ];
  }
  get optionsforNumber() {
    return [
      { label: "Equals", value: "Equals" },
      { label: "Greater than", value: "Greater than" },
      { label: "Less than", value: "Less than" }
    ];
  }

  handleToggleButtonChange() {
    if (this.areDetailsVisible) {
      this.areDetailsVisible = false;
    } else {
      this.areDetailsVisible = true;
    }
  }

  handleProductComboboxChange(event) {
    this.comboBoxEventName = "Product";
    this.comboBoxEventValue = event.detail.value;
    this.comboBoxEventValueProduct = event.detail.value;
  }
  handleQtyComboboxChange(event) {
    this.comboBoxEventName = "Qty";
    this.comboBoxEventValue = event.detail.value;
    this.comboBoxEventValueQty = event.detail.value;
  }
  handleAvlQtyComboboxChange(event) {
    this.comboBoxEventName = "AvlQty";
    this.comboBoxEventValue = event.detail.value;
    this.comboBoxEventValueAvlQty = event.detail.value;
  }

  handleStockNumComboboxChange(event) {
    this.comboBoxEventName = "Stock";
    this.comboBoxEventValue = event.detail.value;
    this.comboBoxEventValueStock = event.detail.value;
  }
  //End all the combobox request
  resetComboBoxValues() {
    this.template.querySelectorAll('lightning-combobox').forEach(each => {
      console.log('resetComboBoxValues ' + each.value);
      each.value = null;
    });
  }
  resetComboBoxInputValues() {
    this.template.querySelectorAll('lightning-input').forEach(each => {
      console.log('resetComboBoxValues ' + each.value);
      each.value = null;
    });
  }
  resetSearchValue() {
    this.constructProductSearchValue = "";
    this.constructQtySearchValue = "";
    this.constructAvlQtySearchValue = "";
    this.constructStockSearchValue = "";
    this.constructSearchValue = "";
    this.comboBoxEventValueProduct = "";
    this.comboBoxEventValueQty = "";
    this.comboBoxEventValueAvlQty = "";
    this.comboBoxEventValueStock = "";
  }
  handleReset() {
    this.resetComboBoxValues();
    this.resetComboBoxInputValues();
    this.resetSearchValue();
    this.searchProduct = "";
    this.searchQty = "";
    this.searchAvlQty = "";
    this.searchReqQty = "";
    this.searchReordQty = "";
    this.searchStockName = "";

    this.isSearchChangeExecuted = false;
    this.renderedCallback();
  }
  handleKeyChange(event) {
    console.log("handleKeyChange " + event.target.value);
    if (event.target.name == "productname") {
      this.searchProduct = event.target.value;
      this.comboBoxEventName = "Product";
      if (!this.stringValueisEmpty(this.comboBoxEventValueProduct)) {
        this.comboBoxEventValue = this.comboBoxEventValueProduct;
      }
    } else if (event.target.name == "avlqtyname") {
      this.searchAvlQty = event.target.value;
      this.comboBoxEventName = "AvlQty";
      if (!this.stringValueisEmpty(this.comboBoxEventValueAvlQty)) {
        this.comboBoxEventValue = this.comboBoxEventValueAvlQty;
      }
    } else if (event.target.name == "qtyname") {
      this.searchQty = event.target.value;
      this.comboBoxEventName = "Qty";
      if (!this.stringValueisEmpty(this.comboBoxEventValueQty)) {
        this.comboBoxEventValue = this.comboBoxEventValueQty;
      }
    } else if (event.target.name == "stockname") {
      this.searchStockName = event.target.value;
      this.comboBoxEventName = "Stock";
      if (!this.stringValueisEmpty(this.comboBoxEventValueStock)) {
      this.comboBoxEventValue = this.comboBoxEventValueStock;
      }
    }
    this.isSearchChangeExecuted = false;
    this.currentpage = 1;
    if (event.target.value != null && event.target.value != "") {
      this.constructDynamicSearchstring();
    }
  }


  //Handle all the combobox request
  constructDynamicSearchstring() {
    switch (this.comboBoxEventName) {
      case "Product":
        {
          if (this.comboBoxEventValue == "Equals") {
            this.constructProductSearchValue = "SVMXC__Product__r.name = '" + this.searchProduct + "'";
          } else if (this.comboBoxEventValue == "Not Equals") {
            this.constructProductSearchValue = "SVMXC__Product__r.name != '" + this.searchProduct + "'";
          } else if (this.comboBoxEventValue == "Starts with") {
            this.constructProductSearchValue = "SVMXC__Product__r.name like '" + this.searchProduct + "%'";
          } else if (this.comboBoxEventValue == "Ends with") {
            this.constructProductSearchValue = "SVMXC__Product__r.name like '%" + this.searchProduct + "'";
          } else if (this.comboBoxEventValue == "Contains") {
            this.constructProductSearchValue = "SVMXC__Product__r.name like '%" + this.searchProduct + "%'";
          } else if (this.comboBoxEventValue == "Not Contains") {
            this.constructProductSearchValue = "(not SVMXC__Product__r.name like '%" + this.searchProduct + "%')";

          }
        }
        break;
      case "Qty":
        {
          if (this.comboBoxEventValue == "Equals") {
            this.constructQtySearchValue = "SVMXC__Quantity2__c = " + this.searchQty;
          } else if (this.comboBoxEventValue == "Greater than") {
            this.constructQtySearchValue = "SVMXC__Quantity2__c > " + this.searchQty;
          } else if (this.comboBoxEventValue == "Less than") {
            this.constructQtySearchValue = "SVMXC__Quantity2__c < " + this.searchQty;

          }
        }
        break;
      case "AvlQty":
        {
          if (this.comboBoxEventValue == "Equals") {
            this.constructAvlQtySearchValue = "SVMXC__Available_Qty__c = " + this.searchAvlQty;
          } else if (this.comboBoxEventValue == "Greater than") {
            this.constructAvlQtySearchValue = "SVMXC__Available_Qty__c > " + this.searchAvlQty;
          } else if (this.comboBoxEventValue == "Less than") {
            this.constructAvlQtySearchValue = "SVMXC__Available_Qty__c < " + this.searchAvlQty;
          }
        }
        break;
      case "Stock": {
        if (this.comboBoxEventValue == "Equals") {
          this.constructStockSearchValue = "name = '" + this.searchStockName + "'";
        } else if (this.comboBoxEventValue == "Not Equals") {
          this.constructStockSearchValue = "name != '" + this.searchStockName + "'";
        } else if (this.comboBoxEventValue == "Starts with") {
          this.constructStockSearchValue = "name like '" + this.searchStockName + "%'";
        } else if (this.comboBoxEventValue == "Ends with") {
          this.constructStockSearchValue = "name like '%" + this.searchStockName + "'";
        } else if (this.comboBoxEventValue == "Contains") {
          this.constructStockSearchValue = "name like '%" + this.searchStockName + "%'";
        } else if (this.comboBoxEventValue == "Not Contains") {
          this.constructStockSearchValue = "(not name like '%" + this.searchStockName + "%')";
        }
      }
    }
  }
  updateColumnSorting(event) {
    let fieldName = event.detail.fieldName;
    let sortDirection = event.detail.sortDirection;
    console.log("updateColumnSorting fieldName " + fieldName + " sortDirection " + sortDirection);
    this.sortBy = fieldName;
    this.sortDirection = sortDirection;
    this.isSearchChangeExecuted = false;
  }
  stringValueisEmpty(inputValue) {
    if (inputValue == null || inputValue == undefined || inputValue.length == 0) {
      return true;
    }
    return false;
  }
  renderedCallback() {
    console.log("constructProductSearchValue "+this.constructProductSearchValue +" constructQtySearchValue "+this.constructQtySearchValue +" constructAvlQtySearchValue "+this.constructAvlQtySearchValue +" constructStockSearchValue "+this.constructStockSearchValue);
    // This line added to avoid duplicate/multiple executions of this code.
    if (this.isSearchChangeExecuted && this.localCurrentPage === this.currentpage) {
      return;
    }
    //Construct where clause
    
    this.constructSearchValue = this.constructProductSearchValue + " and "+this.constructQtySearchValue +" and "+this.constructAvlQtySearchValue+" and "+this.constructStockSearchValue;
    
    if(this.constructSearchValue.startsWith(" and  and  and ")){
      this.constructSearchValue = this.constructSearchValue.replace(" and  and  and ", "");
    } else if (this.constructSearchValue.startsWith(" and  and ")) {
      this.constructSearchValue = this.constructSearchValue.replace(" and  and ", "");
    } else if (this.constructSearchValue.startsWith(" and ")) {
      this.constructSearchValue = " SVMX "+this.constructSearchValue;
      this.constructSearchValue = this.constructSearchValue.replace(" SVMX  and ", "");
    } else if (this.constructSearchValue.startsWith("and ")) {
      this.constructSearchValue = " SVMX "+this.constructSearchValue;
      this.constructSearchValue = this.constructSearchValue.replace(" SVMX and ", "");
    }
    if(this.constructSearchValue.endsWith(" and  and  and ")){
      this.constructSearchValue = this.constructSearchValue.replace(" and  and  and ", "");
    } else if (this.constructSearchValue.endsWith(" and  and ")) {
      this.constructSearchValue = this.constructSearchValue.replace(" and  and ", "");
    } else if (this.constructSearchValue.endsWith(" and ")) {
      this.constructSearchValue = this.constructSearchValue + " SVMX ";
      this.constructSearchValue = this.constructSearchValue.replace(" and  SVMX ", "");
    } else if (this.constructSearchValue.endsWith(" and")) {
      this.constructSearchValue = this.constructSearchValue + " and ";
      this.constructSearchValue = this.constructSearchValue.replace(" and SVMX ", "");
    }
    
    if(this.constructSearchValue.includes(" and  and  and ")){
      this.constructSearchValue = this.constructSearchValue.replace(" and  and  and ", " and ");
    } else if (this.constructSearchValue.includes(" and  and ")) {
      this.constructSearchValue = this.constructSearchValue.replace(" and  and ", " and ");
    }
    console.log("constructSearchValue after "+this.constructSearchValue); 
    //End Construct where clause
    this.isSearchChangeExecuted = true;
    this.localCurrentPage = this.currentpage;
    let soqlProductStockStatus;
    if (this.stringValueisEmpty(this.stockstatus)) {
      soqlProductStockStatus = "SVMXC__Status__c !='' ";
    } else {
      let nameArr = this.stockstatus.split(',');
      let stockStatusVar = "(";
      for (let i = 0; i < nameArr.length; i++) {
        if (i === nameArr.length - 1) {
          stockStatusVar = stockStatusVar + "'" + nameArr[i].trim() + "'";
        } else {
          stockStatusVar = stockStatusVar + "'" + nameArr[i].trim() + "',";
        }
      }
      stockStatusVar = stockStatusVar + ")";
      soqlProductStockStatus = "SVMXC__Status__c IN " + stockStatusVar + " ";
    }

    if (this.constructSearchValue != null && this.constructSearchValue != "") {
      soqlProductStockStatus =
        soqlProductStockStatus + " and " + this.constructSearchValue;
    }
    //getProductsCount({ searchString: this.searchKey, sfdcRecordId: this.recordid })
    getProductsCount({
      searchString: soqlProductStockStatus,
      sfdcRecordId: this.recordid
    })
      .then((recordsCount) => {
        console.log("Connected Apex and got recordsCount " + recordsCount);
        this.totalrecords = recordsCount;
        if (recordsCount !== 0 && !isNaN(recordsCount)) {
          this.totalpages = Math.ceil(recordsCount / this.pagesize);
          if (this.sortBy == "ProductName") {
            this.sortBy = "SVMXC__Product__r.Name";
          } else if (this.sortBy == "ProductQty") {
            this.sortBy = "SVMXC__Quantity2__c";
          } else if (this.sortBy == "AvailableQty") {
            this.sortBy = "SVMXC__Available_Qty__c";
          } else if (this.sortBy == "RequiredQty") {
            this.sortBy = "SVMXC__Required_Quantity2__c";
          } else if (this.sortBy == "ReorderQty") {
            this.sortBy = "SVMXC__Reorder_Quantity2__c";
          }
          getProductsList({
            pagenumber: this.currentpage,
            numberOfRecords: recordsCount,
            pageSize: this.pagesize,
            searchString: soqlProductStockStatus,
            sfdcRecordId: this.recordid,
            sortByfield: this.sortBy,
            sortOrder: this.sortDirection
          })
            .then((productStockList) => {
              this.enableSpinner = false;
              let currentData = [];
              productStockList.forEach((row) => {
                let rowData = {};
                rowData.Id = row.Id;
                rowData.ProductStockURL = '/' + row.Id;
                rowData.Name = row.Name;
                // Account related data
                if (row.SVMXC__Product__c) {
                  rowData.ProductName = row.SVMXC__Product__r.Name;
                  rowData.productRecordURL = '/' + row.SVMXC__Product__c;
                }
                rowData.ProductQty = row.SVMXC__Quantity2__c;
                rowData.AvailableQty = row.SVMXC__Available_Qty__c;
                rowData.RequiredQty = row.SVMXC__Required_Quantity2__c;
                rowData.ReorderQty = row.SVMXC__Reorder_Quantity2__c;
                rowData.ProductStatus = row.SVMXC__Status__c;
                currentData.push(rowData);
              });
              this.productvar = currentData;
              this.error = undefined;
            })
            .catch((error) => {
              const errorevt = new ShowToastEvent({
                title: this.label.l_message1,
                message: error,
                variant: "error",
                mode: "dismissable"
              });
              this.dispatchEvent(errorevt);
              this.productvar = undefined;
            });
        } else {
          const errorevt = new ShowToastEvent({
            title: this.label.l_message2,
            message: "No Records to display",
            variant: "warning",
            mode: "dismissable"
          });
          this.dispatchEvent(errorevt);
          this.enableSpinner = false;
          this.productvar = [];
          this.totalpages = 1;
          this.totalrecords = 0;
        }
        const event = new CustomEvent("recordsload", {
          detail: recordsCount
        });
        this.dispatchEvent(event);
      })
      .catch((error) => {
        const errorevt = new ShowToastEvent({
          title: this.label.l_message1,
          message: error,
          variant: "error",
          mode: "dismissable"
        });
        this.dispatchEvent(errorevt);
        this.totalrecords = undefined;
      });
  }
}