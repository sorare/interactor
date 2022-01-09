module Interactor
  describe Declaration do
    def build_declared(&block)
      Class.new.send(:include, Declaration).tap do |declared|
        declared.class_eval(&block)

        declared.class_eval do
          def context
            self
          end
        end
      end
    end

    subject { declared.context_class }

    describe "#receive" do
      context "with a required argument" do
        let(:declared) {
          build_declared do
            receive :foo
          end
        }

        it "cannot be initialized without foo" do
          expect { subject.new }.to raise_error(ArgumentError)
        end

        it "can be initialized with foo" do
          expect(subject.new(foo: 'bar').foo).to eq('bar')
        end

        context 'when duplicated in a submodule' do
          let(:submodule) do
            Module.new do
              extend ActiveSupport::Concern

              included do
                receive :foo
              end
            end
          end

          let(:declared) {
            build_declared do
              include Submodule

              receive :foo
            end
          }

          before { stub_const("Submodule", submodule) }

          it "can be initialized with foo" do
            expect(subject.new(foo: 'bar').foo).to eq('bar')
          end
        end

      end

      context "with an optional argument" do
        context "with a constant default value" do
          let(:declared) {
            build_declared do
              receive foo: 'bar'
            end
          }

          it "can be initialized without foo" do
            expect(subject.new.foo).to eq('bar')
          end

          it "can be initialized with foo" do
            expect(subject.new(foo: 'baz').foo).to eq('baz')
          end

          it "can be initialized with nil" do
            expect(subject.new(foo: nil).foo).to be nil
          end
        end

        context "with a nil default value" do
          let(:declared) {
            build_declared do
              receive foo: nil
            end
          }

          it "can be initialized without foo" do
            expect(subject.new.foo).to be nil
          end

          it "can be initialized with foo" do
            expect(subject.new(foo: 'baz').foo).to eq('baz')
          end
        end

        context "with a Proc default value" do
          let(:declared) {
            build_declared do
              receive :bar, foo: ->(context) { context.bar }
            end
          }

          it "can be initialized without foo" do
            expect(subject.new(bar: 'bar').foo).to eq('bar')
          end

          it "can be initialized with foo" do
            expect(subject.new(bar: 'bar', foo: 'baz').foo).to eq('baz')
          end
        end
      end
    end
  end
end
