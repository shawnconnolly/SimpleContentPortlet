<%--

    Licensed to Jasig under one or more contributor license
    agreements. See the NOTICE file distributed with this work
    for additional information regarding copyright ownership.
    Jasig licenses this file to you under the Apache License,
    Version 2.0 (the "License"); you may not use this file
    except in compliance with the License. You may obtain a
    copy of the License at:

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on
    an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied. See the License for the
    specific language governing permissions and limitations
    under the License.

--%>

<jsp:directive.include file="/WEB-INF/jsp/include.jsp"/>
<c:set var="includeJQuery" value="${renderRequest.preferences.map['includeJQuery'][0]}"/>
<c:set var="n"><portlet:namespace/></c:set>
<portlet:actionURL var="formUrl" escapeXml="false"><portlet:param name="action" value="updateConfiguration"/></portlet:actionURL>
<portlet:actionURL var="cancelUrl"><portlet:param name="action" value="cancelUpdate"/></portlet:actionURL>
<portlet:resourceURL var="previewUrl" id="preview" escapeXml="false"/>

<c:if test="${includeJQuery}">
    <rs:aggregatedResources path="skin.xml"/>
</c:if>

<style type="text/css">
    #${n}contentForm .flc-inlineEdit-text { min-height: 100px; border: thin dashed #666; padding: 10px; margin: 10px; }
</style>

<h2><spring:message code="configurationForm.title"/></h2>
<p><spring:message code="configurationForm.editInvitation"/></p>

<form:form id="${n}contentForm" commandName="form" action="${formUrl}" method="post">

    <div class="flc-inlineEdit-text">
        ${ form.content }
    </div>

    <div class="flc-inlineEdit-editContainer" style="display:none">

        <form:textarea path="content"/>

        <button class="portlet-form-button portlet-button button portlet-button-primary primary save">
            <spring:message code="configurationForm.preview"/>
        </button>

        <button class="cancel portlet-form-button portlet-button button portlet-button-secondary secondary">
            <spring:message code="configurationForm.cancel"/>
        </button>

    </div>
    
    <div class="save-configuration-button portlet-button-group buttons">
        <input class="portlet-form-button portlet-button portlet-button-primary" type="submit" value="<spring:message code="configurationForm.save"/>"/>
    </div>
    <div class="announcements-portlet-row" id="${n}attachment_add_section" style="display:none;">
        <label>
            <spring:message code="configurationForm.images"/>
            <a style="text-decoration:none;" href="javascript:upAttachments.show(${n}.addAttachmentCallback);">
                <img src="<c:url value="/icons/add.png"/>" border="0" height="16" width="16" style="vertical-align:middle;"/>
            </a>
        </label>
        <div id="${n}attachments" class="announcements-portlet-col">
        </div>
    </div>
    <p>
        <a href="${ cancelUrl }">
            <spring:message code="configurationForm.return"/>
        </a>
    </p>   
     
</form:form>
    
<script type="text/javascript">
    var ${n} = ${n} || {};
    ${n}.jQuery = jQuery.noConflict(${includeJQuery});
    ${n}.fluid = fluid;
    ${n}._ = _.noConflict(); // assign underscore to this namespace

    <c:if test="${includeJQuery}">fluid = null; fluid_1_2 = null;</c:if>
    
    ${n}.scriptCapableViewAccessor = function (element) {
        return {
            value: function (newValue) {
                if (newValue) {
                    element.innerHTML = newValue;
                    return ${n}.jQuery(element);
                } else {
                    return element.innerHTML;
                }
            }
        };
    };
    
    ${n}.jQuery(function(){
        var $ = ${n}.jQuery;
        var _ = ${n}._;
        var fluid = ${n}.fluid;
        var cleanContent = ${cleanContent};

        var makeButtons = function (editor) {
            $(".save", editor.container).click(function(){
                editor.finish();
                return false;
            });

            $(".cancel", editor.container).click(function(){
                editor.cancel();
                $(".save-configuration-button").show();
                return false;
            });
        };

        // Display and use the attachments feature only if it's present
        if(typeof upAttachments != "undefined")
        {
            ${n}.addAttachmentCallback = function(result) {
                ${n}.addAttachment(result);
                upAttachments.hide();
            };
            ${n}.addAttachment = function(result) {
                _.templateSettings.variable = "attachment";
                var template = $('#${n}template-attachment-add-item').html();
                var compiled = _.template(template, result);
                $("#${n}attachments").append(compiled);
                var addedElement = $("#${n}attachments").find('.attachment-item:last');
                addedElement.find('.remove-button').click(function() {
                    addedElement.remove();
                });
            };
            <c:forEach items="${announcement.attachments}" var="attachment">
                ${n}.addAttachment(${attachment});
            </c:forEach>
            $("#${n}attachment_add_section").show();
        }

        $(document).ready(function(){
            // Create an CKEditor 3.x-based Rich Inline Edit component.
            var ckEditor = fluid.inlineEdit.CKEditor("#${n}contentForm", {
                displayAccessor: {
                    type: "${n}.scriptCapableViewAccessor"
                },
                listeners: {
                    onBeginEdit: function(){ $(".save-configuration-button").hide(); },
                    afterFinishEdit: function(newVal, old, edit, view){
                        if (cleanContent) {
                            $.ajax({
                                url: "${ previewUrl }",
                                data: { content: newVal },
                                dataType: "json",
                                async: false,
                                type: "POST",
                                success: function(data) {
                                    ckEditor.updateModelValue(data.content);
                                }
                            });
                        } else {
                            ckEditor.updateModelValue(newVal);                            
                        }
                        $(".save-configuration-button").show();
                    }
                },
                strings: {
                    textEditButton: '<spring:message code="configurationForm.textEditButton"/>'
                },
                tooltipText: '<spring:message code="configurationForm.editInvitation"/>',
                defaultViewText: '<spring:message code="configurationForm.editInvitation"/>'
            });
            makeButtons(ckEditor);  
        });
        
    });
</script>

<script type="text/template" id="${n}template-attachment-add-item">
    <div id="${n}attachment_add_${"<%="} attachment.id ${"%>"}" class="attachment-item">
        <a class="remove-button" href="javascript:void(0);">
            <img id="attachment-delete" src="<c:url value="/icons/delete.png"/>" border="0" style="height:14px;width:14px;vertical-align:middle;margin-right:5px;cursor:pointer;"/>
        </a>
        <span>${"<%="} attachment.filename ${"%>"}</span>
        <input type="hidden" name="attachments" value='${"<%="} JSON.stringify(attachment) ${"%>"}'/>

    </div>
</script>