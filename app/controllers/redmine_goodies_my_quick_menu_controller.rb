class RedmineGoodiesMyQuickMenuController < ApplicationController
    before_action :require_login

    def show
        pairs = RedmineGoodiesSettings.my_quick_menu_pairs
        @wiki_content = nil

        pairs.each do |pair|
            if User.current.id == pair[:id] || User.current.groups.any? { |g| g.id == pair[:id] }
                result = find_wiki_content(pair[:url_fragment])
                if result
                    @wiki_content = result[:content]
                    # project needed for included macros
                    @project      = result[:project]
                end
                break
            end
        end

        render :layout => false
    end

    private

    def find_wiki_content(url_fragment)
        return nil unless url_fragment =~ /projects\/([^\/]+)\/wiki\/([^?#]+)/

        identifier = $1
        page_title = CGI.unescape($2)

        project = Project.find_by_identifier(identifier)
        return nil unless project&.wiki

        page = project.wiki.find_page(page_title)
        return nil unless page&.content

        { content: page.content, project: project }
    end
end
