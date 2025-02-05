function addAnswerMacroToNotesEditor(noteId, questionNumber, is_issue) {
    const editor = is_issue ? document.getElementById('issue_notes') : document.getElementById('message_content');
    if (!editor) return;
    const answerMacro = `{{answer(${noteId}, ${questionNumber}/)}} `;
    editor.value += editor.value.length > 0 ? `\n\n${answerMacro}` : answerMacro;
    const cursorPosition = editor.value.length;
    editor.setSelectionRange(cursorPosition, cursorPosition);
    editor.focus();
}

function markAnsweredQuestions() {
    const notes = document.querySelectorAll(".message-content");
    if (notes === null || notes.length === 0) {
        return;
    }
    for (let i = 0; i < notes.length; i++) {
        const noteContent = notes[i];
        const answers = noteContent.innerHTML.matchAll(/Answer for <a href="#(?:note|message)-\d+">#(?:note|message)-(\d+)<\/a>, (\d+)\//g);
        for (const answer of answers) {
            const questionNoteId = answer[1];
            const questionNumber = answer[2];
            const answerNoteId = noteContent.parentElement.parentElement.id;
            const answeredTextId = `answered-text-${questionNoteId}-${questionNumber}`;
            const answeredTextElement = document.getElementById(answeredTextId);
            const addedAnswers = answeredTextElement.querySelector(".answers");
            answeredTextElement?.parentElement?.classList.add("questions-answered");
            answeredTextElement?.parentElement?.querySelector(".not-yet-answered")?.remove();
            if (addedAnswers === null) {
                answeredTextElement.innerHTML = `<i class="icon icon-checked" style="padding-left: 15px;"></i><span class=\"answers\">Answered in <a href=#${answerNoteId}>#${answerNoteId}</a></span>,&nbsp;`;
            } else {
                addedAnswers.innerHTML += `, <a href=#${answerNoteId}>#${answerNoteId}</a>`;
            }
        }
    }
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
            this.encloseLineSelection('{{questions(1)\n\n1/ ','\n\n}}');
        }
    }
};
