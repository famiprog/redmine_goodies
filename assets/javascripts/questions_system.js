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