module RedmineGoodies
    module Macros
        # Retrieves a mapping of note references (that contain questions using the question macro) to their corresponding answers.
        def self.get_all_answers(issue_id)
            issue = Issue.find_by(id: issue_id)    
            journals = issue.journals.order(:created_on)

            # eg. {"#note-19"=>[{:question=>"1", :response_from=>"#note-20"}, {:question=>"2", :response_from=>"#note-20"}
            answered_questions = {}

            # eg. "{{answer(#note-56, 1/}}", the regex below will extract:
            # '#note-56' and '1'
            regex = /\{\{answer\((#\w+-\d+),\s*(\d+)\/\)\}\}/

            # Iterate through each journal and its notes to search for answers to questions
            journals.each do |journal|
                current_notes = journal.notes
                next if current_notes.blank?
                response_from_note_id = "#note-#{journals.index(journal) + 1}"  # getting note_number (not equals with journal.id)
                
                # search in notes for answers to questions
                matches = current_notes.scan(regex)
                matches.each do |match|
                    note_ref = match[0]  # the note reference from which the questions come
                    question_number = match[1]  # the answered question number
                    
                    answered_questions[note_ref] ||= []
                    unless answered_questions[note_ref].any? { |answer| answer[:question] == question_number && answer[:response_from] == response_from_note_id }
                        answered_questions[note_ref] << { question: question_number, response_from: response_from_note_id }
                    end
                end
            end
            answered_questions
        end

        Redmine::WikiFormatting::Macros.register do
            desc "Custom macro for rendering questions"
            macro :questions do |obj, args, text|
                # eg: '{{questions
                #     1/ A question?
                # }}', the regex below will extract:
                # '1/' and 'A question?'
                output = text.gsub(/^(\d+)\/ (.+)$/) do |match|
                    number = $1
                    question = $2
                    
                    note_id = obj.respond_to?(:indice) && obj.indice ? "#note-#{obj.indice}" : "#note-unknown"
                    answered_questions = obj.journalized && RedmineGoodies::Macros.get_all_answers(obj.journalized.id)
                    answered_note = answered_questions[note_id]
                    answered_text = ""

                    if answered_note
                        answered_note.each do |element|
                            if element && element[:question] == number
                                answered_text = "<i class='icon icon-checked' style='padding-left: 15px;'></i><span>Answered in <a href='#{element[:response_from]}'>#{element[:response_from]}</a></span>" + ", "
                                break
                            end
                        end
                    end
                   
                    reply_btn = "<i class='icon icon-comment' style='vertical-align: middle;'></i><a onclick='showAndScrollTo(\"update\", \"issue_notes\"); addAnswerMacroToNotesEditor(\"#{note_id}\", \"#{number}\"); return false;'>Reply</a>"
                    "<div>[Question, <a href='#{note_id}'>#{note_id}</a>, #{number}/] (#{answered_text}#{reply_btn}) #{question}</div><br>"
                end 
                output.html_safe
            end
        end

        Redmine::WikiFormatting::Macros.register do
            desc "Custom macro for rendering answers"
            macro :answer do |obj, args|
                if args.length == 2
                    note_ref = args[0]
                    number = args[1]
                    "<span>[Answer for <a href='#{note_ref}'>#{note_ref}</a>, #{number}]</span>".html_safe
                else
                    "Error: Invalid arguments for answer macro."
                end
            end
        end
    end
end