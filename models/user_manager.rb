# frozen_string_literal: true

module UserHub
  # Holds every user in a Hash keyed by user_id (spec: Hash for users,
  # Array for posts and attachments) and saves after every change.
  class UserManager
    DEFAULT_ADMIN = { username: 'Eric', email: 'admin@userhub.com', password: 'admin123' }.freeze

    SORT_KEYS = {
      user_id:  ->(u) { u.user_id },
      username: ->(u) { u.username.downcase },
      email:    ->(u) { u.email.downcase },
      posts:    ->(u) { u.total_posts },
      created:  ->(u) { u.created_at }
    }.freeze

    attr_reader :deleted_accounts_count

    def initialize(storage = nil)
      @users = {}
      @deleted_accounts_count = 0
      @storage = storage
      data = @storage&.read
      load_state(data) if data
    end

    # ---- UML operations -------------------------------------------------

    # UML: createUser(user) : Void
    def create_user(user)
      raise DuplicateError, "User id #{user.user_id} already exists." if @users.key?(user.user_id)
      raise DuplicateError, 'Email is already registered.' if email_taken?(user.email)
      raise DuplicateError, 'Username is already taken.' if username_taken?(user.username)

      @users[user.user_id] = user
      save
      nil
    end

    # UML: getUser(userId) : User
    def get_user(user_id)
      @users.fetch(user_id) { raise NotFoundError, "User #{user_id} not found." }
    end

    # UML: updateUser(user) : Void
    def update_user(user)
      get_user(user.user_id)
      @users[user.user_id] = user
      save
      nil
    end

    # UML: deleteUser(userId) : Void  (posts and attachments go with the user)
    def delete_user(user_id)
      @users.delete(user_id) { raise NotFoundError, "User #{user_id} not found." }
      @deleted_accounts_count += 1
      save
      nil
    end

    # UML: getAllUsers() : User[*]   (administrators are excluded by default)
    def get_all_users(sort_by: :user_id, descending: false, include_admins: false)
      users = @users.values
      users = users.reject(&:admin?) unless include_admins
      users = users.sort_by(&SORT_KEYS.fetch(sort_by))
      descending ? users.reverse : users
    end

    # ---- Registration and login ----------------------------------------

    # Validates, checks uniqueness, then calls create_user.
    # Raises ValidationError with every problem found.
    def register(username:, email:, password:, role: :user)
      errors = Validator.user(username: username, email: email, password: password)
      errors << 'Username is already taken.' if username_taken?(username)
      errors << 'Email is already registered.' if email_taken?(email)
      Validator.raise_if_invalid(errors)

      user = User.new(username.strip, email.strip, password, role: role)
      create_user(user)
      user
    end

    # Returns the User when the credentials are right, otherwise nil.
    def authenticate(email, password)
      user = find_by_email(email)
      user if user&.login(email, password)
    end

    def find_by_email(email)
      @users.values.find { |u| u.email.casecmp?(email.to_s.strip) }
    end

    def username_taken?(username, except_id: nil)
      @users.values.any? { |u| u.user_id != except_id && u.username.casecmp?(username.to_s.strip) }
    end

    def email_taken?(email, except_id: nil)
      @users.values.any? { |u| u.user_id != except_id && u.email.casecmp?(email.to_s.strip) }
    end

    def ensure_default_admin
      return if @users.values.any?(&:admin?)

      register(**DEFAULT_ADMIN, role: :admin)
    end

    # ---- Search ---------------------------------------------------------

    # field: :any, :user_id, :username or :email
    def search_users(query, field: :any)
      q = query.to_s.strip.downcase
      return get_all_users if q.empty?

      get_all_users.select do |u|
        case field
        when :user_id  then u.user_id.to_s == q
        when :username then u.username.downcase.include?(q)
        when :email    then u.email.downcase.include?(q)
        else
          u.user_id.to_s == q || u.username.downcase.include?(q) || u.email.downcase.include?(q)
        end
      end
    end

    # Every post as [user, post] pairs.
    def all_posts
      get_all_users.flat_map { |u| u.posts.map { |p| [u, p] } }
    end

    def search_posts(title)
      q = title.to_s.strip.downcase
      all_posts.select { |_user, post| post.title.downcase.include?(q) }
    end

    # Every attachment as [user, post, attachment] triples.
    def all_attachments
      all_posts.flat_map { |u, p| p.attachments.map { |a| [u, p, a] } }
    end

    def search_attachments(file_name)
      q = file_name.to_s.strip.downcase
      all_attachments.select { |_u, _p, a| a.file_name.downcase.include?(q) }
    end

    # ---- Dashboard ------------------------------------------------------

    def stats(recent_count: 5)
      users = get_all_users
      {
        total_users:       users.size,
        total_posts:       users.sum(&:total_posts),
        total_attachments: users.sum(&:total_attachments),
        deleted_accounts:  @deleted_accounts_count,
        recent_users:      users.sort_by(&:created_at).reverse.first(recent_count),
        recent_posts:      all_posts.sort_by { |_u, p| p.created_at }.reverse.first(recent_count)
      }
    end

    # ---- Persistence ----------------------------------------------------

    def save
      @storage&.write(to_h)
    end

    def to_h
      {
        'next_user_id'       => User.next_user_id,
        'next_post_id'       => Post.next_post_id,
        'next_attachment_id' => Attachment.next_attachment_id,
        'deleted_accounts'   => @deleted_accounts_count,
        'users'              => @users.values.map(&:to_h)
      }
    end

    private

    def load_state(data)
      User.next_user_id             = data['next_user_id']
      Post.next_post_id             = data['next_post_id']
      Attachment.next_attachment_id = data['next_attachment_id']
      @deleted_accounts_count       = data['deleted_accounts']
      data['users'].each do |hash|
        user = User.from_h(hash)
        @users[user.user_id] = user
      end
    end
  end
end
