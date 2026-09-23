# frozen_string_literal: true

require 'tk'
require 'tkextlib/tile'
require_relative '../userhub'

require_relative 'base_view'
require_relative 'login_view'
require_relative 'register_view'
require_relative 'user_dashboard'
require_relative 'admin_dashboard'
require_relative 'profile_view'
require_relative 'post_views'
require_relative 'admin_views'
require_relative 'reports_view'

module UserHub
  module GUI
    # Owns the main window, the UserManager and the logged-in user, and
    # switches between screens (one Frame at a time).
    class App
      VIEWS = {
        login:            LoginView,
        register:         RegisterView,
        user_dashboard:   UserDashboardView,
        admin_dashboard:  AdminDashboardView,
        profile:          ProfileView,
        address:          AddressView,
        post_list:        PostListView,
        post_form:        PostFormView,
        attachment_list:  AttachmentListView,
        user_management:  UserManagementView,
        all_posts:        AllPostsView,
        reports:          ReportsView
      }.freeze

      attr_reader :user_manager
      # selected_user / selected_post let one screen pass an item to the next
      # (e.g. the post list opens the post form for the chosen post).
      attr_accessor :current_user, :selected_user, :selected_post

      def initialize
        @user_manager = UserManager.new(Storage.new)
        @user_manager.ensure_default_admin
        build_window
        show(:login)
      end

      def run
        Tk.mainloop
      end

      def show(view_name)
        @current_view&.destroy
        @current_view = VIEWS.fetch(view_name).new(@container, self)
        @current_view.pack(fill: 'both', expand: true)
      end

      def login_success(user)
        @current_user = user
        show(user.admin? ? :admin_dashboard : :user_dashboard)
      end

      def logout
        @current_user&.logout
        @current_user = nil
        @selected_user = nil
        @selected_post = nil
        show(:login)
      end

      private

      def build_window
        @root = TkRoot.new
        @root.title('UserHub')
        @root.geometry('960x640')
        @root.minsize(800, 560)
        begin
          Tk::Tile::Style.theme_use('clam')
        rescue StandardError
          nil # keep the platform default theme
        end
        @container = Tk::Tile::Frame.new(@root)
        @container.pack(fill: 'both', expand: true)
      end
    end
  end
end
