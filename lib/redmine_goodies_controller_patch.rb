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
                #   <p><img src="/attachments/download/90/clipboard-202408191804-gdzhu.png" alt=""></p>
                #   <p><img srcset="/attachments/thumbnail/98/200 2x" style="max-width: 100px; max-height: 100px;" src="/attachments/thumbnail/98/200"></p>
                # </div>, this regex will match: 
                # "<img src="/attachments/download/90/clipboard-202408191804-gdzhu.png" alt="">"
                response.body = response.body.gsub(/<img(?![^>]*\bsrcset\b)[^>]*>/) do |img|
                    "<details class=\"collapsible-img\"><summary><span class=\"icon-image-collapsible\"></span><a class=\"expand-collapse-btn\">Click to expand/collapse image</a> | <a href=\"#\" onclick=\"expandAll(&quot;#main&quot;); return false;\">Expand all</a> | <a href=\"#\" onclick=\"collapseAll(&quot;#main&quot;); return false;\">Collapse all</a></summary>#{img}</details>"
                end
            end
        end
    end
end
