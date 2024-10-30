module RedmineGoodiesControllerPatch
    def self.included(base)
        base.send(:include, InstanceMethods)
        base.send(:after_action, :remove_lazy_loading_img)
        base.send(:after_action, :collapsible_images)
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
    end
end
