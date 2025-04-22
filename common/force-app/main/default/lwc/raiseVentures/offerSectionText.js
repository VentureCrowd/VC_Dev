const offerTextMapping = [
    {
        key: 'SAFE Note',
        type: 'Wholesale',
        text: `Investors will be issued units in an unregistered wholesale managed investment scheme, structured as a unit trust, the trustee of which is VentureCrowd Nominees Pty Ltd (ACN 166 599 140). The trust will acquire SAFE notes issued by $companyLegalName.`
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