# redmine_goodies

# Features

## Button for `<details>` tag

<details>

Simple version:

![](img-readme/details1.png)

Version w/ custom text for expand/collapse:

![](img-readme/details2.png)

You can select an existing section, and it will be wrapped in `<details>`.

![](img-readme/details3.png)

![](img-readme/details4.png)

And by the way, this is how it's rendered. `<details>` is a standard HTML tag; it's not our invention. You can use it anywhere in HTML and/or Markdown. In other programs as well, e.g. GitHub, etc. We use this tag even for this `README.md` that you are currently reading 🙂.

![](img-readme/details5.png)

</details>

## Button and highlight for questions/answers

<details>

### Add questions

<table>
    <tr>
        <td>Fig 1</td>
        <td>Fig 2</td>
    </tr>
    <tr>
        <td>

![](img-readme/questions1.png)
        </td>
        <td>

![](img-readme/questions2.png)
        </td>
    </tr>
    <tr>
        <td colspan="2">Fig 3</td>
    </tr>
    <tr>
        <td colspan="2">

![](img-readme/questions3.png)

Questions w/o answer are in *yellow*.
        </td>
    </tr>
</table>

In our company we leverage this plugin and:
* we have a scheduled task (written in TS / [deno](https://deno.com/))
* that uses the API to check if the questions are answered
* and if not, it sends reminders.

### Answer to questions

<table>
    <tr>
        <td>Fig 1</td>
        <td>Fig 2</td>
    </tr>
    <tr>
        <td>

![](img-readme/questions4.png)
        </td>
        <td>

![](img-readme/questions5.png)

Will switch the issue in edit mode and add the macro.
        </td>
    </tr>
    <tr>
        <td colspan="2">Fig 3</td>
    </tr>
    <tr>
        <td colspan="2">

![](img-readme/questions6.png)

If the issue is in edit mode, it will append the macro, to the existing note (at cursor position)
        </td>
    </tr>
    <tr>
        <td colspan="2">Fig 4</td>
    </tr>
    <tr>
        <td colspan="2">

![](img-readme/questions7.png)

The answers are in *green*. The answered questions switched from *yellow* to *blue*. 

Questions and answers are cross linked; click on *#note-???* to navigate between them.
        </td>
    </tr>
    <tr>
        <td colspan="2">Fig 5</td>
    </tr>
    <tr>
        <td colspan="2">

![](img-readme/questions8.png)

A question can have multiple answers.
        </td>
    </tr>    
</table>

**Hint:** the question system can also be used on forums.

## Limitation

1/ WHEN a question is on page 1 of a **forum** AND the answer is on page 2, THEN the cross-linking between them will not work properly.

![](img-readme/question_forum.png)

![](img-readme/answer_forum.png)

Even if the question has an answer, it is not marked as answered. Also, when you click on the link to the question from the answer, nothing happens.

</details>

# Licenses for third party components/assets

We use some icons from [Google Fonts](https://fonts.google.com/icons), licensed under [Apache License v2](https://www.apache.org/licenses/LICENSE-2.0.html)