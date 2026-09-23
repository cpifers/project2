# frozen_string_literal: true

require_relative 'base_view'

module UserHub
  module GUI
    # TODO: replace with the real screen.
    class ReportsView < StubView
      private

      def view_title
        'Reports'
      end

      def back_target
        :admin_dashboard
      end

      def todo_items
        [
          'Buttons: Master Report, User Detail Report (pick a user), Post Report',
          'Build with ReportGenerator.new(user_manager, current_user.username)',
          'Display report[:headers] / report[:rows] in a Treeview, with title, date, admin and footer above/below',
          'Export button: Tk.getSaveFile then ReportGenerator#export_csv (HTML/PDF optional)'
        ]
      end
    end
  end
end
