const investProductTypeMapping = [
    {
        key: 'Preference Shares',
        fields : [
            {
                fieldName: 'Sector',
                value: 'sector',
            },
            {
                fieldName: 'Offer type',
                value: 'investmentType',
            },
            {
                fieldName: 'Investment Type',
                value: 'investmentProductType',
            },
            {
                fieldName: 'Minimum Investment',
                value: 'minInvestAmount',
                format: 'currency',
            },
            {
                fieldName: 'Coupon',
                value: 'coupon',
                format: 'per-annum',
            },
            {
                fieldName: 'Term',
                value: 'term',
                format: 'months'
            },
            {
                fieldName: 'Conversion',
                value: 'conversion',
            },
        ]
    },
    {
        key : 'Convertible Note',
        fields : [
            {
                fieldName: 'Sector',
                value: 'sector',
            },
            {
                fieldName: 'Offer type',
                value: 'investmentType',
            },
            {
                fieldName: 'Investment Type',
                value: 'investmentProductType',
            },
            {
                fieldName: 'Minimum Investment',
                value: 'minInvestAmount',
                format: 'currency',
            },
            {
                fieldName: 'Coupon',
                value: 'coupon',
                format: 'per-annum'
            },
            {
                fieldName: 'Term',
                value: 'term',
                format: 'months'
            },
            {
                fieldName: 'Conversion',
                value: 'conversion',
            },
        ]
    },
    {
        key : 'Promissory Note',
        fields : [
            {
                fieldName: 'Sector',
                value: 'sector',
            },
            {
                fieldName: 'Offer type',
                value: 'investmentType',
            },
            {
                fieldName: 'Investment Type',
                value: 'investmentProductType',
            },
            {
                fieldName: 'Minimum Investment',
                value: 'minInvestAmount',
                format: 'currency',
            },
            {
                fieldName: 'Interest Rate',
                value: 'interestRate',
                format: 'per-annum',
            },
            {
                fieldName: 'Term',
                value: 'term',
                format: 'months'
            },
            {
                fieldName: 'Security',
                value: 'security',
                format: 'percentage',
            },
        ]
    },
    {
        key : 'SAFE Note',
        fields : [
            {
                fieldName: 'Sector',
                value: 'sector',
            },
            {
                fieldName: 'Offer type',
                value: 'investmentType',
            },
            {
                fieldName: 'Investment Type',
                value: 'investmentProductType',
            },
            {
                fieldName: 'Minimum Investment',
                value: 'minInvestAmount',
                format: 'currency',
            },
            {
                fieldName: 'Valuation Cap',
                value: 'valuationCap',
                format: 'currency',
            },
            {
                fieldName: 'Discount Rate',
                value: 'discountRate',
                format: 'percentage',
            },
            {
                fieldName: 'Conversion',
                value: 'conversion',
            },
        ]
    },
    {
        key : 'Ordinary Shares',
        fields : [
            {
                fieldName: 'Sector',
                value: 'sector',
            },
            {
                fieldName: 'Minimum Investment',
                value: 'minInvestAmount',
                format: 'currency',
            },
            {
                fieldName: 'Offer type',
                value: 'investmentType',
            },
            {
                fieldName: 'Investment Type',
                value: 'investmentProductType',
            },
            {
                fieldName: 'Share Price',
                value: 'sharePrice',
                format: 'currency',
            },
        ]
    }
]

export {investProductTypeMapping}