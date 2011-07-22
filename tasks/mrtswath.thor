class Mrtswath < Thor
  include Thor::Actions

  def self.source_root
    File.join(File.dirname(__FILE__), '..')
  end

  desc "params INPUT_FILE GEO_FILE OUTPUT_FILE", "generates a params file for mrtswath"
  long_desc "This command will create a params files that can be used with mrtswath based on the options given"
  method_option :format, :type => :string
  method_option :bands, :type => :string, :default => "EV_1KM_RefSB, 1"
  method_option :force, :type => :boolean

  def params(input_file, geo_file, output_file)
    @config = {
      :input => input_file,
      :input_sds => options[:bands],
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

  desc "go PARAMS_FILE", "run the mrtswath program"
  def go(params_file)
    cmd = []
    cmd << `which swath2grid`.chomp
    cmd << "-pf=#{params_file}"
    puts cmd.inspect
    system(*cmd)
  end

  desc "all INPUT_FILE GEO_FILE OUTPUT_FILE", "runs mrtswath after generating a params files"
  method_option :format, :type => :string
  method_option :force, :type => :boolean
  
  def all(input, geo, output)
    invoke :params, [input, geo, output]
    invoke :go, ["#{output}.params"]
  end

  protected

  def determine_format(filename)
    case filename.split('.').last.downcase.to_sym
      when :hdf
        'HDF_FMT'
      else
        'GEOTIFF_FMT'
    end
  end
end
