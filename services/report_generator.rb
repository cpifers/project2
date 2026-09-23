# frozen_string_literal: true

require 'csv'

module UserHub
  # Builds the three administrator reports as plain Hashes so the GUI, CSV
  # export and any future HTML/PDF export all use the same data.
  #
  # Report shape:
  #   { title:, date:, admin:, details: [[label, value], ...],
  #     headers: [...], rows: [[...], ...], footer: 'text' }
  class ReportGenerator
    DATE_FORMAT   = '%m/%d/%Y'
    REPORT_HEADER = '%A, %B %-d, %Y'

    def initialize(user_manager, admin_name)
      @manager    = user_manager
      @admin_name = admin_name
    end

    def master_report
      users = @manager.get_all_users
      rows = users.map do |u|
        [u.user_id, u.username, u.email, u.address ? u.address.get_full_address : '-', u.total_posts]
      end
      {
        title:   'Master Report',
        date:    today,
        admin:   @admin_name,
        details: [],
        headers: ['User ID', 'Username', 'Email', 'Address', 'Number of Posts'],
        rows:    rows,
        footer:  "Summary of all registered users (#{users.size})"
      }
    end

    def user_detail_report(user_id)
      user = @manager.get_user(user_id)
      address = user.address
      {
        title:   'User Detail Report',
        date:    today,
        admin:   @admin_name,
        details: [
          ['User ID', user.user_id], ['Username', user.username], ['Email', user.email],
          ['Street', address&.street || '-'], ['City', address&.city || '-'], ['State', address&.state || '-']
        ],
        headers: ['Post ID', 'Title', 'Created Date', 'Updated Date'],
        rows:    user.posts.map { |p| [p.post_id, p.title, fmt(p.created_at), fmt(p.updated_at)] },
        footer:  "Number of Posts: #{user.total_posts}"
      }
    end

    # Pass a user_id to limit the report to one user; nil covers every user.
    def post_report(user_id = nil)
      posts = user_id ? @manager.get_user(user_id).posts : @manager.all_posts.map(&:last)
      rows = posts.map do |p|
        names = p.attachments.map(&:file_name)
        [p.post_id, p.title, fmt(p.created_at), fmt(p.updated_at), names.empty? ? '-' : names.join(', '), names.size]
      end
      {
        title:   'Post Report',
        date:    today,
        admin:   @admin_name,
        details: [],
        headers: ['Post ID', 'Title', 'Created Date', 'Updated Date', 'Attachments', '#'],
        rows:    rows,
        footer:  "Total Number of Attachments: #{posts.sum { |p| p.attachments.size }}"
      }
    end

    def export_csv(report, path)
      CSV.open(path, 'w') do |csv|
        csv << [report[:title]]
        csv << ['Date', report[:date], 'Admin', report[:admin]]
        report[:details].each { |label, value| csv << [label, value] }
        csv << report[:headers]
        report[:rows].each { |row| csv << row }
        csv << [report[:footer]] if report[:footer]
      end
      path
    end

    # TODO: export_html(report, path)  -> ERB template, easy
    # TODO: export_pdf(report, path)   -> prawn + prawn-table, only if time allows

    private

    def today
      Time.now.strftime(REPORT_HEADER)
    end

    def fmt(time)
      time.strftime(DATE_FORMAT)
    end
  end
end
