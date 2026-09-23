# frozen_string_literal: true

# Run with:  ruby test/models_test.rb
# Needs no display: only the model and service layers are loaded.

require 'minitest/autorun'
require 'tmpdir'
require_relative '../userhub'

class ModelsTest < Minitest::Test
  include UserHub

  def setup
    reset_counters
    @dir     = Dir.mktmpdir
    @storage = Storage.new(File.join(@dir, 'test.json'))
    @manager = UserManager.new(@storage)
  end

  def teardown
    FileUtils.remove_entry(@dir)
  end

  def reset_counters
    User.next_user_id = 1
    Post.next_post_id = 1
    Attachment.next_attachment_id = 1
  end

  def register(name = 'john_smith', email = 'john@email.com')
    @manager.register(username: name, email: email, password: 'secret1')
  end

  def test_password_is_hashed_and_verifiable
    user = register
    refute_includes user.password_digest, 'secret1'
    assert user.login('john@email.com', 'secret1')
    refute user.login('john@email.com', 'wrong')
  end

  def test_registration_validation_reports_every_error
    error = assert_raises(ValidationError) { @manager.register(username: 'ab', email: 'nope', password: '123') }
    assert_equal 3, error.errors.size
  end

  def test_duplicate_email_and_username_are_rejected
    register
    assert_raises(ValidationError) { register('other_name', 'JOHN@email.com') }
    assert_raises(ValidationError) { register('John_Smith', 'other@email.com') }
  end

  def test_static_ids_increment
    a = register('user_one', 'one@email.com')
    b = register('user_two', 'two@email.com')
    assert_equal a.user_id + 1, b.user_id
  end

  def test_authenticate
    user = register
    assert_equal user, @manager.authenticate('john@email.com', 'secret1')
    assert_nil @manager.authenticate('john@email.com', 'bad')
    assert_nil @manager.authenticate('missing@email.com', 'secret1')
  end

  def test_post_crud_and_attachment_limit
    user = register
    post = Post.new('My First Ruby Project', 'Hello')
    user.create_post(post)
    assert_equal 1, user.total_posts

    5.times { |i| post.add_attachment(Attachment.new("file#{i}.zip", 'zip', 100)) }
    assert_raises(LimitError) { post.add_attachment(Attachment.new('extra.zip', 'zip', 100)) }

    post.remove_attachment(post.attachments.first.attachment_id)
    assert_equal 4, post.attachments.size

    user.delete_post(post.post_id)
    assert_equal 0, user.total_posts
  end

  def test_deleting_a_user_counts_deleted_accounts
    user = register
    @manager.delete_user(user.user_id)
    assert_equal 1, @manager.deleted_accounts_count
    assert_raises(NotFoundError) { @manager.get_user(user.user_id) }
  end

  def test_persistence_round_trip_restores_data_and_counters
    user = register
    post = Post.new('Title', 'Body')
    post.add_attachment(Attachment.new('a.png', 'png', 10))
    user.create_post(post)
    user.address = Address.new('123 Main St', 'Columbus', 'Ohio', '43004')
    @manager.update_user(user)
    @manager.delete_user(register('temp_user', 'temp@email.com').user_id)

    reset_counters
    reloaded = UserManager.new(@storage)
    loaded   = reloaded.get_user(user.user_id)

    assert_equal 'Title', loaded.posts.first.title
    assert_equal 'a.png', loaded.posts.first.attachments.first.file_name
    assert_equal '123 Main St, Columbus, Ohio 43004', loaded.address.get_full_address
    assert_equal 1, reloaded.deleted_accounts_count
    assert_equal 3, User.next_user_id
  end

  def test_search
    user = register
    post = Post.new('Learning OOP Concepts', 'Body')
    post.add_attachment(Attachment.new('Database_Design.pdf', 'pdf', 5))
    user.create_post(post)

    assert_equal [user], @manager.search_users('john')
    assert_equal [user], @manager.search_users(user.user_id.to_s, field: :user_id)
    assert_equal [user], @manager.search_users('john@', field: :email)
    assert_equal 1, @manager.search_posts('oop').size
    assert_equal 1, @manager.search_attachments('design').size
  end

  def test_admin_is_hidden_from_user_lists
    @manager.ensure_default_admin
    register
    assert_equal 1, @manager.get_all_users.size
    assert_equal 2, @manager.get_all_users(include_admins: true).size
  end

  def test_reports
    user = register
    post = Post.new('Database Design Notes', 'Body')
    post.add_attachment(Attachment.new('Database_Design.pdf', 'pdf', 5))
    user.create_post(post)

    reports = ReportGenerator.new(@manager, 'Eric')
    assert_equal 1, reports.master_report[:rows].size
    assert_equal 'Number of Posts: 1', reports.user_detail_report(user.user_id)[:footer]
    assert_equal 'Total Number of Attachments: 1', reports.post_report[:footer]

    path = reports.export_csv(reports.master_report, File.join(@dir, 'master.csv'))
    assert File.exist?(path)
  end

  def test_validator_rules
    assert_empty Validator.address(street: 'a', city: 'b', state: 'c', zip_code: 'd')
    assert_equal 4, Validator.address(street: '', city: ' ', state: nil, zip_code: '').size
    assert_equal 2, Validator.post(title: '', content: '').size
    assert_equal 3, Validator.attachment(file_name: '', file_type: '', file_size: 0).size
  end
end
