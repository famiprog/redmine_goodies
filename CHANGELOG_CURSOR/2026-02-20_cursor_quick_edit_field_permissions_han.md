# Quick edit field permissions handling
_Exported on 2/20/2026 at 11:04:46 GMT+1 from Cursor (2.4.31)_

---

**User**

The quick edit field works regardless of the permissions.   First check the permission. If no permission: server side: forbid. Client: show that entry in menu, but disabled + the suffix (read only).

---

**User**

doesn't work. The field Pr list, via workflow, is read-only for all roles (except Manager). E.g. including for a developer. I am logged in w/ a developer. I still can modify.

---

**User**

same. a "dev" can edit Pr list. Although it's read only cf. workflow

---

**User**

1/ It seems to work. The context menu show disabled, as requested. I have no means to verify if the server implementation also enforces the check (in case of a hacker). Is it so?
2/ the "disabled" looks ugly. Because it has another style and alignment. Let's not change the style. Only add "(read only)", and on click: do nothing. This way, the visuals will be uniform.

---

