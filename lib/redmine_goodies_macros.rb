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
                    output = text.gsub(/^\s*(\d+)\s*\/\s*(.+?)\s*$/) do |match|
                        number = $1
                        question = formatting_question_content($2, obj)
                        note_link = obj.respond_to?(:indice) && obj.indice ? "#note-#{obj.indice}" : "note unknown/needs page refresh"
                        render_question(number, question, note_link, obj)
                    end
                    question_system_info = "<p class=\"question_system_info\"><i>NOTE: these questions were added using the <span class=\"jstb_questions_macro\"></span> button. For answering, please use the \"Add answer\" button. This way the questions/answers will be linked together.</i></p>"
                    output += question_system_info
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