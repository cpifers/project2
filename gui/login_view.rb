# frozen_string_literal: true

require_relative 'base_view'

module UserHub
  module GUI
    class LoginView < BaseView
      def initialize(parent, controller)
        super
        @email    = TkVariable.new('')
        @password = TkVariable.new('')
        @error    = TkVariable.new('')
        build_ui
      end

      private

      def build_ui
        card = Tk::Tile::Frame.new(self, padding: 24)
        card.place(relx: 0.5, rely: 0.45, anchor: 'center')

        Tk::Tile::Label.new(card, text: 'UserHub', font: 'Helvetica 24 bold').grid(row: 0, column: 0, columnspan: 2, pady: 4)
        Tk::Tile::Label.new(card, text: 'Log in to continue').grid(row: 1, column: 0, columnspan: 2, pady: 8)

        Tk::Tile::Label.new(card, text: 'Email').grid(row: 2, column: 0, sticky: 'e', padx: 6, pady: 6)
        email_entry = Tk::Tile::Entry.new(card, textvariable: @email, width: 32)
        email_entry.grid(row: 2, column: 1, pady: 6)

        Tk::Tile::Label.new(card, text: 'Password').grid(row: 3, column: 0, sticky: 'e', padx: 6, pady: 6)
        password_entry = Tk::Tile::Entry.new(card, textvariable: @password, width: 32, show: '*')
        password_entry.grid(row: 3, column: 1, pady: 6)

        Tk::Tile::Label.new(card, textvariable: @error, foreground: 'red').grid(row: 4, column: 0, columnspan: 2)

        Tk::Tile::Button.new(card, text: 'Log in', command: proc { attempt_login }).grid(row: 5, column: 0, columnspan: 2, pady: 6)
        Tk::Tile::Button.new(card, text: 'Create an account', command: proc { @controller.show(:register) })
                        .grid(row: 6, column: 0, columnspan: 2)

        Tk::Tile::Label.new(card, text: 'First-run admin: admin@userhub.com / admin123', foreground: 'gray')
                        .grid(row: 7, column: 0, columnspan: 2, pady: 12)

        email_entry.bind('Return') { attempt_login }
        password_entry.bind('Return') { attempt_login }
        email_entry.focus
      end

      def attempt_login
        user = user_manager.authenticate(@email.value, @password.value)
        if user
          @controller.login_success(user)
        else
          @error.value = 'Invalid email or password.'
          @password.value = ''
        end
      end
    end
  end
end
