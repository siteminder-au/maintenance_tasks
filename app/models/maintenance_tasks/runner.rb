# frozen_string_literal: true

module MaintenanceTasks
  # This class is responsible for running a given Task.
  module Runner
    extend self

    # @deprecated Use {Runner} directly instead.
    def new
      ActiveSupport::Deprecation.warn(
        'Use Runner.run instead of Runner.new.run'
      )
      self
    end

    # Exception raised when a Task Job couldn't be enqueued.
    class EnqueuingError < StandardError
      # Initializes a Enqueuing Error.
      #
      # @param run [Run] the Run which failed to be enqueued.
      # @return [EnqueuingError] an Enqueuing Error instance.
      def initialize(run)
        super("The job to perform #{run.task_name} could not be enqueued")
        @run = run
      end

      attr_reader :run
    end

    # Runs a Task.
    #
    # This method creates a Run record for the given Task name and enqueues the
    # Run. If a CSV file is provided, it is attached to the Run record.
    #
    # @param name [String] the name of the Task to be run.
    # @param csv_file [attachable, nil] a CSV file that provides the collection
    #   for the Task to iterate over when running, in the form of an attachable
    #   (see https://edgeapi.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-attach).
    #   Value is nil if the Task does not use CSV iteration.
    #
    # @return [Task] the Task that was run.
    #
    # @raise [EnqueuingError] if an error occurs while enqueuing the Run.
    # @raise [ActiveRecord::RecordInvalid] if validation errors occur while
    #   creating the Run.
    def run(name:, csv_file: nil, params:)
      run = Run.active.find_by(task_name: name) || Run.new(task_name: name)
      run.csv_file.attach(csv_file) if csv_file

      run.enqueued!
      enqueue(run, params)
      Task.named(name)
    end

    private

    def enqueue(run, params)
      unless MaintenanceTasks.job.constantize.perform_later(run, params)
        raise "The job to perform #{run.task_name} could not be enqueued. "\
          'Enqueuing has been prevented by a callback.'
      end
    rescue => error
      run.persist_error(error)
      raise EnqueuingError, run
    end
  end
end
