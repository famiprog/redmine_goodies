function addAnswerMacroToNotesEditor(noteId, questionNumber) {
    const notesEditor = document.getElementById('issue_notes'); //issue
    // const notesEditor = document.getElementById('message_content'); // forum
    if (!notesEditor) return;
    const answerMacro = `{{answer(${noteId}, ${questionNumber}/)}} `;
    notesEditor.value += notesEditor.value.length > 0 ? `\n\n${answerMacro}` : answerMacro;
    const cursorPosition = notesEditor.value.length;
    notesEditor.setSelectionRange(cursorPosition, cursorPosition);
    notesEditor.focus();
}

function markAnsweredQuestions() {
    const notes = document.querySelectorAll(".message-content"); // issue
    // const notes = document.querySelectorAll(".message"); //forum
    notes.forEach(noteContent => {
        /**
         * eg: "Answer for #note-26, 2/ In my opinion, this is the solution."
         * the regex below will match: "Answer for #note-26, 2/"
         * and it will extract: "26" & "2"
         */
        const answers = noteContent.innerHTML.matchAll(/Answer for <a href="#note-\d+">#note-(\d+)<\/a>, (\d+)\//g);
        answers.forEach(answer => {
            const questionNoteId = answer[1];
            const questionNumber = answer[2];
            const answerNoteId = noteContent.parentElement.parentElement.id;
            const answeredTextId = `answered-text-${questionNoteId}-${questionNumber}`;
            const answeredTextElement = document.getElementById(answeredTextId);
            const addedAnswers = answeredTextElement.querySelector(".answers");
            answeredTextElement?.parentElement?.classList.add("questions-answered");
            answeredTextElement.parentElement?.querySelector(".not-yet-answered")?.remove()
            addedAnswers === null ?
                answeredTextElement.innerHTML = `<i class="icon icon-checked" style="padding-left: 15px;"></i><span class=\"answers\">Answered in <a href=#${answerNoteId}>#${answerNoteId}</a></span>,&nbsp;` :
                addedAnswers.innerHTML += `, <a href=#${answerNoteId}>#${answerNoteId}</a>`;
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
            this.encloseLineSelection('{{questions(1)\n\n1/ ','\n\n}}');
        }
    }
};
