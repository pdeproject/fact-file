<!--- CUSTOMIZE THIS: This is the seller's Payment Data Transfer authorization token.
 Replace this with the PDT token in "Website Payment Preferences" under your account.---> 
<cfset authToken="Dc7P6f0ZadXW-U1X8oxf8_vUK09EHBMD7_53IiTT-CfTpfzkN0nipFKUPYy">
<cfset txToken = url.tx>
<!--- Change to www.sandbox.paypal.com to test against sandbox --->
<cfset ppHostname = "www.paypal.com">
 
<CFHTTP url="https://#ppHostname#/cgi-bin/webscr" method="POST" resolveurl="no"> 
    <cfhttpparam name="Host" type="header"    value="#ppHostname#">
    <cfhttpparam name="cmd"  type="formField" value="_notify-synch">
    <cfhttpparam name="tx"   type="formField" value="#txToken#">
    <cfhttpparam name="at"   type="formField" value="#authToken#">
</CFHTTP>
 
<cfif left(#cfhttp.FileContent#,7) is "SUCCESS"> 
<cfloop list="#cfhttp.FileContent#" index="curLine" delimiters="#chr(10)#">
    <cfif listGetAt(curLine,1,"=") is "first_name">
        <cfset firstName=listGetAt(curLine,2,"=")>
    </cfif>
    <cfif listGetAt(curLine,1,"=") is "last_name">
        <cfset lastName=listGetAt(curLine,2,"=")>
    </cfif>
    <cfif listGetAt(curLine,1,"=") is "item_name">
        <cfset itemName=listGetAt(curLine,2,"=")>
    </cfif>
    <cfif listGetAt(curLine,1,"=") is "mc_gross">
        <cfset mcGross=listGetAt(curLine,2,"=")>
    </cfif>
    <cfif listGetAt(curLine,1,"=") is "mc_currency">
        <cfset mcCurrency=listGetAt(curLine,2,"=")>
    </cfif>
</cfloop>
 
<cfoutput>
    <p><h3>Your order has been received.</h3></p>
    <b>Details</b><br>
    <li>Name: #firstName# #lastName#</li>
    <li>Description: #itemName#</li>
    <li>Amount: #mcCurrency# #mcGross#</li>
    <hr>
</cfoutput>
 
<cfelse>
    ERROR
</cfif>
