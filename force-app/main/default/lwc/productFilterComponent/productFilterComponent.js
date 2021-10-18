/* eslint-disable @lwc/lwc/no-document-query */
/* eslint-disable no-alert */
/* eslint-disable radix */
/* eslint-disable no-unused-vars */
/* eslint-disable vars-on-top */
/* eslint-disable guard-for-in */
/* eslint-disable no-console */
/* eslint-disable no-undef */
import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import fetchProductRecords from "@salesforce/apex/BlubProductShopping.fetchProductRecords";

export default class ProductFilterComponent extends LightningElement {
  @track attributeValueMap;
  @track proIdWithValuesMap;
  @track valueHoldList = [];
  @track selectedFilterProductId;
  @api recordId;

  connectedCallback() {
    fetchProductRecords({ parentId: this.recordId })
      .then(result => {
        var attributeValueMap = result.attributeValueMap;
        var proIdWithValuesMap = result.proIdWithValuesMap;
        if (proIdWithValuesMap && attributeValueMap) {
          var tempProIdWithValues = [];
          for (let key in proIdWithValuesMap) {
            tempProIdWithValues.push({
              key: key,
              values: proIdWithValuesMap[key]
            });
          }
          this.proIdWithValuesMap = tempProIdWithValues;
          var tempAttributeMap = [];
          var i = 1;
          for (var key in attributeValueMap) {
            var valueList = [];
            for (var index in attributeValueMap[key]) {
              if (i === 1) {
                valueList.push({
                  data: attributeValueMap[key][index],
                  isVisible: false
                });
              } else {
                valueList.push({
                  data: attributeValueMap[key][index],
                  isVisible: true
                });
              }
            }
            i++;
            tempAttributeMap.push({ mapKey: key, values: valueList });
          }

          this.attributeValueMap = tempAttributeMap;
          this.error = undefined;
        } else {
          console.log("Blank==", this.attributeValueMap);
        }
      })
      .catch(error => {
        let errorMessage;
        if (error) {
          if (Array.isArray(error.body)) {
            errorMessage = error.body.map(e => e.message).join(", ");
          } else if (typeof error.body.message === "string") {
            errorMessage = error.body.message;
          }
        }
        if (errorMessage) {
          this.customShowToast("Error", errorMessage, "error", "pester");
        }
      });
  }
  handleClick(event) {
    let selectedVal;
    if (event && event.target && event.target.variant) {
      event.target.variant = "brand";
      selectedVal = event.target.label;
    }

    let valueHoldList = this.valueHoldList;
    if (selectedVal) {
      valueHoldList.push(selectedVal);
    }

    let proIdWithValuesMap = this.proIdWithValuesMap;
    let index = parseInt(event.target.title);
    var valueList = this.attributeValueMap;
    var sameValueList = valueList[index].values;

    if (proIdWithValuesMap && valueList && sameValueList.length > 0) {
      if (this.attributeValueMap.length > index + 1) {
        valueList = valueList[index + 1].values;
        for (let valIndex in valueList) {
          for (let proIdIndex in proIdWithValuesMap) {
            if (
              proIdWithValuesMap[proIdIndex].values.includes(
                valueList[valIndex].data
              ) &&
              proIdWithValuesMap[proIdIndex].values.some(r =>
                valueHoldList.includes(r)
              )
            ) {
              valueList[valIndex].isVisible = false;
            }
          }
        }
      }

      for (let sameValIndex in sameValueList) {
        sameValueList[sameValIndex].isVisible = true;
      }

      if (valueHoldList.length === valueList.length) {
        for (let proIdIndex in proIdWithValuesMap) {
          if (
            proIdWithValuesMap[proIdIndex].values.sort().toString() ===
            this.valueHoldList.sort().toString()
          ) {
            this.selectedFilterProductId =
            proIdWithValuesMap[proIdIndex].key;
          }
        }
      }
    }
  }

  handleReset() {
    this.valueHoldList = [];
    this.selectedFilterProductId = "";
    let attributeValueMap = this.attributeValueMap;
    if (attributeValueMap) {
      for (let attIdIndex in attributeValueMap) {
        for (let valIdIndex in attributeValueMap[attIdIndex].values) {
          if (parseInt(attIdIndex) === 0) {
            attributeValueMap[attIdIndex].values[valIdIndex].isVisible = false;
          } else {
            attributeValueMap[attIdIndex].values[valIdIndex].isVisible = true;
          }
        }
      }
    }
    let optionButtonVarient = this.template.querySelectorAll(".option-button");

    if (optionButtonVarient) {
      optionButtonVarient.forEach(function(element) {
        element.variant = "neutral";
      }, this);
    }
  }

  customShowToast(title, message, variant, mode) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
      mode: mode
    });
    this.dispatchEvent(evt);
  }
}