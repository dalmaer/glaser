require 'roast'
require 'json'
require_relative 'github_handler'
require_relative 'chunker'

module Glaser
  class Analyzer
    def initialize(target:, serious_mode: false, output_file: nil)
      @target = target
      @serious_mode = serious_mode
      @output_file = output_file || generate_timestamped_filename
      @github_handler = GitHubHandler.new
      @chunker = Chunker.new
    end

    def analyze
      puts "🔍 Analyzing target: #{@target}".colorize(:yellow)
      
      # Determine if target is local path or GitHub URL
      local_path = if github_url?(@target)
        puts "📥 Cloning GitHub repository...".colorize(:cyan)
        @github_handler.clone_repo(@target)
      else
        validate_local_path!(@target)
        @target
      end

      puts "🧠 Chunking codebase for analysis...".colorize(:blue)
      chunks = @chunker.chunk_repository(local_path)
      
      puts "🔥 Starting multi-agent roast analysis...".colorize(:red)
      
      # Run Roast workflows for each agent type
      results = run_analysis_workflows(local_path, chunks)
      
      puts "📝 Generating report...".colorize(:green)
      generate_report(results)
      
      puts "✅ Analysis complete! Report saved to #{@output_file}".colorize(:green)
      puts ""
      display_colorized_report
    end

    private

    def github_url?(target)
      target.match?(/^https?:\/\/github\.com\//)
    end

    def validate_local_path!(path)
      unless File.exist?(path)
        raise Error, "Path does not exist: #{path}"
      end
      
      unless File.directory?(path)
        raise Error, "Path is not a directory: #{path}"
      end
    end

    def run_analysis_workflows(path, chunks)
      workflows = %w[documentation code_quality dependency bug_hunter nitpicker]
      results = {}

      workflows.each do |workflow_name|
        puts "  🔥 Running #{workflow_name} agent...".colorize(:magenta)
        
        workflow_path = File.join(__dir__, '../../workflows', "#{workflow_name}.yml")
        
        if File.exist?(workflow_path)
          begin
            # This will be implemented once we create the workflow files
            results[workflow_name] = execute_roast_workflow(workflow_path, path, chunks)
          rescue StandardError => e
            puts "  ⚠️  #{workflow_name} agent failed: #{e.message}".colorize(:yellow)
            results[workflow_name] = { error: e.message }
          end
        else
          puts "  ⚠️  Workflow not found: #{workflow_path}".colorize(:yellow)
          results[workflow_name] = { error: "Workflow file not found" }
        end
      end

      results
    end

    def execute_roast_workflow(workflow_path, target_path, chunks)
      # For now, implement a basic mock analysis based on the workflow type
      # This is a temporary solution until proper roast integration is working
      
      workflow_name = File.basename(workflow_path, '.yml')
      
      begin
        result = case workflow_name
        when 'documentation'
          analyze_documentation(target_path, chunks)
        when 'code_quality'
          analyze_code_quality(target_path, chunks)
        when 'dependency'
          analyze_dependencies(target_path, chunks)
        when 'bug_hunter'
          analyze_bugs(target_path, chunks)
        when 'nitpicker'
          analyze_nitpicks(target_path, chunks)
        else
          "Unknown workflow type: #{workflow_name}"
        end
        
        {
          status: 'completed',
          result: result,
          workflow: workflow_path,
          target: target_path,
          chunks_count: chunks.size
        }
      rescue => e
        {
          status: 'error',
          error: e.message,
          workflow: workflow_path,
          target: target_path,
          chunks_count: chunks.size
        }
      end
    end

    private

    def analyze_documentation(target_path, chunks)
      # Comprehensive documentation analysis
      doc_chunks = chunks.select { |chunk| chunk[:type] == 'documentation' }
      readme_files = Dir.glob(File.join(target_path, '**/README*'), File::FNM_CASEFOLD)
      
      roast_lines = []
      roast_lines << "## 📚 Documentation Roast"
      roast_lines << ""
      
      if readme_files.empty?
        roast_lines << "🔥 **Missing README**: This project is like a mystery novel with no cover - nobody knows what it does! Add a README.md already."
        roast_lines << ""
        roast_lines << "### 📝 Final Documentation Grade: F"
        roast_lines << "Your documentation is more missing than my motivation on Monday mornings."
        return roast_lines.join("\n")
      end
      
      # Analyze the main README
      readme_content = File.read(readme_files.first) rescue ""
      readme_lines = readme_content.split("\n")
      
      # Basic README analysis
      roast_lines.concat(analyze_readme_basics(readme_content, readme_lines))
      roast_lines << ""
      
      # Content quality analysis
      roast_lines.concat(analyze_readme_content(readme_content, readme_lines))
      roast_lines << ""
      
      # Structure and completeness
      roast_lines.concat(analyze_readme_structure(readme_content, target_path))
      roast_lines << ""
      
      # Documentation ecosystem
      roast_lines.concat(analyze_doc_ecosystem(target_path, doc_chunks))
      roast_lines << ""
      
      # Final grade and roast
      roast_lines.concat(generate_documentation_grade(readme_content, target_path))
      
      roast_lines.join("\n")
    end

    def analyze_readme_basics(content, lines)
      roast_lines = []
      roast_lines << "### 📄 README Basics"
      
      # Length analysis
      if content.length < 100
        roast_lines << "🔥 **Micro README**: Your README is shorter than a grocery list. Are you documenting a single function?"
      elsif content.length < 500
        roast_lines << "🔥 **Tweet-sized README**: This README needs more substance than a reality TV show plotline."
      elsif content.length > 10000
        roast_lines << "🔥 **README Novel**: This README is longer than some people's attention spans. Consider breaking it up!"
      else
        roast_lines << "✅ **Decent Length**: Your README has a reasonable length. Not too short, not a novel."
      end
      
      # Title analysis
      first_line = lines.first&.strip || ""
      if first_line.empty?
        roast_lines << "🔥 **Missing Title**: Your README starts with nothing. Even a haiku has a first line!"
      elsif !first_line.start_with?('#')
        roast_lines << "🔥 **No Markdown Title**: Your README title isn't using markdown headers. This isn't a text file from 1995!"
      elsif first_line.length < 5
        roast_lines << "🔥 **Lazy Title**: '#{first_line}' - Really? That's the best you could come up with?"
      end
      
      # Emoji analysis
      emoji_count = content.scan(/[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]/).size
      if emoji_count > 20
        roast_lines << "🔥 **Emoji Overload**: #{emoji_count} emojis? This README looks like a teenager's text message!"
      elsif emoji_count == 0
        roast_lines << "🔥 **Emoji Desert**: Zero emojis? Add some visual flair - this isn't a legal document!"
      end
      
      roast_lines
    end

    def analyze_readme_content(content, lines)
      roast_lines = []
      roast_lines << "### 📝 Content Quality"
      
      # Check for essential sections
      has_description = content.match?(/(?:description|about|what|overview)/i)
      has_installation = content.match?(/(?:install|setup|getting started|quick start)/i)
      has_usage = content.match?(/(?:usage|example|how to|tutorial)/i)
      has_api = content.match?(/(?:api|reference|documentation)/i)
      has_contributing = content.match?(/(?:contribut|development|build)/i)
      has_license = content.match?(/(?:license|copyright|mit|apache)/i)
      
      missing_sections = []
      missing_sections << "description" unless has_description
      missing_sections << "installation" unless has_installation
      missing_sections << "usage examples" unless has_usage
      missing_sections << "contribution guidelines" unless has_contributing
      missing_sections << "license info" unless has_license
      
      if missing_sections.any?
        roast_lines << "🔥 **Missing Essentials**: No #{missing_sections.join(', ')}? This README is more incomplete than my dating profile!"
      else
        roast_lines << "✅ **Complete Structure**: You've got all the essential sections. Finally, someone who reads the manual!"
      end
      
      # Check for common problems
      if content.include?('TODO')
        todo_count = content.scan(/TODO/i).size
        roast_lines << "🔥 **TODO Paradise**: #{todo_count} TODOs in your README? Finish writing it before publishing!"
      end
      
      if content.include?('Lorem ipsum')
        roast_lines << "🔥 **Lorem Ipsum Detected**: Really? Placeholder text in your README? That's lazier than my weekend plans!"
      end
      
      # Check for broken/placeholder content
      placeholder_patterns = [
        /your-repo-name/i,
        /replace-with/i,
        /change-this/i,
        /example\.com/,
        /username\/repo/
      ]
      
      placeholder_patterns.each do |pattern|
        if content.match?(pattern)
          roast_lines << "🔥 **Placeholder Content**: Found placeholder text - this README is more template than documentation!"
          break
        end
      end
      
      roast_lines
    end

    def analyze_readme_structure(content, target_path)
      roast_lines = []
      roast_lines << "### 🏗️ Structure & Links"
      
      # Check for code blocks
      code_blocks = content.scan(/```[\s\S]*?```/).size
      if code_blocks == 0
        roast_lines << "🔥 **No Code Examples**: A README without code examples is like a cooking show without food!"
      elsif code_blocks > 20
        roast_lines << "🔥 **Code Block Overload**: #{code_blocks} code blocks? This README is more code than text!"
      else
        roast_lines << "✅ **Good Examples**: #{code_blocks} code blocks - nice balance of explanation and examples."
      end
      
      # Check for links
      markdown_links = content.scan(/\[([^\]]*)\]\(([^)]*)\)/).size
      if markdown_links == 0
        roast_lines << "🔥 **Link Desert**: No links? This README is more isolated than a deserted island!"
      end
      
      # Check for images/badges
      images = content.scan(/!\[([^\]]*)\]\(([^)]*)\)/).size
      if images == 0
        roast_lines << "🔥 **Image-Free Zone**: No images or badges? Add some visual appeal - this isn't a terms of service!"
      end
      
      # Check for table of contents
      has_toc = content.match?(/(?:table of contents|toc|contents)/i)
      if content.length > 3000 && !has_toc
        roast_lines << "🔥 **Missing TOC**: This README is long enough to need a table of contents. Help your readers navigate!"
      end
      
      roast_lines
    end

    def analyze_doc_ecosystem(target_path, doc_chunks)
      roast_lines = []
      roast_lines << "### 🌍 Documentation Ecosystem"
      
      # Check for docs folder
      docs_folder = File.exist?(File.join(target_path, 'docs'))
      if docs_folder
        roast_lines << "✅ **Docs Folder**: You have a docs/ folder. Someone actually cares about documentation!"
      else
        roast_lines << "🔥 **No Docs Folder**: No dedicated docs folder? Everything crammed in the README like a studio apartment!"
      end
      
      # Check for changelog
      changelog_files = Dir.glob(File.join(target_path, '**/CHANGELOG*'), File::FNM_CASEFOLD)
      if changelog_files.empty?
        roast_lines << "🔥 **Missing Changelog**: No CHANGELOG? How do users know what changed besides playing detective?"
      else
        roast_lines << "✅ **Changelog Present**: You maintain a changelog. Responsible AND organized!"
      end
      
      # Check for contributing guidelines
      contributing_files = Dir.glob(File.join(target_path, '**/CONTRIBUTING*'), File::FNM_CASEFOLD)
      if contributing_files.empty?
        roast_lines << "🔥 **No Contributing Guide**: No CONTRIBUTING.md? Good luck getting quality contributions!"
      else
        roast_lines << "✅ **Contributing Guide**: You welcome contributors with proper guidelines. How civilized!"
      end
      
      # Check for license
      license_files = Dir.glob(File.join(target_path, '**/LICENSE*'), File::FNM_CASEFOLD)
      if license_files.empty?
        roast_lines << "🔥 **License MIA**: No LICENSE file? This code is in legal limbo!"
      else
        roast_lines << "✅ **Licensed**: You have a license file. Legally responsible!"
      end
      
      roast_lines << ""
      roast_lines << "📊 **Documentation Stats**:"
      roast_lines << "- Documentation files: #{doc_chunks.sum { |chunk| chunk[:files].size }}"
      roast_lines << "- Has docs folder: #{docs_folder ? 'Yes' : 'No'}"
      roast_lines << "- Has changelog: #{changelog_files.any? ? 'Yes' : 'No'}"
      roast_lines << "- Has contributing guide: #{contributing_files.any? ? 'Yes' : 'No'}"
      roast_lines << "- Has license: #{license_files.any? ? 'Yes' : 'No'}"
      
      roast_lines
    end

    def generate_documentation_grade(readme_content, target_path)
      roast_lines = []
      
      # Scoring system
      score = 0
      
      # README quality (40 points)
      score += 10 if readme_content.length > 500
      score += 10 if readme_content.match?(/(?:install|setup)/i)
      score += 10 if readme_content.match?(/(?:usage|example)/i)
      score += 10 if readme_content.scan(/```[\s\S]*?```/).size > 0
      
      # Structure (30 points)
      score += 10 if readme_content.match?(/(?:description|about)/i)
      score += 10 if readme_content.match?(/(?:contribut|development)/i)
      score += 10 if readme_content.match?(/(?:license|copyright)/i)
      
      # Ecosystem (30 points)
      score += 10 if File.exist?(File.join(target_path, 'docs'))
      score += 10 if Dir.glob(File.join(target_path, '**/CHANGELOG*'), File::FNM_CASEFOLD).any?
      score += 10 if Dir.glob(File.join(target_path, '**/LICENSE*'), File::FNM_CASEFOLD).any?
      
      # Grade calculation
      grade = case score
      when 90..100 then "A+"
      when 80..89 then "A"
      when 70..79 then "B"
      when 60..69 then "C"
      when 50..59 then "D"
      else "F"
      end
      
      roast_lines << "### 📝 Final Documentation Grade: #{grade}"
      
      final_roast = case grade
      when "A+", "A"
        "Your documentation is cleaner than my comedy material - and that's saying something!"
      when "B"
        "Decent documentation, but there's room for improvement - like my dating life."
      when "C"
        "Your docs are more average than a Netflix algorithm recommendation."
      when "D"
        "This documentation needs more work than my family relationships."
      when "F"
        "Your documentation is more scattered than my thoughts during a live performance."
      end
      
      roast_lines << final_roast
      roast_lines
    end

    def analyze_code_quality(target_path, chunks)
      # Basic code quality analysis
      code_files = chunks.select { |chunk| chunk[:type] == 'source_code' }
      
      roast_lines = []
      roast_lines << "## 🧱 Code Quality Roast"
      roast_lines << ""
      
      # Check for common code smells
      js_files = Dir.glob(File.join(target_path, '**/*.{js,ts,jsx,tsx}'))
      py_files = Dir.glob(File.join(target_path, '**/*.py'))
      
      total_files = js_files.size + py_files.size
      
      if total_files == 0
        roast_lines << "🔥 **No Code Found**: Is this a documentation-only project? Where's the actual code?"
      else
        roast_lines << "📊 **Code Quality Stats**:"
        roast_lines << "- JavaScript/TypeScript files: #{js_files.size}"
        roast_lines << "- Python files: #{py_files.size}"
        roast_lines << "- Total analyzed chunks: #{code_files.size}"
        
        # Check for linting configs
        has_eslint = File.exist?(File.join(target_path, '.eslintrc.js')) || 
                    File.exist?(File.join(target_path, '.eslintrc.json')) ||
                    File.exist?(File.join(target_path, 'eslint.config.js'))
        has_prettier = File.exist?(File.join(target_path, '.prettierrc'))
        
        roast_lines << ""
        if has_eslint
          roast_lines << "✅ **Linting Setup**: Good, you have ESLint configured. At least someone cares about code quality."
        else
          roast_lines << "🔥 **No Linting**: Your code is probably messier than a teenager's room. Set up ESLint!"
        end
        
        if has_prettier
          roast_lines << "✅ **Code Formatting**: Prettier is configured. Your code might actually be readable."
        else
          roast_lines << "🔥 **Formatting Chaos**: No Prettier config found. I bet your code looks like it was formatted by a drunk monkey."
        end
      end
      
      roast_lines.join("\n")
    end

    def analyze_dependencies(target_path, chunks)
      # Basic dependency analysis
      roast_lines = []
      roast_lines << "## 📦 Dependency Roast"
      roast_lines << ""
      
      package_json = File.join(target_path, 'package.json')
      requirements_txt = File.join(target_path, 'requirements.txt')
      gemfile = File.join(target_path, 'Gemfile')
      
      if File.exist?(package_json)
        package_data = JSON.parse(File.read(package_json)) rescue {}
        deps = (package_data['dependencies'] || {}).keys
        dev_deps = (package_data['devDependencies'] || {}).keys
        
        roast_lines << "📊 **Node.js Dependencies**:"
        roast_lines << "- Production dependencies: #{deps.size}"
        roast_lines << "- Development dependencies: #{dev_deps.size}"
        
        if deps.size > 50
          roast_lines << "🔥 **Dependency Hell**: #{deps.size} dependencies? Are you building the next Facebook or just a todo app?"
        elsif deps.size < 5
          roast_lines << "🔥 **Minimalist Much?**: Only #{deps.size} dependencies. Either you're a genius or you're reinventing the wheel."
        end
        
      elsif File.exist?(requirements_txt)
        reqs = File.readlines(requirements_txt).map(&:strip).reject(&:empty?)
        roast_lines << "📊 **Python Dependencies**:"
        roast_lines << "- Requirements: #{reqs.size}"
        
      elsif File.exist?(gemfile)
        roast_lines << "📊 **Ruby Dependencies**:"
        roast_lines << "- Gemfile found, analyzing Ruby dependencies..."
        
      else
        roast_lines << "🔥 **Dependency Mystery**: No package.json, requirements.txt, or Gemfile found. How does this thing even run?"
      end
      
      roast_lines.join("\n")
    end

    def analyze_bugs(target_path, chunks)
      # Basic bug hunting analysis
      roast_lines = []
      roast_lines << "## 🕵️ Bug Hunter Roast"
      roast_lines << ""
      
      # Look for common bug patterns
      test_files = Dir.glob(File.join(target_path, '**/*{test,spec}*'))
      
      roast_lines << "📊 **Testing Analysis**:"
      roast_lines << "- Test files found: #{test_files.size}"
      
      if test_files.empty?
        roast_lines << "🔥 **No Tests Found**: Your code is like a tightrope walker without a net. Add some tests before your users find the bugs for you!"
      else
        roast_lines << "✅ **Tests Present**: At least you have some tests. Whether they actually test anything useful is another question..."
      end
      
      # Check for TODO/FIXME comments
      todo_count = 0
      fixme_count = 0
      
      chunks.select { |c| c[:type] == 'source_code' }.each do |chunk|
        content = chunk[:content] || ""
        todo_count += content.scan(/TODO|todo/i).size
        fixme_count += content.scan(/FIXME|fixme/i).size
      end
      
      roast_lines << ""
      roast_lines << "🔍 **Code Analysis**:"
      roast_lines << "- TODO comments: #{todo_count}"
      roast_lines << "- FIXME comments: #{fixme_count}"
      
      if todo_count > 10
        roast_lines << "🔥 **TODO Overload**: #{todo_count} TODOs? This isn't a todo list app, it's your codebase!"
      end
      
      if fixme_count > 5
        roast_lines << "🔥 **FIXME Festival**: #{fixme_count} FIXMEs? Sounds like your code is held together with duct tape and prayers."
      end
      
      roast_lines.join("\n")
    end

    def analyze_nitpicks(target_path, chunks)
      # Naming convention and style nitpicking analysis
      roast_lines = []
      roast_lines << "## 🔍 Nitpicker Agent Roast"
      roast_lines << ""
      
      code_chunks = chunks.select { |chunk| chunk[:type] == 'source_code' }
      naming_issues = []
      style_issues = []
      total_files_analyzed = 0
      
      code_chunks.each do |chunk|
        # Process each file in the chunk
        chunk[:files].each do |file_info|
          file_path = file_info[:path]
          next unless File.exist?(file_path)
          
          content = File.read(file_path) rescue ""
          next if content.empty?
          
          total_files_analyzed += 1
          file_name = File.basename(file_path)
          
          # Check for bad variable names
          bad_names = content.scan(/(?:var|let|const|def)\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*[=\(]/).flatten
          bad_names.each do |name|
            if name.length == 1 && !%w[i j k x y z].include?(name)
              naming_issues << "🔥 Single letter variable '#{name}' in #{file_name} - What is this, algebra class?"
            elsif %w[data info stuff thing temp].include?(name.downcase)
              naming_issues << "🔥 Generic variable '#{name}' in #{file_name} - This tells me nothing!"
            elsif name.match?(/^[a-z]{1,3}$/) && !%w[app api url uri].include?(name.downcase)
              naming_issues << "🔥 Cryptic abbreviation '#{name}' in #{file_name} - I need a decoder ring!"
            end
          end
          
          # Check for inconsistent indentation
          lines = content.split("\n")
          tab_lines = lines.count { |line| line.start_with?("\t") }
          space_lines = lines.count { |line| line.match?(/^[ ]{2,}/) }
          
          if tab_lines > 0 && space_lines > 0
            style_issues << "🔥 Mixed tabs and spaces in #{file_name} - Pick a side in the indentation war!"
          end
          
          # Check for magic numbers
          magic_numbers = content.scan(/(?<![a-zA-Z0-9_])[0-9]+(?![a-zA-Z0-9_])/).reject { |n| %w[0 1 2 -1].include?(n) }
          if magic_numbers.size > 5
            style_issues << "🔥 Magic numbers galore in #{file_name} - #{magic_numbers.size} unexplained numbers found!"
          end
          
          # Check for long lines
          long_lines = lines.select { |line| line.length > 120 }
          if long_lines.size > 3
            style_issues << "🔥 Long lines in #{file_name} - #{long_lines.size} lines longer than a CVS receipt!"
          end
        end
      end
      
      roast_lines << "📊 **Nitpicking Stats**:"
      roast_lines << "- Code files analyzed: #{total_files_analyzed}"
      roast_lines << "- Naming issues found: #{naming_issues.size}"
      roast_lines << "- Style issues found: #{style_issues.size}"
      roast_lines << ""
      
      if naming_issues.empty? && style_issues.empty?
        roast_lines << "✅ **Clean Code**: Surprisingly, your naming and style are decent. I'm almost disappointed I can't roast you more!"
      else
        roast_lines << "### 🎯 Naming Issues:"
        naming_issues.first(5).each { |issue| roast_lines << issue }
        roast_lines << "... and #{naming_issues.size - 5} more naming disasters!" if naming_issues.size > 5
        roast_lines << ""
        
        roast_lines << "### 🎨 Style Issues:"
        style_issues.first(5).each { |issue| roast_lines << issue }
        roast_lines << "... and #{style_issues.size - 5} more style crimes!" if style_issues.size > 5
      end
      
      roast_lines << ""
      total_issues = naming_issues.size + style_issues.size
      grade = if total_issues == 0
        "A+"
      elsif total_issues < 5
        "B"
      elsif total_issues < 10
        "C"
      elsif total_issues < 20
        "D"
      else
        "F"
      end
      
      roast_lines << "### 📝 Final Nitpicking Grade: #{grade}"
      roast_lines << "Overall, this code made me #{total_issues == 0 ? 'surprisingly happy' : 'more nitpicky than a food critic at a gas station'} 🔍"
      
      roast_lines.join("\n")
    end

    def generate_report(results)
      report_content = build_report_content(results)
      File.write(@output_file, report_content)
    end

    def build_report_content(results)
      <<~MARKDOWN
        # 🔥 Glaser Code Roast Report
        
        Generated on: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}
        Target: #{@target}
        Mode: #{@serious_mode ? 'Serious' : 'Roast'}
        
        ---
        
        ## 📋 Analysis Summary
        
        #{results.map { |agent, result| format_agent_summary(agent, result) }.join("\n\n")}
        
        ---
        
        ## 🎭 The Roast Results
        
        #{results.map { |agent, result| format_agent_results(agent, result) }.join("\n\n")}
        
        ---
        
        *Generated by Glaser v#{VERSION} - AI-powered code roasting with attitude* 🔥
      MARKDOWN
    end

    def format_agent_summary(agent, result)
      status_emoji = result[:error] ? '❌' : '✅'
      message = if result[:error]
        result[:error]
      elsif result[:result]
        'Analysis completed successfully'
      else
        'Analysis completed'
      end
      "#{status_emoji} **#{agent.split('_').map(&:capitalize).join(' ')} Agent**: #{message}"
    end

    def format_agent_results(agent, result)
      return format_error_result(agent, result) if result[:error]
      
      <<~SECTION
        ### #{agent_emoji(agent)} #{agent.split('_').map(&:capitalize).join(' ')} Agent
        
        #{format_agent_content(agent, result)}
      SECTION
    end

    def format_error_result(agent, result)
      <<~SECTION
        ### ❌ #{agent.split('_').map(&:capitalize).join(' ')} Agent
        
        **Error:** #{result[:error]}
        
        This agent couldn't complete its roast due to technical difficulties.
      SECTION
    end

    def format_agent_content(agent, result)
      if result[:result]
        result[:result]
      else
        case agent
        when 'documentation'
          'Documentation analysis results will appear here once workflows are implemented.'
        when 'code_quality'
          'Code quality analysis results will appear here once workflows are implemented.'
        when 'dependency'
          'Dependency analysis results will appear here once workflows are implemented.'
        when 'bug_hunter'
          'Bug hunting results will appear here once workflows are implemented.'
        when 'nitpicker'
          'Nitpicking analysis results will appear here once workflows are implemented.'
        else
          'Analysis results pending workflow implementation.'
        end
      end
    end

    def agent_emoji(agent)
      {
        'documentation' => '📝',
        'code_quality' => '🧱',
        'dependency' => '📦',
        'bug_hunter' => '🕵️',
        'nitpicker' => '🔍'
      }[agent] || '🤖'
    end

    def generate_timestamped_filename
      timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
      repo_name = File.basename(@target).gsub(/[^a-zA-Z0-9_-]/, '_')
      "glaser-report_#{repo_name}_#{timestamp}.md"
    end

    def display_colorized_report
      return unless File.exist?(@output_file)
      
      puts "📄 Report Preview:".colorize(:cyan)
      puts "=" * 60
      
      content = File.read(@output_file)
      lines = content.split("\n")
      
      # Display first 50 lines with colors
      lines.first(50).each do |line|
        colored_line = colorize_markdown_line(line)
        puts colored_line
      end
      
      if lines.size > 50
        puts ""
        puts "... (#{lines.size - 50} more lines in full report)".colorize(:light_black)
      end
      
      puts "=" * 60
      puts "📁 Full report: #{@output_file}".colorize(:cyan)
    end

    def colorize_markdown_line(line)
      case line
      when /^# /
        line.colorize(:red).bold
      when /^## /
        line.colorize(:yellow).bold
      when /^### /
        line.colorize(:blue).bold
      when /^🔥/
        line.colorize(:red)
      when /^✅/
        line.colorize(:green)
      when /^📊/
        line.colorize(:cyan)
      when /^📝/, /^📚/, /^🧱/, /^📦/, /^🕵️/, /^🔍/
        line.colorize(:magenta).bold
      when /^\*/
        line.colorize(:light_yellow)
      when /^-/
        line.colorize(:white)
      when /Grade: [A-F]/
        if line.include?('A+') || line.include?('A')
          line.colorize(:green).bold
        elsif line.include?('B')
          line.colorize(:yellow).bold
        elsif line.include?('C')
          line.colorize(:light_yellow).bold
        elsif line.include?('D')
          line.colorize(:light_red).bold
        else
          line.colorize(:red).bold
        end
      else
        line
      end
    end
  end
end