<#import "template.ftl" as layout>
<#import "components/atoms/button.ftl" as button>
<#import "components/atoms/button-group.ftl" as buttonGroup>
<#import "components/atoms/checkbox.ftl" as checkbox>
<#import "components/atoms/form.ftl" as form>
<#import "components/atoms/input.ftl" as input>

<@layout.registrationLayout
  displayMessage=!messagesPerField.existsError("email")
  ;
  section
>
  <#if section="header">
    ${msg("updateEmailTitle")}
  <#elseif section="form">
    <@form.kw action=url.loginAction method="post" id="kc-update-email-form">
      <#list profile.attributes as attribute>
        <#if attribute.name == "email">
          <@input.kw
            autocomplete="email"
            autofocus=true
            disabled=attribute.readOnly
            invalid=messagesPerField.existsError("email")
            label=msg("email")
            message=kcSanitize(messagesPerField.get("email"))
            name="email"
            required=attribute.required
            type="email"
            value=(attribute.value)!''
          />
        </#if>
      </#list>
      <@checkbox.kw
        label=msg("logoutOtherSessions")
        name="logout-sessions"
        value="on"
      />
      <@buttonGroup.kw>
        <@button.kw color="primary" type="submit">
          ${msg("doSubmit")}
        </@button.kw>
        <#if isAppInitiatedAction??>
          <@button.kw color="secondary" name="cancel-aia" type="submit" value="true" formnovalidate="formnovalidate">
            ${msg("doCancel")}
          </@button.kw>
        </#if>
      </@buttonGroup.kw>
    </@form.kw>
  </#if>
</@layout.registrationLayout>
