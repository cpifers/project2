# frozen_string_literal: true

require_relative 'base_view'

module UserHub
  module GUI
    class UserDashboardView < BaseView
      def initialize(parent, controller)
        super
        build_header('My Dashboard')
        build_body
      end

      private

      def build_body
        body = Tk::Tile::Frame.new(self, padding: 24)
        body.pack(fill: 'both', expand: true)

        Tk::Tile::Label.new(body, text: "Welcome, #{current_user.username}!", font: 'Helvetica 18 bold').pack(anchor: 'w')
        Tk::Tile::Label.new(body, text: "Total posts: #{current_user.total_posts}", font: 'Helvetica 12').pack(anchor: 'w', pady: 8)

        buttons = Tk::Tile::Frame.new(body)
        buttons.pack(anchor: 'w', pady: 16)
        actions.each_with_index do |(label, handler), index|
          Tk::Tile::Button.new(buttons, text: label, width: 22, command: handler)
                          .grid(row: index / 2, column: index % 2, padx: 6, pady: 6)
        end
      end

      def actions
        [
          ['My Profile',        proc { @controller.show(:profile) }],
          ['My Address',        proc { @controller.show(:address) }],
          ['My Posts',          proc { @controller.show(:post_list) }],
          ['New Post',          proc { open_new_post }],
          ['Delete My Account', proc { delete_account }]
        ]
      end

      def open_new_post
        @controller.selected_post = nil
        @controller.show(:post_form)
      end

      def delete_account
        return unless confirm?('Delete your account, all your posts and their attachments? This cannot be undone.')

        user_manager.delete_user(current_user.user_id)
        @controller.logout
      end
    end
  end
end
