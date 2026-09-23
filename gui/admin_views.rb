# frozen_string_literal: true

require_relative 'base_view'

module UserHub
  module GUI
    # TODO: replace with the real screen.
    class UserManagementView < StubView
      private

      def view_title
        'Manage Users'
      end

      def back_target
        :admin_dashboard
      end

      def todo_items
        [
          'Treeview of user_manager.get_all_users (sortable via get_all_users(sort_by:))',
          'Search box + field selector (User ID / Username / Email) using search_users',
          'Create user (register), update user, delete user (confirm?, then delete_user)',
          'View a user profile and that user\'s posts; open their post attachments'
        ]
      end
    end

    # TODO: replace with the real screen.
    class AllPostsView < StubView
      private

      def view_title
        'All Posts'
      end

      def back_target
        :admin_dashboard
      end

      def todo_items
        [
          'Treeview of user_manager.all_posts: post id, title, author, dates, attachment count',
          'Search by post title (search_posts) and attachment file name (search_attachments)',
          'Select a post to list its attachments'
        ]
      end
    end
  end
end
