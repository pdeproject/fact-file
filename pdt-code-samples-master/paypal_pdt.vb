// ASP VB.Net
 
Imports System.Collections.Generic
Imports System.Net
Imports System.IO 
 
Partial Public Class vbPDTSample  Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        ' CUSTOMIZE THIS: This is the seller's Payment Data Transfer authorization token.
        ' Replace this with the PDT token in "Website Payment Preferences" under your account.
        Dim authToken As String = "Dc7P6f0ZadXW-U1X8oxf8_vUK09EHBMD7_53IiTT-CfTpfzkN0nipFKUPYy"
        Dim txToken As String = Request.QueryString("tx")
        Dim strRequest As String = "cmd=_notify-synch&tx=" & txToken & "&at=" & authToken

        'Post back to either sandbox or live
        Dim strSandbox As String = "https://www.sandbox.paypal.com/cgi-bin/webscr"
        Dim strLive As String = "https://www.paypal.com/cgi-bin/webscr"
        Dim req As HttpWebRequest = CType(WebRequest.Create(strSandbox), HttpWebRequest)

        'Set values for the request back
        req.Method = "POST"
        req.ContentType = "application/x-www-form-urlencoded"
        req.ContentLength = strRequest.Length

        'for proxy
        'Dim proxy As New WebProxy(New System.Uri("http://url:port#"))
        'req.Proxy = proxy

        'Send the request to PayPal and get the response
        Dim streamOut As StreamWriter = New StreamWriter(req.GetRequestStream(), Encoding.ASCII)
        streamOut.Write(strRequest)
        streamOut.Close()
        Dim streamIn As StreamReader = New StreamReader(req.GetResponse().GetResponseStream())
        Dim strResponse As String = streamIn.ReadToEnd()
        streamIn.Close()

        If Not String.IsNullOrEmpty(strResponse) Then
            Dim results As New Dictionary(Of String, String)
            Dim reader As New StringReader(strResponse)
            Dim line As String = reader.ReadLine()
            If line = "SUCCESS" Then
                While True
                    Dim aLine As String
                    aLine = reader.ReadLine
                    If aLine IsNot Nothing Then
                        Dim strArr() As String
                        strArr = aLine.Split("=")
                        results.Add(strArr(0), strArr(1))
                    Else
                        Exit While
                    End If
                End While
                Response.Write("<p><h3>Your order has been received.</h3></p>")
                Response.Write("<b>Details</b><br>")
                Response.Write("<li>Name: " + results("first_name") & " " & results("last_name") & "</li>")
                Response.Write("<li>Item: " & results("item_name") & "</li>")
                Response.Write("<li>Amount: " & results("payment_gross") & "</li>")
                Response.Write("<hr>")
            ElseIf line = "FAIL" Then
                'log for manual investigation
                Response.Write("Unable to retrive transaction detail")

            End If
        Else
            Response.Write("Unknown Error")


        End If

    End Sub
End Class
