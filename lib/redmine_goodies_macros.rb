module RedmineGoodiesMacros
    module WikiMacros
        module QuestionMacro
            Redmine::WikiFormatting::Macros.register do
                desc "Custom macro for rendering questions"
                macro :questions do |obj, args, text|
                    if args.length == 1 && !args[0].match?(/\A\d+\z/)
                        return "<p style=\"color: red\"><b>Error:</b> Invalid argument for the questions macro. It must be a number.<p>".html_safe
                    end
                    # eg: 
                    # {{questions
                    #     1/ A question?
                    # }}, the regex below will extract:
                    # '1/' and 'A question?'
                    output = text.gsub(/^(\d+)\/ (.+)$/) do |match|
                        number = $1
                        # this is needed because when 'html_safe' is applied, markdown is no longer interpreted.
                        question = Redmine::WikiFormatting.to_html("markdown", $2).gsub("<p>", "<span>").gsub("</p>", "</span>")
                        note_link = obj.respond_to?(:indice) && obj.indice ? "#note-#{obj.indice}" : "note unknown/needs page refresh"
                        reply_btn = "<i class=\"icon icon-comment\" style=\"vertical-align: middle;\"></i><a class=\"reply-btn\" onclick=\"showAndScrollTo(&quot;update&quot;, &quot;issue_notes&quot;); addAnswerMacroToNotesEditor(&quot;#{note_link}&quot;, &quot;#{number}&quot;); return false;\">Add answer</a>"
                        "<p><span class=\"questions-macro\"><b>Question: <a href=\"#{note_link}\">#{note_link}</a>, #{number}/</b> (<span id=\"answered-text-#{obj.respond_to?(:indice) && obj.indice ? obj.indice : "x"}-#{number}\"></span>#{reply_btn})</span> #{question}</p>"
                    end
                    output.html_safe
                end
            end
        end
        module AnswerMacro
            Redmine::WikiFormatting::Macros.register do
                desc "Custom macro for rendering answers"
                macro :answer do |obj, args|
                    if args.length == 2
                        note_ref = args[0]
                        number = args[1]
                        return "<span class=\"answer-macro\">Answer for <a href=\"#{note_ref}\">#{note_ref}</a>, #{number}</span>".html_safe
                    end
                    return "<p style=\"color: red\"><b>Error:</b> Invalid arguments for answer macro.<p>".html_safe
                end
            end
        end
    end
end