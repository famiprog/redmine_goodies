module QuestionsSystemHelper
    def formatting_question_content(question, obj)
        textilizable(question, project: obj.project)
            .gsub("<p>", "<span>").gsub("</p>", "</span>")
            .gsub(/<img src="(clipboard-[^"]+)"/) do |match|
                img_name = $1
                attachment = obj.attachments.find { |att| att.filename == img_name } if obj.respond_to?(:attachments)
                attachment ? "<img src=\"#{url_for(controller: 'attachments', action: 'download', id: attachment.id)}\"" : match
            end
    end

    def render_question(number, question_text, note_link, obj)
        render partial: "redmine_goodies/questions_macro", locals: { number: number, question_text: question_text, note_link: note_link, obj: obj }
     end
end