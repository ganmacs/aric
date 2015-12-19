require 'aric/job'

module Aric
  class JobHandler
    class JobNotFound < StandardError; end

    class << self
      def play(*args)
        if args.first && jobs.include?(args.first.to_sym)
          new(:play_music).run(*args)
        else
          raise JobNotFound
        end
      end

      def jobs
        @jobs ||= job_class_hash.values.flat_map(&:itself)
      end

      def job_class_hash
        @job_class_hash ||= job_classes.each_with_object({}) do |c, a|
          a[c] = c.public_instance_methods(false)
        end
      end

      private

      def job_classes
        @job_class ||= Job.constants.map { |e| Job.const_get(e) }
      end
    end

    def initialize(job_name)
      @job_name = job_name.to_sym
    end

    def run(*args)
      # Check argument number
      job_class.run(@job_name, *args)
    end

    private

    # Return Job class that has job_name method
    def job_class
      raise JobNotFound if job_not_found?
      JobHandler.job_class_hash.find { |_, v| v.include?(@job_name) }.first
    end

    def job_not_found?
      !JobHandler.jobs.include?(@job_name)
    end
  end
end
