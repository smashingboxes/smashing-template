# https://stackoverflow.com/questions/10911371/how-to-get-the-line-of-code-that-triggers-a-query
module QueryTrace
  def self.enable!
    ::ActiveRecord::LogSubscriber.send(:include, self)
  end

  def self.append_features(klass)
    super
    klass.class_eval do
      unless method_defined?(:log_info_without_trace)
        alias_method :log_info_without_trace, :sql
        alias_method :sql, :log_info_with_trace
      end
    end
  end

  def log_info_with_trace(event)
    log_info_without_trace(event)
    trace_log = Rails.backtrace_cleaner.clean(caller)
    if trace_log && event.payload[:name] != "SCHEMA"
      trace_log.each do |log|
        logger.debug("   \\_ \e[33mCalled from:\e[0m " + log)
      end
    end
  end
end

QueryTrace.enable! if Rails.env.development?