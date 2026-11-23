<#import "template.ftl" as layout>
<#import "components/atoms/button.ftl" as button>
<#import "components/atoms/button-group.ftl" as buttonGroup>

<@layout.registrationLayout displayMessage=false showAnotherWayIfPresent=false; section>
  <#if section="header">
    <#if messageHeader??>
      ${kcSanitize(msg(messageHeader))?no_esc}
    <#else>
      ${kcSanitize(message.summary)?no_esc}
    </#if>
  <#elseif section="form">
    <div id="kc-info-message" class="space-y-4">
      <div class="bg-primary-50 border border-primary-100 p-4 rounded-lg text-secondary-700 text-sm leading-relaxed" role="status">
        <p class="break-words">
          ${kcSanitize(message.summary)?no_esc}<#if requiredActions?? && requiredActions?has_content>:
            <strong><#list requiredActions as requiredAction>${kcSanitize(msg("requiredAction." + requiredAction))?no_esc}<#sep>, </#list></strong>
          </#if>
        </p>
      </div>
      <#if !skipLink??>
        <#if pageRedirectUri?has_content>
          <@buttonGroup.kw>
            <@button.kw color="primary" component="a" href=pageRedirectUri>
              ${kcSanitize(msg("backToApplication"))?no_esc}
            </@button.kw>
          </@buttonGroup.kw>
        <#elseif actionUri?has_content>
          <@buttonGroup.kw>
            <@button.kw color="primary" component="a" href=actionUri>
              ${kcSanitize(msg("proceedWithAction"))?no_esc}
            </@button.kw>
          </@buttonGroup.kw>
        <#elseif (client.baseUrl)?has_content>
          <@buttonGroup.kw>
            <@button.kw color="primary" component="a" href=client.baseUrl>
              ${kcSanitize(msg("backToApplication"))?no_esc}
            </@button.kw>
          </@buttonGroup.kw>
        </#if>
      </#if>
    </div>
  </#if>
</@layout.registrationLayout>
