<#macro emailLayout>
<!DOCTYPE html>
<html lang="${locale.language}" dir="${(ltr)?then('ltr','rtl')}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    .votivo-content a { color: #285e4f; text-decoration: underline; overflow-wrap: anywhere; }
    .votivo-content p { margin: 0 0 20px; }
  </style>
</head>
<body style="margin:0;padding:0;background-color:#f7f9f8;color:#202b2b;font-family:Arial,Helvetica,sans-serif;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background-color:#f7f9f8;">
    <tr>
      <td align="center" style="padding:40px 16px;">
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:560px;">
          <tr>
            <td style="padding:0 0 24px;font-size:28px;font-weight:700;letter-spacing:-1px;color:#285e4f;">votivo.</td>
          </tr>
          <tr>
            <td style="padding:32px;background-color:#ffffff;border:1px solid #dfe5e2;border-top:4px solid #285e4f;border-radius:12px;">
              <div class="votivo-content" style="font-size:16px;line-height:1.65;color:#202b2b;">
                <#nested>
              </div>
            </td>
          </tr>
          <tr>
            <td style="padding:24px 0;font-size:13px;line-height:1.6;color:#677171;">Votivo &middot; Room for every opinion.</td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
</#macro>
