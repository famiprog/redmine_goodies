module RedmineGoodiesMacros
    module WikiMacros
        module QuestionMacro
            Redmine::WikiFormatting::Macros.register do
                desc "Custom macro for rendering questions"
                macro :questions do |obj, args, text|
                    if args.length == 1 && !args[0].match?(/\A\d+\z/)
                            output = "<p style=\"color: red\"><b>Error:</b> Invalid argument for the questions macro. It must be a number.<p>"
                    else
                        # eg: 
                        # {{questions
                        #     1/ A question?
                        # }}, the regex below will extract:
                        # '1/' and 'A question?'
                        output = text.gsub(/^(\d+)\/ (.+)$/) do |match|
                            number = $1
                            question = $2
                            note_link = obj.respond_to?(:indice) && obj.indice ? "#note-#{obj.indice}" : "note unknown/needs page refresh"
                            reply_btn = "<i class=\"icon icon-comment\" style=\"vertical-align: middle;\"></i><a class=\"reply-btn\" onclick=\"showAndScrollTo(&quot;update&quot;, &quot;issue_notes&quot;); addAnswerMacroToNotesEditor(&quot;#{note_link}&quot;, &quot;#{number}&quot;); return false;\">Add answer</a>"
                            "<div><span class=\"questions-macro\"><b>Question: <a href=\"#{note_link}\">#{note_link}</a>, #{number}/</b> (<span id=\"answered-text-#{obj.respond_to?(:indice) && obj.indice ? obj.indice : "x"}-#{number}\"></span>#{reply_btn})</span> #{question}</div><br>"
                        end 
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
                        "<span class=\"answer-macro\">Answer for <a href=\"#{note_ref}\">#{note_ref}</a>, #{number}</span>".html_safe
                    else
                        "Error: Invalid arguments for answer macro."
                    end
                end
            end
        end
    end
end