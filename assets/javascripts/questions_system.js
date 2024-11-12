function addAnswerMacroToNotesEditor(noteId, questionNumber) {
    const notesEditor = document.getElementById('issue_notes');
    if (!notesEditor) return;
    const answerMacro = `{{answer(${noteId}, ${questionNumber}/)}} `;
    notesEditor.value += notesEditor.value.length > 0 ? `\n\n${answerMacro}` : answerMacro;
    const cursorPosition = notesEditor.value.length;
    notesEditor.setSelectionRange(cursorPosition, cursorPosition);
    notesEditor.focus();
}

function markAnsweredQuestions() {
    const notes = document.querySelectorAll(".message-content");
    notes.forEach(noteContent => {
        /**
         * eg: "Answer for #note-26, 2/ In my opinion, this is the solution."
         * the regex below will match: "Answer for #note-26, 2/"
         * and it will extract: "26" & "2"
         */
        const answers = noteContent.innerHTML.matchAll(/Answer for <a href="#note-\d+">#note-(\d+)<\/a>, (\d+)\//g);
        const linkNotes = [];
        answers.forEach(answer => {
            const questionNoteId = answer[1];
            const questionNumber = answer[2];
            const answerNoteId = noteContent.parentElement.parentElement.id;
            const answeredTextId = `answered-text-${questionNoteId}-${questionNumber}`;
            const answeredTextElement = document.getElementById(answeredTextId);
            linkNotes.push(`<a href=#${answerNoteId}>#${answerNoteId}</a>`);
            answeredTextElement.innerHTML = `<i class="icon icon-checked" style="padding-left: 15px;"></i><span>Answered in [${linkNotes}]</span>,&nbsp;`;
        });
    });
}

jsToolBar.prototype.elements.space6 = {
    type: 'space',
};

jsToolBar.prototype.elements.questions_macro = {
    type: 'button',
    title: 'Questions macro',
    fn: {
        wiki: function() {
            this.encloseLineSelection('{{questions\n\n1/ ','\n\n}}');
        }
    }
};

jsToolBar.prototype.elements.questions_macro_arg = {
    type: 'button',
    title: 'Questions macro with arg',
    fn: {
        wiki: function() {
            this.encloseLineSelection('{{questions(1', ')}}');
        }
    }
};
