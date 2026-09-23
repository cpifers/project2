# frozen_string_literal: true

require_relative 'base_view'

module UserHub
  module GUI
    class RegisterView < BaseView
      FIELDS = [
        [:username, 'Username', false],
        [:email,    'Email',    false],
        [:password, 'Password', true],
        [:confirm,  'Confirm password', true]
      ].freeze

      def initialize(parent, controller)
        super
        @vars = FIELDS.to_h { |key, _label, _secret| [key, TkVariable.new('')] }
        build_ui
      end

      private

      def build_ui
        card = Tk::Tile::Frame.new(self, padding: 24)
        card.place(relx: 0.5, rely: 0.45, anchor: 'center')

        Tk::Tile::Label.new(card, text: 'Create an account', font: 'Helvetica 20 bold').grid(row: 0, column: 0, columnspan: 2, pady: 12)

        FIELDS.each_with_index do |(key, label, secret), index|
          row = index + 1
          Tk::Tile::Label.new(card, text: label).grid(row: row, column: 0, sticky: 'e', padx: 6, pady: 6)
          options = { textvariable: @vars[key], width: 32 }
          options[:show] = '*' if secret
          Tk::Tile::Entry.new(card, options).grid(row: row, column: 1, pady: 6)
        end

        Tk::Tile::Label.new(card, text: 'Username 3+ characters, valid email, password 6+ characters', foreground: 'gray')
                        .grid(row: 5, column: 0, columnspan: 2, pady: 6)
        Tk::Tile::Button.new(card, text: 'Register', command: proc { attempt_register }).grid(row: 6, column: 0, columnspan: 2, pady: 6)
        Tk::Tile::Button.new(card, text: 'Back to login', command: proc { @controller.show(:login) })
                        .grid(row: 7, column: 0, columnspan: 2)
      end

      def attempt_register
        return error_dialog('Passwords do not match.') if @vars[:password].value != @vars[:confirm].value

        user_manager.register(
          username: @vars[:username].value,
          email:    @vars[:email].value,
          password: @vars[:password].value
        )
        info_dialog('Account created. You can now log in.')
        @controller.show(:login)
      rescue ValidationError => e
        error_dialog(e.message)
      end
    end
  end
end
