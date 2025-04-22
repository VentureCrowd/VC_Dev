// inputValidation.js
const DEFAULT_FILE_SIZE_LIMIT = 3 * 1024 * 1024; // 3MB in bytes

// Function to handle validation based on the input type
const validateInput = (type, value, limit, fileType) => {
    // Handle length limit if applicable
    if (limit && value.length > limit) {
        return `The input exceeds the maximum limit of ${limit} characters.`;
    }

    switch (type) {
        case 'email':
            return validateEmail(value);
        case 'number':
            return validateNumber(value);
        case 'tel':
            return validateTel(value);
        case 'url':
            return validateUrl(value);
        case 'password':
            return validatePassword(value);
        case 'file':
            return validateFile(value, limit, fileType);  // New case for file validation
        case 'files':
            return validateFiles(value, limit);
        case 'date':
            return validateDate(value);
        case 'currency':
            return validateCurrency(value);
        case 'checkbox':
            return validateCheckbox(value);
        case 'radio':
            return validateRadio(value);
        case 'text':
        default:
            return validateText(value);
    }
}

const validateRadio = (value) =>{
    return '';
}

// Validation rules for each type
const validateEmail = (value) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(value)) {
        return 'Please enter a valid email address.';
    }
    return '';
}

const validateNumber = (value) => {
    if (!value.match(/^-?\d*(\.\d+)?$/)) {
        return 'Please enter a valid number.';
    }
    return '';
}

const validateTel = (value) => {
    const telRegex = /^(\+?\d{10,15}|\d{9})$/; // Allows + followed by 10-15 digits or exactly 9 digits

    if (!telRegex.test(value)) {
        return 'Please enter a valid telephone number.';
    }
    return '';
}

const validateUrl = (value) => {
    const urlRegex = /[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)/;
    if (!urlRegex.test(value)) {
        return 'Please enter a valid URL.';
    }
    return '';
}

const validatePassword = (value) => {
    if (value.length < 8) {
        return 'Password must be at least 8 characters long.';
    }
    return '';
}

const validateText = (value) => {
    // if (value.trim().length === 0) {
    //     return 'This field cannot be empty.';
    // }
    return '';
}

// Validation for file input
const validateFile = (file, limit = DEFAULT_FILE_SIZE_LIMIT, fileType) => {
    if (!file) {
        return 'Please select a file.';
    }

    // Validate file size if limit is defined (assuming limit is in bytes)
    if (file.size > limit) {
        return `The file ${file.name}, exceeds the maximum limit of ${limit / (1024 * 1024)} MB.`;
    }

    if(fileType==='image'){
        if(file.type != 'image/png' && file.type != 'image/jpeg' && file.type != 'image/webp' ){
            return `The file ${file.name}, must be a PNG, JPEG or WEBP`;
        }
    }else if(fileType==='document'){
        if(file.type != 'application/pdf'){
            return `The file ${file.name}, must be a PDF`;
        }
    }
   

    return '';
}

const validateFiles = (files, limit = DEFAULT_FILE_SIZE_LIMIT) => {
    if(files.length <= 0){
        return 'Please select a file'
    }

    return '';
}

// Validation for date input
const validateDate = (value) => {
    const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
    if (!dateRegex.test(value)) {
        return 'Please enter a valid date in yyyy-mm-dd format.';
    }

    // Additional validation to check if the date is a valid calendar date
    const parts = value.split('-');
    const year = parseInt(parts[0], 10);
    const month = parseInt(parts[1], 10);
    const day = parseInt(parts[2], 10);
    const date = new Date(year, month - 1, day);

    if (date.getFullYear() !== year || date.getMonth() + 1 !== month || date.getDate() !== day) {
        return 'Please enter a valid calendar date in yyyy-mm-dd format.';
    }

    // Check if the date is in the past
    const today = new Date();
    today.setHours(0, 0, 0, 0); // Set time to midnight to only compare dates
    if (date < today) {
        return 'The date cannot be in the past.';
    }


    return '';
}

// Validation for currency input
const validateCurrency = (value) => {
    const currencyRegex = /^\d+(\.\d{1,2})?$/;
    if (!currencyRegex.test(value)) {
        return 'Please enter a valid currency amount.';
    }
    return '';
}

const validateCheckbox = (values) => {
    if (values.length <= 0) {
        return 'Please select at least one option.';
    }
    return '';
};


export { validateInput };