# frozen_string_literal: true

require 'json'
require 'fileutils'

module UserHub
  # Reads and writes the whole application state as one JSON file.
  class Storage
    DEFAULT_PATH = File.expand_path('../data/userhub.json', __dir__)

    attr_reader :path

    def initialize(path = DEFAULT_PATH)
      @path = path
    end

    # Returns a Hash, or nil when nothing has been saved yet.
    def read
      return nil unless File.exist?(@path)

      JSON.parse(File.read(@path))
    end

    # Writes to a temp file first so a crash cannot leave a half-written file.
    def write(data)
      FileUtils.mkdir_p(File.dirname(@path))
      tmp = "#{@path}.tmp"
      File.write(tmp, JSON.pretty_generate(data))
      File.rename(tmp, @path)
    end
  end
end
