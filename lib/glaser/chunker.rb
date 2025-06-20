module Glaser
  class Chunker
    MAX_CHUNK_SIZE = 50_000 # characters
    
    def initialize
      @ignored_patterns = [
        /\.git\//,
        /node_modules\//,
        /vendor\//,
        /\.bundle\//,
        /build\//,
        /dist\//,
        /\.DS_Store/,
        /Thumbs\.db/,
        /\.log$/,
        /\.tmp$/,
        /\.cache\//
      ]
    end

    def chunk_repository(path)
      puts "  📂 Scanning repository structure...".colorize(:blue)
      
      all_files = scan_files(path)
      grouped_files = group_files_by_type(all_files)
      
      chunks = []
      
      grouped_files.each do |file_type, files|
        puts "  📋 Processing #{files.size} #{file_type} files...".colorize(:blue)
        chunks.concat(create_chunks_for_files(files, file_type))
      end
      
      puts "  ✅ Created #{chunks.size} chunks for analysis".colorize(:green)
      chunks
    end

    private

    def scan_files(path)
      files = []
      
      Dir.glob("#{path}/**/*", File::FNM_DOTMATCH).each do |file_path|
        next unless File.file?(file_path)
        next if should_ignore?(file_path)
        
        files << {
          path: file_path,
          relative_path: file_path.sub("#{path}/", ''),
          size: File.size(file_path),
          type: determine_file_type(file_path)
        }
      end
      
      files
    end

    def should_ignore?(file_path)
      @ignored_patterns.any? { |pattern| file_path.match?(pattern) }
    end

    def determine_file_type(file_path)
      ext = File.extname(file_path).downcase
      
      case ext
      when '.rb', '.py', '.js', '.ts', '.java', '.cpp', '.c', '.go', '.rs', '.php'
        'source_code'
      when '.md', '.txt', '.rst', '.adoc'
        'documentation'
      when '.json', '.yml', '.yaml', '.toml', '.xml'
        'configuration'
      when '.gemspec', '.podspec'
        'package_spec'
      when ''
        case File.basename(file_path)
        when 'Gemfile', 'Rakefile', 'Makefile', 'Dockerfile'
          'configuration'
        when 'README', 'LICENSE', 'CHANGELOG'
          'documentation'
        when 'package.json', 'composer.json', 'requirements.txt', 'Pipfile'
          'dependency_manifest'
        else
          'other'
        end
      else
        'other'
      end
    end

    def group_files_by_type(files)
      files.group_by { |file| file[:type] }
    end

    def create_chunks_for_files(files, file_type)
      chunks = []
      current_chunk = {
        type: file_type,
        files: [],
        total_size: 0,
        id: "#{file_type}_#{chunks.size + 1}"
      }

      files.each do |file|
        # If adding this file would exceed the chunk size, finalize current chunk
        if current_chunk[:total_size] + file[:size] > MAX_CHUNK_SIZE && !current_chunk[:files].empty?
          chunks << current_chunk
          current_chunk = {
            type: file_type,
            files: [],
            total_size: 0,
            id: "#{file_type}_#{chunks.size + 1}"
          }
        end

        current_chunk[:files] << file
        current_chunk[:total_size] += file[:size]
      end

      # Add the final chunk if it has files
      chunks << current_chunk unless current_chunk[:files].empty?
      
      chunks
    end
  end
end