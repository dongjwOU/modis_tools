class Mrtswath < Thor
  include Thor::Actions

  def self.source_root
    File.join(File.dirname(__FILE__), '..')
  end

  desc "params INPUT_FILE GEO_FILE OUTPUT_FILE", "generates a params file for mrtswath"
  long_desc "This command will create a params files that can be used with mrtswath based on the options given"
  method_option :format, :type => :string
  method_option :force, :type => :boolean

  def params(input_file, geo_file, output_file)
    @config = {
      :input => input_file,
      :geofile => geo_file,
      :output => output_file
    }

    unless options.include? "format"
      @config[:format] = determine_format(output_file)
    else
      @config[:format] = options['format']
    end

    template('templates/mrtswath.params.erb', "#{@config[:output]}.params", options['force'])
  end

  desc 'help', 'Show the default help text'
  def help
    super('params')
  end

  protected

  def determine_format(filename)
    case filename.split('.').last.downcase.to_sym
      when :tif
        'TIF'
      when :hdf
        'HDF'
      else
        'TIF'
    end
  end
end
