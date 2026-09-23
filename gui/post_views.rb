# frozen_string_literal: true

require_relative 'base_view'

module UserHub
  module GUI
    # TODO: replace with the real screen.
    class PostListView < StubView
      private

      def view_title
        'My Posts'
      end

      def back_target
        :user_dashboard
      end

      def todo_items
        [
          'Treeview of current_user.posts: id, title, created, updated, attachment count',
          'Search by title, sort by clicking column headings',
          'Buttons: New, Edit (sets controller.selected_post), Delete (confirm?), Attachments'
        ]
      end
    end

    # TODO: replace with the real screen.
    class PostFormView < StubView
      private

      def view_title
        'Create / Edit Post'
      end

      def back_target
        :post_list
      end

      def todo_items
        [
          'Title entry and content Text widget (Validator.post)',
          'Create: Post.new + current_user.create_post; Edit: Post#edit + current_user.update_post',
          'Call user_manager.save after every change'
        ]
      end
    end

    # TODO: replace with the real screen.
    class AttachmentListView < StubView
      private

      def view_title
        'Attachments'
      end

      def back_target
        :post_list
      end

      def todo_items
        [
          'Treeview of controller.selected_post.attachments',
          'Add: Tk.getOpenFile, build name/type/size from the file, Validator.attachment, copy into data/uploads',
          'Enforce the 5-attachment limit (Post#add_attachment raises LimitError)',
          'Remove: Post#remove_attachment(id) after confirm?'
        ]
      end
    end
  end
end
