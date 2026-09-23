# frozen_string_literal: true

require 'tk'
require 'tkextlib/tile'

module UserHub
  module GUI
    # Every screen is a Frame that the App controller packs into the main
    # window. Views only call UserManager / models and display the results;
    # no business rules live here.
    class BaseView < Tk::Tile::Frame
      def initialize(parent, controller)
        super(parent)
        @controller = controller
      end

      private

      def user_manager
        @controller.user_manager
      end

      def current_user
        @controller.current_user
      end

      # Title bar with an optional Back button and a Log out button.
      def build_header(title, back: nil)
        bar = Tk::Tile::Frame.new(self, padding: 8)
        bar.pack(side: 'top', fill: 'x')
        if back
          Tk::Tile::Button.new(bar, text: '< Back', command: proc { @controller.show(back) }).pack(side: 'left', padx: 8)
        end
        Tk::Tile::Label.new(bar, text: title, font: 'Helvetica 16 bold').pack(side: 'left')
        Tk::Tile::Button.new(bar, text: 'Log out', command: proc { @controller.logout }).pack(side: 'right')
        bar
      end

      # columns: [[id, heading, width], ...]  ->  a Treeview showing only headings.
      # Fill it with: table.insert('', 'end', values: [...])
      def build_table(parent, columns, height: 8)
        table = Tk::Tile::Treeview.new(parent, columns: columns.map(&:first), show: 'headings', height: height)
        columns.each do |id, text, width|
          table.heading_configure(id, text: text)
          table.column_configure(id, width: width)
        end
        table
      end

      def error_dialog(message)
        Tk.messageBox(type: 'ok', icon: 'error', title: 'UserHub', message: message)
      end

      def info_dialog(message)
        Tk.messageBox(type: 'ok', icon: 'info', title: 'UserHub', message: message)
      end

      def confirm?(message)
        Tk.messageBox(type: 'yesno', icon: 'question', title: 'UserHub', message: message) == 'yes'
      end

      def format_date(time)
        time.strftime('%m/%d/%Y')
      end
    end

    # Placeholder screen: shows what still has to be built. Replace each
    # subclass with a real view as you implement it.
    class StubView < BaseView
      def initialize(parent, controller)
        super
        build_header(view_title, back: back_target)
        body = Tk::Tile::Frame.new(self, padding: 20)
        body.pack(fill: 'both', expand: true)
        Tk::Tile::Label.new(body, text: 'Not implemented yet. This screen needs:', font: 'Helvetica 12 bold').pack(anchor: 'w')
        todo_items.each do |item|
          Tk::Tile::Label.new(body, text: "  - #{item}").pack(anchor: 'w', pady: 2)
        end
      end

      private

      def view_title
        'Coming soon'
      end

      def back_target
        nil
      end

      def todo_items
        []
      end
    end
  end
end
