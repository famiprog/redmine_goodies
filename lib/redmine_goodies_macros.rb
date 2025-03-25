module RedmineGoodiesMacros
    module WikiMacros
        module QuestionMacro
            Redmine::WikiFormatting::Macros.register do
                desc "Custom macro for rendering questions"
                macro :questions do |obj, args, text|
                    if args.length == 1 && !args[0].match?(/\A\d+\z/)
                        return l(:questions_system_invalid_question_macro).html_safe
                    end
                    # eg: 
                    # {{questions
                    #       1  /  A question?
                    #     2/Another question?
                    # }}, the regex below will extract:
                    # ('1/' and 'A question?'); ('2/' and 'Another question?')
                    output = text.gsub(/^\s*(\d+)\s*\/\s*(.*?)(?=\n\s*\d+\s*\/|\n\}\}|\z)/m) do |match|
                        number = $1
                        question = formatting_question_content($2, obj)
                        render_questions(number, question, obj)
                    end
                    output += l(:questions_system_note_info)
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
                        return l(:questions_system_answer_macro_text, note_ref: note_ref, number: number).html_safe
                    end
                    return l(:questions_system_invalid_answer_macro).html_safe
                end
            end
        end
    end
end