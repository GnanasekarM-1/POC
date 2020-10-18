import { LightningElement, wire, api, track } from 'lwc';
import historyDetails from '@salesforce/apex/PIQ_TechAttributeHistory.getHistory';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'


// Adding Custom Labels
import l_PageTitle from '@salesforce/label/c.PRODIQ001_TAG222';
import l_Range from '@salesforce/label/c.PRODIQ001_TAG223';
import l_FromDate from '@salesforce/label/c.PRODIQ001_TAG225';
import l_ToDate from '@salesforce/label/c.PRODIQ001_TAG226';
import l_NoRecords from '@salesforce/label/c.PRODIQ001_TAG227';
import l_Export from '@salesforce/label/c.PRODIQ001_TAG224';
import l_startEndDateError from '@salesforce/label/c.PRODIQ001_TAG228';

export default class PiqTechAttributeHistory extends LightningElement {
@wire(historyDetails, { recordId: '$recordId', startDate: '$selectedStart', endDate: '$selectedEnd'}) history;

label = {
    l_PageTitle,
    l_Range,
    l_FromDate, 
    l_ToDate,
    l_NoRecords,
    l_Export,
    l_startEndDateError
};

@track filteredData = [];
@track columnsAttributes = [];
@track installedBase = '';
@track selectedStart = '';
@track selectedEnd = '';
@track fileProp = '';
@track loading = true;
@track isDataExist = false;

@api recordId;

_filter = [];


@api
get columns() {
    let clos = [];
    this.columnsAttributes = [];
    if(this.history.data != null){
        this.columnsAttributes = this.history.data.attributes;
        for (let key in this.columnsAttributes) {
            clos.push({label: this.columnsAttributes[key], fieldName: key});
        }
    }
    return clos;
}

@api
get tableData(){
    let response = [];
    if(this.history != null && this.history.data != null){
        if(this.history.data.success){
            this.fileProp = this.history.data.objInstalledBase.Name;
            let lstAttributes = this.history.data.lstTechAttributes;
            this.isDataExist = true;
            for (let key in lstAttributes) {
                let eachRow = {capturedOn: lstAttributes[key].capturedOn};
                for (let key2 in lstAttributes[key].attributes) {
                    let attribute = lstAttributes[key].attributes[key2];
                    eachRow[attribute.key] = attribute.value;
                } 
                response.push(eachRow);
            }
            this.filteredData = response;
        } 

    }
    this.loading = false;
    return response;
}

@api 
get installedBaseName(){ //#new coded to populate IB Name as per the BAC-5560
let installedBaseName = '';
if(this.history != null && this.history.data != null && this.history.data.success !=null 
        && this.history.data.objInstalledBase != null){
        installedBaseName = this.history.data.objInstalledBase.Name;

}
return installedBaseName;
}


// On date change fire this action to recreate table
onDateChange(event) {
    if(event.target.name === 'startdatepicker'){
        let newStartDate = event.target.value;
        if(this.selectedEnd && this.selectedEnd < newStartDate){
            alert(l_startEndDateError);
            return;
        }
        if(newStartDate != this.selectedStart){
            this.loading = true;
            this.selectedStart = event.target.value;
        }
    }
    else if(event.target.name === 'enddatepicker'){
        let newEndDate = event.target.value;
        if( this.selectedStart && newEndDate <  this.selectedStart){
            alert(l_startEndDateError);
            return;
        }
        if(newEndDate != this.selectedEnd){
            this.loading = true;
            this.selectedEnd = event.target.value;
        }
    }
}


// Action to download CSV for the available data
downloadCSV(){
    // Populate object for filtered data
    let lstFilteredDate = [];
   /* for (let key in this.filteredData) { // #need to ask bala for this code, as of now commented it
        lstFilteredDate.push(lstFilteredDate[key]);
    }*/
    this.exportCSVFile(this.columnsAttributes, this.filteredData); 
}

// Convert the JSON object to CSV
convertToCSV(objArray) {
    var array = typeof objArray != 'object' ? JSON.parse(objArray) : objArray;
    var str = '';
    for (let i = 0; i < array.length; i++) {
        let line = '';
        for (let index in array[i]) {
            if (line !== '') line += ',';
            let colVal = array[i][index];
            if(colVal.indexOf(","))  colVal = '"' + colVal + '"';
            line += colVal;
        }
        str += line + '\r\n';
    }
    return str;
}

// Gets the JSON and pass it to CSV convertor and create file and deliver the generated content as CSV
exportCSVFile(headers, items) {
    if (headers && !items.includes(headers)) { // fix for BAC-5563 issue# 2, included  !items.includes(headers)
        items.unshift(headers);
    }

    // Convert Object to JSON
    let jsonObject = JSON.stringify(items);
    let csv = this.convertToCSV(jsonObject);
    let exportedFilenmae = this.fileProp + '_' + new Date().toJSON().slice(0,26) + '.csv'; // added underscore(_) in name as per the BAC-5560
    let blob = new Blob([csv]);
    if (navigator.msSaveBlob) { // IE 10+
        navigator.msSaveBlob(blob, exportedFilenmae);
    } else {
        
        let link = document.createElement("a");
        if (link.download !== undefined) { // feature detection
            // Browsers that support HTML5 download attribute
            let url = URL.createObjectURL(blob);
            link.setAttribute("href", url);
            link.setAttribute("target", '_top');
            link.setAttribute("download", exportedFilenmae);
            link.style.visibility = 'hidden';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }
    }
}


}