module RedmineGoodiesControllerPatch
    include RedmineGoodiesHelper

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.send(:after_action, :remove_lazy_loading_img)
        base.send(:after_action, :collapsible_images)
        base.send(:after_action, :actions_to_trigger_when_fields_changed, if: -> { request.path.include?("/issues/") })
        base.send(:after_action, :check_actions_to_trigger_when_fields_changed_json, if: -> { request.path.include?("/settings/plugin") })
    end

    module InstanceMethods
        def remove_lazy_loading_img
            if RedmineGoodiesSettings.remove_lazy_loading?
                response.body = response.body.gsub(/loading="lazy"/, "")
            end
        end

        def collapsible_images
            if RedmineGoodiesSettings.collapsible_images?
                # e.g. 
                # <div class="...">
                #   <p><img src="/attachments/thumbnail/91/clipboard-202408191234-gdasdu.png" alt=""></p>
                #   <img alt="clipboard-202410301333-uwhg6.png" class="filecontent image" src="/attachments/download/253/clipboard-202410301333-uwhg6.png">
                #   <p><img src="/attachments/download/90/clipboard-202408191804-gdzhu.png" alt=""></p>
                #   <p><img srcset="/attachments/thumbnail/98/200 2x" style="max-width: 100px; max-height: 100px;" src="/attachments/thumbnail/98/200"></p>
                # </div>, this regex will match: 
                # "<img src="/attachments/download/90/clipboard-202408191804-gdzhu.png" alt="">"
                response.body = response.body.gsub(/<img(?![^>]*\b(class="[^"]*\bfilecontent\b[^"]*"|\bsrcset\b))[^>]*\bsrc="\/attachments\/download[^"]*"[^>]*>/) do |img|
                    "<details class=\"collapsible-img\"><summary><span class=\"icon-image-collapsible\"></span><a class=\"expand-collapse-btn\" onclick=\"addBackgroundToCollapsibleImage(event.target?.parentElement.parentElement)\">Click to expand/collapse image</a> | <a href=\"#\" onclick=\"expandAll(event); return false;\">Expand all</a> | <a href=\"#\" onclick=\"collapseAll(event); return false;\">Collapse all</a></summary>#{img}</details>"
                end
            end
        end

        def check_actions_to_trigger_when_fields_changed_json
            begin
                actions_to_trigger_when_fields_changed = JSON.parse(RedmineGoodiesSettings.get_setting(:actions_to_trigger_when_fields_changed))
                actions_to_trigger_when_fields_changed.each do |field_actions|
                    unless field_actions.is_a?(Hash) && field_actions.key?(RedmineGoodiesHelper::JSON_FIELDS[:FIELD]) && field_actions.key?(RedmineGoodiesHelper::JSON_FIELDS[:VALUE]) && field_actions.key?(RedmineGoodiesHelper::JSON_FIELDS[:TRIGGER]) && field_actions.key?(RedmineGoodiesHelper::JSON_FIELDS[:ACTIONS])
                        raise StandardError, "Missing or wrong keys in json: #{field_actions.inspect}"
                    end
                end
            rescue JSON::ParserError => e
                flash.discard(:notice)
                flash[:error] = "Error parsing JSON: #{e.message}"
            rescue StandardError => e
                flash.discard(:notice)
                flash[:error] = e.message
            end
        end

        def actions_to_trigger_when_fields_changed
            actions_to_trigger_when_fields_changed = JSON.parse(RedmineGoodiesSettings.get_setting(:actions_to_trigger_when_fields_changed))
            actions_to_trigger_when_fields_changed.each do |field_actions|
                apply_actions(field_actions)
            end
        end
    end
end
