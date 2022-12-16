module Interactor
  describe Failure do
    describe ".cause_stack" do
      subject { failure.cause_stack }

      let(:exception_1) { Class.new(Exception) }
      let(:exception_2) { Class.new(Exception) }
      let(:interactor) do
        Class.new.send(:include, Interactor) do
          def call
            begin
              raise exception_1
            rescue StandardError
              raise exception_2
            end
          rescue StandardError
            context.fail!
          end
        end
      end

      it "returns an empty stack" do
        interactor.call!
      rescue Failure => e
        expect(e.cause_stack).to contain_exactly(described_class, exception_1, exception_2)
      end
    end
  end
end
