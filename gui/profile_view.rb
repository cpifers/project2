# frozen_string_literal: true

require_relative 'base_view'

module UserHub
  module GUI
    # TODO: replace with the real screen.
    class ProfileView < StubView
      private

      def view_title
        'My Profile'
      end

      def back_target
        :user_dashboard
      end

      def todo_items
        [
          'Show and edit username and email (Validator.user, UserManager#email_taken?, then update_user)',
          'Change password (User#change_password, Validator.user with password)',
          'Profile picture: file picker limited to PNG/GIF, copy into data/uploads, show with TkPhotoImage',
          'Show total posts (User#total_posts)'
        ]
      end
    end

    # TODO: replace with the real screen.
    class AddressView < StubView
      private

      def view_title
        'My Address'
      end

      def back_target
        :user_dashboard
      end

      def todo_items
        [
          'Form: street, city, state, zip code (all required: Validator.address)',
          'Save creates or updates current_user.address, then user_manager.save',
          'Show the result of Address#get_full_address'
        ]
      end
    end
  end
end
