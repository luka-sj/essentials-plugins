#===============================================================================
#  Luka's Scripting Utilities
#
#  Error logger utility
#  Used to store custom error log messages
#===============================================================================
module LUTS
  module Logger
    class << self
      # @return [String] path to which to log message output
      def log_path
        'luts_log.txt' # ::RTP.getSaveFileName('luts_log.txt')
      end

      # Logs message to console and file
      # @param msg [String]
      # @param options [Hash]
      def log_msg(msg, options = {})
        log_to_console(msg, options)

        File.open(log_path, 'ab') do |f|
          f.write("#{timestamp} [#{options[:type].to_s.upcase}] #{msg}\r\n")
        end
      end

      # Logs message to console with formatting
      # @param msg [String]
      # @param options [String]
      def log_to_console(msg, options)
        return if options[:skip_console] == true

        # print log level
        if options[:type].eql?(:debug)
          Console.echo_str("[#{options[:type].to_s.upcase}]")
        else
          Console.echo_str(" #{options[:type].to_s.upcase} ", bg: console_color(options[:type]))
        end

        # print header if applicable
        if options[:header].eql?(true)
          Console.echoln(Console.markup_style(" *** #{msg} ***", text: :brown))
          return
        end

        # print line item if applicable
        Console.echo_str(' -> ', text: :brown) if msg.start_with?('-> ')
        msg = " #{msg}"

        # print rest of message
        if options[:break].eql?(false)
          Console.echo_str(msg.sub('-> ', '').gsub('`', '"'), options.except(:type, :break))
        else
          Console.echo_p(msg.sub('-> ', '').gsub('`', '"'), options.except(:type, :break))
        end
      end

      # Get console color for message type
      # @param type [Symbol]
      def console_color(type)
        case type
        when :error
          :red
        when :warn
          :brown
        else
          :cyan
        end
      end

      # @return [String] formated timestamp
      def timestamp
        Time.now.strftime('[%H:%M:%S %a %d-%b-%Y]')
      end

      # INFO level log
      # @param msg [String]
      # @param options [Hash]
      def info(msg, options = {})
        log_msg(msg, options.merge({ type: :info }))
      end

      # ERROR level log
      # @param msg [String]
      # @param options [Hash]
      def error(msg, options = {})
        log_msg(msg, options.merge({ type: :error }))
      end

      # ERROR level log and crash application
      # @param msg [String]
      # @param options [Hash]
      def critical(msg, options = {})
        log_msg(msg, options.merge({ type: :error }))

        raise LUTS::ScriptError, msg
      end

      # WARN level log
      # @param msg [String]
      # @param options [Hash]
      def warn(msg, options = {})
        log_msg(msg, options.merge({ type: :warn }))
      end

      # DEBUG level log
      # @param msg [String]
      # @param options [Hash]
      def debug(msg, options = {})
        return unless $DEBUG

        log_msg(msg, options.merge({ type: :debug }))
      end
    end
  end
end
