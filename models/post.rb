# frozen_string_literal: true

require 'time'

module UserHub
  class Post
    MAX_ATTACHMENTS = 5

    # UML: nextPostId : Integer <<static>>
    @next_post_id = 1

    class << self
      attr_accessor :next_post_id

      def allocate_id
        id = @next_post_id
        @next_post_id += 1
        id
      end
    end

    attr_reader :post_id, :created_at, :updated_at, :attachments
    attr_accessor :title, :content

    def initialize(title, content)
      @post_id     = self.class.allocate_id
      @title       = title
      @content     = content
      @created_at  = Time.now
      @updated_at  = @created_at
      @attachments = [] # composition: a Post owns 0..5 Attachments
    end

    def edit(title, content)
      @title   = title
      @content = content
      touch
    end

    def add_attachment(attachment)
      raise LimitError, "A post can have at most #{MAX_ATTACHMENTS} attachments." if @attachments.size >= MAX_ATTACHMENTS

      @attachments << attachment
      touch
    end

    def remove_attachment(attachment_id)
      removed = @attachments.reject! { |a| a.attachment_id == attachment_id }
      raise NotFoundError, "Attachment #{attachment_id} not found." if removed.nil?

      touch
    end

    def find_attachment(attachment_id)
      @attachments.find { |a| a.attachment_id == attachment_id }
    end

    def to_h
      {
        'post_id' => @post_id, 'title' => @title, 'content' => @content,
        'created_at' => @created_at.iso8601, 'updated_at' => @updated_at.iso8601,
        'attachments' => @attachments.map(&:to_h)
      }
    end

    def self.from_h(hash)
      post = allocate
      post.send(:restore, hash)
      post
    end

    private

    def touch
      @updated_at = Time.now
    end

    def restore(hash)
      @post_id     = hash['post_id']
      @title       = hash['title']
      @content     = hash['content']
      @created_at  = Time.parse(hash['created_at'])
      @updated_at  = Time.parse(hash['updated_at'])
      @attachments = hash['attachments'].map { |a| Attachment.from_h(a) }
    end
  end
end
