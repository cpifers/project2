# frozen_string_literal: true

require_relative 'base_view'

module UserHub
  module GUI
    class AdminDashboardView < BaseView
      def initialize(parent, controller)
        super
        build_header('Administrator Dashboard')
        stats = user_manager.stats
        body = Tk::Tile::Frame.new(self, padding: 16)
        body.pack(fill: 'both', expand: true)
        build_cards(body, stats)
        build_actions(body)
        build_recent(body, stats)
      end

      private

      def build_cards(parent, stats)
        row = Tk::Tile::Frame.new(parent)
        row.pack(fill: 'x')
        [
          ['Total Users',            stats[:total_users]],
          ['Total Posts',            stats[:total_posts]],
          ['Total Attachments',      stats[:total_attachments]],
          ['Total Deleted Accounts', stats[:deleted_accounts]]
        ].each do |label, value|
          card = Tk::Tile::Frame.new(row, padding: 12, relief: 'groove', borderwidth: 2)
          card.pack(side: 'left', expand: true, fill: 'x', padx: 4)
          Tk::Tile::Label.new(card, text: value.to_s, font: 'Helvetica 24 bold').pack
          Tk::Tile::Label.new(card, text: label).pack
        end
      end

      def build_actions(parent)
        row = Tk::Tile::Frame.new(parent)
        row.pack(fill: 'x', pady: 12)
        [
          ['Manage Users',  :user_management],
          ['Search Users',  :user_management],
          ['View All Posts', :all_posts],
          ['Reports',       :reports]
        ].each do |label, target|
          Tk::Tile::Button.new(row, text: label, command: proc { @controller.show(target) }).pack(side: 'left', padx: 4)
        end
      end

      def build_recent(parent, stats)
        wrap = Tk::Tile::Frame.new(parent)
        wrap.pack(fill: 'both', expand: true)

        users_table = recent_table(
          wrap, 'Recently Registered Users',
          [['id', 'ID', 40], ['username', 'Username', 120], ['email', 'Email', 180], ['date', 'Registered', 90]]
        )
        stats[:recent_users].each do |u|
          users_table.insert('', 'end', values: [u.user_id, u.username, u.email, format_date(u.created_at)])
        end

        posts_table = recent_table(
          wrap, 'Recently Created Posts',
          [['id', 'ID', 40], ['title', 'Title', 170], ['author', 'Author', 110], ['date', 'Created', 90]]
        )
        stats[:recent_posts].each do |user, post|
          posts_table.insert('', 'end', values: [post.post_id, post.title, user.username, format_date(post.created_at)])
        end
      end

      def recent_table(parent, title, columns)
        box = Tk::Tile::Frame.new(parent)
        box.pack(side: 'left', fill: 'both', expand: true, padx: 4)
        Tk::Tile::Label.new(box, text: title, font: 'Helvetica 12 bold').pack(anchor: 'w', pady: 4)
        table = build_table(box, columns, height: 6)
        table.pack(fill: 'both', expand: true)
        table
      end
    end
  end
end
