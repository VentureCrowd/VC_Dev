<aura:application extends="force:slds" access="GLOBAL">
    <aura:handler value="{!this}" name="init" action="{!c.init}"/>

    <!-- <aura:dependency resource="c:productDetails" /> -->
    <c:productDetailsLightning/>
</aura:application>