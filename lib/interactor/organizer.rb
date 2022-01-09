module Interactor
  # Public: Interactor::Organizer methods. Because Interactor::Organizer is a
  # module, custom Interactor::Organizer classes should include
  # Interactor::Organizer rather than inherit from it.
  #
  # Examples
  #
  #   class MyOrganizer
  #     include Interactor::Organizer
  #
  #     organizer InteractorOne, InteractorTwo
  #   end
  module Organizer
    extend ActiveSupport::Concern
    include Interactor

    # Internal: Interactor::Organizer class methods.
    class_methods do
      # Public: Declare Interactors to be invoked as part of the
      # Interactor::Organizer's invocation. These interactors are invoked in
      # the order in which they are declared.
      #
      # interactors - Zero or more (or an Array of) Interactor classes.
      #
      # Examples
      #
      #   class MyFirstOrganizer
      #     include Interactor::Organizer
      #
      #     organize InteractorOne, InteractorTwo
      #   end
      #
      #   class MySecondOrganizer
      #     include Interactor::Organizer
      #
      #     organize [InteractorThree, InteractorFour]
      #   end
      #
      # Returns nothing.
      def organize(*interactors)
        @organized = interactors.flatten
      end

      # Internal: An Array of declared Interactors to be invoked.
      #
      # Examples
      #
      #   class MyOrganizer
      #     include Interactor::Organizer
      #
      #     organize InteractorOne, InteractorTwo
      #   end
      #
      #   MyOrganizer.organized
      #   # => [InteractorOne, InteractorTwo]
      #
      # Returns an Array of Interactor classes or an empty Array.
      def organized
        @organized ||= []
      end
    end

    def call
      self.class.organized.inject(context) do |ctx, interactor|
        interactor.call!(ctx)
      end
    end
  end
end