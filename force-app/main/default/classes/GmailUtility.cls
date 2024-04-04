public with sharing class GmailUtility {
    public static void gmailAttchmentBody(string b64data) {
    string body = 'Content-Type: multipart/mixed; boundary=foo_bar_baz MIME-Version: 1.0
    to: dev@adisols.com
    from: webmaster@adisols.com
    subject: POSTMAN Rest API Execution
    
    --foo_bar_baz
    this is mail with an attachment
    
    --foo_bar_baz
    Content-Type: application/png
    MIME-Version: 1.0
    Content-Transfer-Encoding: base64
    Content-Disposition: attachment; filename="Attachment_file.png"';
    }
}