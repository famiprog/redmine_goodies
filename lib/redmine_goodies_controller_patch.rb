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
                # <div id="note-35" class="note">
                #     ...
                #     <div id="journal-118-notes" class="wiki">
                #          <p><img src="/attachments/download/90/clipboard-202408191804-gdzhu.png" alt=""></p></div>
                #          <p><img src="/attachments/download/90/clipboard-202408191804-gdzhu.png" alt=""></p>
                #     </div>
                #     ...
                # </div>
                # ...
                # <div id="note-36" class="note">
                #     ...
                #     <div id="journal-119-notes" class=\"wiki\">
                #          <p><img src="/attachments/download/90/clipboard-202408191804-gdzhu.png" alt=""></p></div>
                #     </div>
                #     ...
                # </div>
                #
                # The regex below will match:
                # <div journal-118-notes class="wiki">
                #      <p><img src="/attachments/download/90/clipboard-202408191804-gdzhu.png" alt=""></p></div>
                #      <p><img src="/attachments/download/90/clipboard-202408191804-gdzhu.png" alt=""></p>
                # </div>
                # <div id="journal-119-notes" class=\"wiki\">
                #      <p><img src="/attachments/download/90/clipboard-202408191804-gdzhu.png" alt=""></p></div>
                # </div>
                response.body = response.body.gsub(/<div[^>]*class=(\\?"?)wiki(\\?"?)[^>]*>(.*?)<\/div>/m) do |div_class_wiki|
                    # e.g. <div class="..."><p><img src="/attachments/download/90/clipboard-202408191804-gdzhu.png" alt=""></p></div>, this regex will match: 
                    # "<img src="/attachments/download/90/clipboard-202408191804-gdzhu.png" alt="">"
                    div_class_wiki.gsub(/<img\s+[^>]*src=["']?([^"'\s>]+)["']?[^>]*>/) do |img|
                        "<details class=\"collapsible-img\"><summary><span class=\"icon-image-collapsible\"></span><a>Click to expand image</a> | <a href=\"#\" onclick=\"expandAll(&quot;#main&quot;); return false;\">Expand all</a> | <a href=\"#\" onclick=\"collapseAll(&quot;#main&quot;); return false;\">Collapse all</a></summary>#{img}</details>"
                    end
                end
            end
        end
    end
end
