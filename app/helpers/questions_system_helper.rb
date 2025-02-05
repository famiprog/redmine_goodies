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

    def render_questions(number, question_text, obj)
        is_issue = false
        if obj.is_a?(Journal)
            is_issue = true
            note_id = obj&.indice
            note_link = note_id ? "#note-#{note_id}" : "note id unknown/needs page refresh"
        elsif obj.is_a?(Message)
            note_id = obj&.id
            note_link = note_id ? "#message-#{note_id}" : "message id unknown/needs page refresh"
        end          

        render partial: "redmine_goodies/questions_macro", locals: { number: number, question_text: question_text, note_link: note_link, id: note_id, is_issue: is_issue }
    end
end