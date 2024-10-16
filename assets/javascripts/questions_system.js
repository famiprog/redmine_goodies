function addAnswerMacroToNotesEditor(note_id, question_number) {
    const notesEditor = document.getElementById('issue_notes');
    const answerMacro = "{{answer(" + note_id + ", " + question_number + "/" + ")}}"
    if (notesEditor) {
        const start = notesEditor.selectionStart;
        const end = notesEditor.selectionEnd;
        const currentValue = notesEditor.value;
        notesEditor.value = currentValue.substring(0, start) + answerMacro + currentValue.substring(end);
        notesEditor.selectionStart = notesEditor.selectionEnd = start + answerMacro.length;
        notesEditor.focus();
    } 
}

function markAnsweredQuestions() {
    const notes = document.querySelectorAll(".message-content");
    notes.forEach(noteContent => {
        /**
         * eg: "[Answer for #note-26, 2/] In my opinion, this is the solution."
         * the regex below will match: "[Answer for #note-26, 2/]"
         * and it will extract: "26" & "2"
         */
        const answers = noteContent.innerHTML.matchAll(/\[Answer for <a href="#note-\d+">#note-(\d+)<\/a>, (\d+)\/\]/g);
        answers.forEach(answer => {
            const questionNoteId = answer[1];
            const questionNumber = answer[2];
            const answerNoteId = noteContent.parentElement.parentElement.id;
            const answeredTextId = `answered-text-${questionNoteId}-${questionNumber}`;
            const answeredTextElement = document.getElementById(answeredTextId);
            answeredTextElement.innerHTML = `<i class="icon icon-checked" style="padding-left: 15px;"></i><span>Answered in <a href=#${answerNoteId}>#${answerNoteId}</a></span>,&nbsp;`;
        });
    });
}