import { LightningElement } from 'lwc';
export class Utility  extends LightningElement {

    static validateUrl(url) {
        if(url && url != undefined) { 
            let urlValidatorRegex = /^(https:\/\/)?(www\.)?[a-zA-Z0-9-]{1,}\..{2,}$/
            let isValidUrl = urlValidatorRegex.test(url);
            this.urlIsValid = isValidUrl;
            return isValidUrl;
        }
        return false;
        
    }

    static isValidSocialMediaUrl(socialMediaUrl, platform) {
        // Regular expressions for each social media platform
        const facebookRegex = /(?:(?:http|https):\/\/)?(?:www.)?facebook.com\/(?:(?:\w)*#!\/)?(?:pages\/)?(?:[?\w\-]*\/)?(?:profile.php\?id=(?=\d.*))?([\w\.-]*)?/;
        const instagramRegex = /(?:(?:http|https):\/\/)?(?:www.)?instagram.com\/(?:(?:\w)*#!\/)?(?:pages\/)?(?:[?\w\-]*\/)?(?:profile.php\?id=(?=\d.*))?([\w\.-]*)?/;
        const youtubeRegex = /(?:(?:http|https):\/\/)?(?:www.)?youtube.com\/(?:(?:\w)*#!\/)?(?:pages\/)?(?:[?\w\-]*\/)?(?:profile.php\?id=(?=\d.*))?([\w\.-]*)?/;
        const linkedinRegex = /(?:(?:http|https):\/\/)?(?:www.)?linkedin.com\/(?:(?:\w)*#!\/)?(?:pages\/)?(?:[?\w\-]*\/)?(?:profile.php\?id=(?=\d.*))?([\w\.-]*)?/;
        const twitterRegex = /(?:(?:http|https):\/\/)?(?:www.)?twitter.com\/(?:(?:\w)*#!\/)?(?:pages\/)?(?:[?\w\-]*\/)?(?:profile.php\?id=(?=\d.*))?([\w\.-]*)?/;
      
        // Check if the URL matches any of the social media platforms
      if(platform == 'Linkedin_link__c' &&  linkedinRegex.test(socialMediaUrl)) { 
        return true;
      } else if(platform == 'Instagram_link__c' && instagramRegex.test(socialMediaUrl)) { 
        return true;
      } else if(platform == 'Youtube_link__c' && youtubeRegex.test(socialMediaUrl)) { 
        return true;
      } else if(platform == 'Facebook_link__c' && facebookRegex.test(socialMediaUrl)) { 
        return true;
      } else if(platform == 'Twitter_X_link__c' && twitterRegex.test(socialMediaUrl)) { 
        return true;
      }
      return false; 
    }

    static validateEmail(email) { 
      if(email && email != undefined) {
        let emailValidatorRegex = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|.(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
        let isValidEmail = emailValidatorRegex.test(email);
        return isValidEmail;
      }
      return false;
    }

    static removeDuplicates(items,dataType) { 
      if(dataType == 'Array') { 
        return items.filter((item, index) => items.indexOf(item) === index); 
      }
      
    } 

    /**
     * Exports data to a CSV file.
     *
     * @param {Object} headers - An object containing the headers for the CSV file.
     * @param {Array} totalData - An array of objects representing the data to be exported.
     * @param {string} [fileTitle] - An optional parameter specifying the title of the exported file.
     *
     * @returns {void}
     *
     * @example
     * const headers = {
     *   id: 'ID',
     *   name: 'Name',
     *   email: 'Email',
     * };
     *
     * const data = [
     *   { id: 1, name: 'John Doe', email: 'john.doe@example.com' },
     *   { id: 2, name: 'Jane Smith', email: 'jane.smith@example.com' },
     * ];
     *
     * Utils.exportCSVFile(headers, data, 'Users');
     */
    static exportCSVFile(headers, totalData, fileTitle) {
      if (!totalData || !totalData.length) {
          return null;
      }

      const jsonObject = JSON.stringify(totalData);
      const result = this.convertToCSV(jsonObject, headers);
      if (result === null) return;

      // Encode CSV content
      const encodedUri = 'data:text/csv;charset=utf-8,' + encodeURIComponent(result);
      const exportedFilename = fileTitle ? `${fileTitle}.csv` : 'export.csv';

      // Create a temporary anchor element
      const link = document.createElement("a");
      link.setAttribute("href", encodedUri);
      link.setAttribute("download", exportedFilename);
      link.style.visibility = "hidden";
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    }
  

  static convertToCSV(objArray, headers){
      const columnDelimiter = ','
      const lineDelimiter = '\r\n'
      const actualHeaderKey = Object.keys(headers)
      const headerToShow = Object.values(headers) 
      let str = ''
      str+=headerToShow.join(columnDelimiter) 
      str+=lineDelimiter
      const data = typeof objArray !=='object' ? JSON.parse(objArray):objArray

      data.forEach(obj=>{
          let line = ''
          actualHeaderKey.forEach(key=>{
              if(line !=''){
                  line+=columnDelimiter
              }
              let strItem = obj[key]+''
              line+=strItem? strItem.replace(/,/g, ''):strItem
          })
          str+=line+lineDelimiter
      })
      return str
  }

  static abnValidation(abnNumber) {
    const weights = [10, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19];
    let abn = abnNumber?.toString().replace(/[^\d]/g, '');
    let result = false;
    // check length is 11 digits
    if (abn?.length === 11) {
        // apply ato check method
        let sum = 0,
            weight,
            digit;
        for (let index = 0; index <= weights.length - 1; index++) {
            weight = weights[index];
            digit = abn[index] - (index ? 0 : 1);
            sum += weight * digit;
        }
        result = sum % 89 === 0;
        return result;
      }
      return result;
  }
}