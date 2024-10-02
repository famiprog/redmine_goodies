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
                # e.g. <div class="..."><p><img src="/attachments/download/90/clipboard-202408191804-gdzhu.png" alt=""></p></div>, this regex will match: 
                # "<p><img src="/attachments/download/90/clipboard-202408191804-gdzhu.png" alt=""></p>"
                response.body = response.body.gsub(/<p><img\s+[^>]*src=["']?([^"'\s>]+)["']?[^>]*>/) do |img|
                    "<details open><summary>Click to expand image | <a href=\"#\" onclick=\"expandAll('#main'); return false;\">Expand all</a> | <a href=\"#\" onclick=\"collapseAll('#main'); return false;\">Collapse all</a></summary>#{img}</details>"
                end
            end
        end
    end
end
