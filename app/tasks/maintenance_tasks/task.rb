# frozen_string_literal: true

module MaintenanceTasks
  # Base class that is inherited by the host application's task classes.
  class Task
    extend ActiveSupport::DescendantsTracker

    class NotFoundError < NameError; end

    class << self
      # Finds a Task with the given name.
      #
      # @param name [String] the name of the Task to be found.
      #
      # @return [Task] the Task with the given name.
      #
      # @raise [NotFoundError] if a Task with the given name does not exist.
      def named(name)
        task = name.safe_constantize
        raise NotFoundError.new("Task #{name} not found.", name) unless task
        unless task.is_a?(Class) && task < Task
          raise NotFoundError.new("#{name} is not a Task.", name)
        end
        task
      end

      # Returns a list of concrete classes that inherit from the Task
      # superclass.
      #
      # @return [Array<Class>] the list of classes.
      def available_tasks
        load_constants
        descendants
      end

      # Make this Task a task that handles CSV.
      #
      # An input to upload a CSV will be added in the form to start a Run. The
      # collection and count method are implemented.
      def csv_collection
        include(CsvCollection)
      end

      # The list of available parameters on the Task
      def params
        @params ||= {}
      end

      # Define a parameter for this Task.
      def param(name, type)
        puts name, type
        params[name] = type
        # attr_accessor name
      end

      # Processes one item.
      #
      # Especially useful for tests.
      #
      # @param item the item to process.
      def process(item)
        new.process(item)
      end

      # Returns the collection for this Task.
      #
      # Especially useful for tests.
      #
      # @return the collection.
      def collection
        new.collection
      end

      # Returns the count of items for this Task.
      #
      # Especially useful for tests.
      #
      # @return the count of items.
      def count
        new.count
      end

      private

      def load_constants
        namespace = MaintenanceTasks.tasks_module.safe_constantize
        return unless namespace
        namespace.constants.map { |constant| namespace.const_get(constant) }
      end
    end

    # Placeholder method to raise in case a subclass fails to implement the
    # expected instance method.
    #
    # @raise [NotImplementedError] with a message advising subclasses to
    #   implement an override for this method.
    def collection
      raise NoMethodError, "#{self.class.name} must implement `collection`."
    end

    # Placeholder method to raise in case a subclass fails to implement the
    # expected instance method.
    #
    # @param _item [Object] the current item from the enumerator being iterated.
    #
    # @raise [NotImplementedError] with a message advising subclasses to
    #   implement an override for this method.
    def process(_item)
      raise NoMethodError, "#{self.class.name} must implement `process`."
    end

    # Total count of iterations to be performed.
    #
    # Tasks override this method to define the total amount of iterations
    # expected at the start of the run. Return +nil+ if the amount is
    # undefined, or counting would be prohibitive for your database.
    #
    # @return [Integer, nil]
    def count
    end

    # Set params on the Task so it's accessible from Task code
    def set_params(params)
      params.each do |param_name, param_value|
        attr_accessor param_name
        param = param_value # need to coerce into what we expect
      end
    end

    private

    # def coerce_param(value, type)
    #   raise unless type in [Integer, Float, String, Boolean, Array, Hash]
    # end
  end
end
