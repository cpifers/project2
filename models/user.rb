# frozen_string_literal: true

require 'time'

module UserHub
  class User
    ROLES = %i[user admin].freeze

    # UML: nextUserId : Integer <<static>>
    @next_user_id = 1

    class << self
      attr_accessor :next_user_id

      def allocate_id
        id = @next_user_id
        @next_user_id += 1
        id
      end
    end

    attr_reader :user_id, :role, :password_digest, :created_at, :posts
    attr_accessor :username, :email, :address, :profile_picture

    # UML: User(username, email, password)
    # The password is hashed immediately; only the digest is kept.
    def initialize(username, email, password, role: :user)
      raise ArgumentError, "Unknown role: #{role}" unless ROLES.include?(role)

      @user_id         = self.class.allocate_id
      @username        = username
      @email           = email
      @password_digest = PasswordHasher.digest(password)
      @role            = role
      @posts           = [] # composition: a User owns 0..* Posts
      @address         = nil # association: 0..1 Address
      @profile_picture = nil # path to an image file
      @created_at      = Time.now
      @logged_in       = false
    end

    def admin?
      @role == :admin
    end

    def logged_in?
      @logged_in
    end

    # UML: login(email, password) : Boolean
    def login(email, password)
      matches = @email.to_s.casecmp?(email.to_s.strip) && PasswordHasher.verify(password, @password_digest)
      @logged_in = matches
    end

    # UML: logout() : Void
    def logout
      @logged_in = false
      nil
    end

    def change_password(new_password)
      @password_digest = PasswordHasher.digest(new_password)
    end

    # UML: createPost(post) : Void
    def create_post(post)
      @posts << post
      nil
    end

    # UML: updatePost(post) : Void  (replaces the stored post that has the same id)
    def update_post(post)
      index = @posts.index { |p| p.post_id == post.post_id }
      raise NotFoundError, "Post #{post.post_id} not found." if index.nil?

      @posts[index] = post
      nil
    end

    # UML: deletePost(postId) : Void  (its attachments go with it)
    def delete_post(post_id)
      removed = @posts.reject! { |p| p.post_id == post_id }
      raise NotFoundError, "Post #{post_id} not found." if removed.nil?

      nil
    end

    def find_post(post_id)
      @posts.find { |p| p.post_id == post_id }
    end

    def total_posts
      @posts.size
    end

    def total_attachments
      @posts.sum { |p| p.attachments.size }
    end

    def to_h
      {
        'user_id' => @user_id, 'username' => @username, 'email' => @email,
        'password_digest' => @password_digest, 'role' => @role.to_s,
        'profile_picture' => @profile_picture, 'created_at' => @created_at.iso8601,
        'address' => @address&.to_h, 'posts' => @posts.map(&:to_h)
      }
    end

    def self.from_h(hash)
      user = allocate
      user.send(:restore, hash)
      user
    end

    private

    def restore(hash)
      @user_id         = hash['user_id']
      @username        = hash['username']
      @email           = hash['email']
      @password_digest = hash['password_digest']
      @role            = hash['role'].to_sym
      @profile_picture = hash['profile_picture']
      @created_at      = Time.parse(hash['created_at'])
      @address         = hash['address'] && Address.from_h(hash['address'])
      @posts           = hash['posts'].map { |p| Post.from_h(p) }
      @logged_in       = false
    end
  end
end
