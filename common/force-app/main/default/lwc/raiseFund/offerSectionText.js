const offerTextMapping = [
    {
        key: 'SAFE Note',
        type: 'Wholesale',
        text: `Investors will be issued units in an unregistered wholesale managed investment scheme, structured as a unit trust, the trustee of which is VentureCrowd Nominees Pty Ltd (ACN 166 599 140). The trust will acquire SAFE notes issued by $companyLegalName.`
    },
    {
        key: 'Interests in a Limited Partnership',
        type: 'Wholesale',
        text: 'The Fund is structured as an Early Stage Venture Capital Limited Partnership (ESVCLP) pending registration with Industry, Innovation & Science Australia. Investors will acquire limited partnership interests in the Fund which will be governed by the Partnership Deed. The Fund will acquire the securities issued by the companies.'
    },
    {
        key: 'Ordinary Shares',
        type: 'Wholesale',
        text: 'Investors will be issued units in an unregistered wholesale managed investment scheme, structured as a unit trust, the trustee of which is VentureCrowd Nominees Pty Ltd (ACN 166 599 140). The trust will acquire the preference shares issued by VentureCrowd Services Australia Pty Ltd.'
    }
]

const getOfferTextMapping = (investmentType, productType, companyLegalName) => {
    const offerText = offerTextMapping.find(offerTextMapping => offerTextMapping.key === investmentType && productType === offerTextMapping.type)
    if(offerText){
        return offerText.text.replace('$companyLegalName', companyLegalName);
    }
    return null
    }   

export {getOfferTextMapping, offerTextMapping};