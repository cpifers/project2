# frozen_string_literal: true

require 'time'

module UserHub
  class Attachment
    # UML: nextAttachmentId : Integer <<static>>
    @next_attachment_id = 1

    class << self
      attr_accessor :next_attachment_id

      def allocate_id
        id = @next_attachment_id
        @next_attachment_id += 1
        id
      end
    end

    attr_reader :attachment_id, :uploaded_at
    attr_accessor :file_name, :file_type, :file_size, :file_path

    def initialize(file_name, file_type, file_size, file_path = nil)
      @attachment_id = self.class.allocate_id
      @file_name     = file_name
      @file_type     = file_type
      @file_size     = file_size
      @file_path     = file_path
      @uploaded_at   = Time.now
    end

    def to_h
      {
        'attachment_id' => @attachment_id, 'file_name' => @file_name, 'file_type' => @file_type,
        'file_size' => @file_size, 'file_path' => @file_path, 'uploaded_at' => @uploaded_at.iso8601
      }
    end

    def self.from_h(hash)
      attachment = allocate
      attachment.send(:restore, hash)
      attachment
    end

    private

    def restore(hash)
      @attachment_id = hash['attachment_id']
      @file_name     = hash['file_name']
      @file_type     = hash['file_type']
      @file_size     = hash['file_size']
      @file_path     = hash['file_path']
      @uploaded_at   = Time.parse(hash['uploaded_at'])
    end
  end
end
