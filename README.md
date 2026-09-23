# UserHub (Ruby + Tk)

Desktop app for registering users, managing profiles/addresses, posts and attachments,
with an administrator dashboard and reports. Follows the provided UML class diagram.

## Run

```
gem install tk        # also needs Tcl/Tk 8.6 installed on the system
ruby main.rb          # start the app
ruby test/models_test.rb   # model/service tests, no display needed
```

First run seeds an administrator: **admin@userhub.com / admin123** (username "Eric").
Data is saved to `data/userhub.json`; delete that file to start fresh.

## Structure

```
main.rb                 entry point
userhub.rb              loads models + services (never requires Tk)
errors.rb               ValidationError, NotFoundError, DuplicateError, LimitError
models/                 user, address, post, attachment, user_manager   (UML classes)
services/               validator, password_hasher, storage, report_generator
gui/                    app (controller/navigator), base_view, one file per screen
test/                   models_test.rb
data/                   userhub.json (created at runtime), uploads/
```

Rule: `models/` and `services/` never touch Tk. Views call `UserManager` and display results.

## UML mapping (Ruby naming conventions)

| UML                              | Ruby                                        |
|----------------------------------|---------------------------------------------|
| `nextUserId <<static>>`          | `User.next_user_id` (class-level instance variable) |
| `nextPostId`, `nextAttachmentId` | `Post.next_post_id`, `Attachment.next_attachment_id` |
| `getFullAddress()`               | `Address#get_full_address`                  |
| `createPost / updatePost / deletePost` | `User#create_post / update_post / delete_post` |
| `addAttachment / removeAttachment` | `Post#add_attachment / remove_attachment` |
| `createUser / getUser / updateUser / deleteUser / getAllUsers` | `UserManager#create_user / get_user / update_user / delete_user / get_all_users` |
| `password : Text`                | `password_digest` (salted PBKDF2-SHA256, never plain text) |
| `User[*]`                        | `Array` of `User`                           |
| `Text / Number / DateTime`       | `String / Integer / Time`                   |

## Design decisions

- **Admin** is a `role` (`:user` / `:admin`) on `User`; admins are hidden from user lists and counts.
- **Users** live in a `Hash` keyed by `user_id`; posts and attachments are `Array`s.
- **Composition**: deleting a user drops their posts; deleting a post drops its attachments.
- **Deleted accounts** are counted in `UserManager#deleted_accounts_count` and persisted.
- **Static counters** are saved in the JSON file so IDs never repeat after a restart.
- **Passwords** use stdlib PBKDF2 (no gem needed). Swap in bcrypt by editing `services/password_hasher.rb` only.

## Status / TODO (by grading area)

- [x] Models, validation rules, search methods, dashboard statistics, JSON persistence, report data + CSV export
- [x] GUI: navigation, login, registration, user dashboard (incl. delete account), admin dashboard (stats + recent tables)
- [ ] GUI: profile (+ profile picture, change password), address form
- [ ] GUI: post list / create / edit / delete, attachment list / add / remove
- [ ] GUI: admin user management (create, view, search, sort, update, delete), all posts, attachment view
- [ ] GUI: reports screen + export button (HTML / PDF optional)
- [ ] Copy chosen attachment and profile picture files into `data/uploads/`
