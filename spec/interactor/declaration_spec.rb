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

    describe '#receive' do
      context 'with a required argument' do
        let(:declared) do
          build_declared do
            receive :foo
          end
        end

        it 'cannot be initialized without foo' do
          expect { subject.build }.to raise_error(ArgumentError)
        end

        it 'can be initialized with foo' do
          expect(subject.build(foo: 'bar').foo).to eq('bar')
        end

        it 'can introspect the received arguments' do
          expect(declared.received_arguments).to eq([:foo])
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

          let(:declared) do
            build_declared do
              include Submodule

              receive :foo
            end
          end

          before { stub_const('Submodule', submodule) }

          it 'can be initialized with foo' do
            expect(subject.build(foo: 'bar').foo).to eq('bar')
          end
        end
      end

      context 'with an optional argument' do
        context 'with a constant default value' do
          let(:declared) do
            build_declared do
              receive foo: 'bar'
            end
          end

          it 'can be initialized without foo' do
            expect(subject.build.foo).to eq('bar')
          end

          it 'can be initialized with foo' do
            expect(subject.build(foo: 'baz').foo).to eq('baz')
          end

          it 'can be initialized with nil' do
            expect(subject.build(foo: nil).foo).to be nil
          end
        end

        context 'with a nil default value' do
          let(:declared) {
            build_declared do
              receive foo: nil
            end
          }

          it 'can be initialized without foo' do
            expect(subject.build.foo).to be nil
          end

          it 'can be initialized with foo' do
            expect(subject.build(foo: 'baz').foo).to eq('baz')
          end
        end

        context 'with a Proc default value' do
          let(:declared) {
            build_declared do
              receive :bar, foo: ->(context) { context.bar }
            end
          }

          it 'can be initialized without foo' do
            expect(subject.build(bar: 'bar').foo).to eq('bar')
          end

          it 'can be initialized with foo' do
            expect(subject.build(bar: 'bar', foo: 'baz').foo).to eq('baz')
          end

          it 'can introspect the received arguments' do
            expect(declared.received_arguments).to eq(%i[bar foo])
          end
        end
      end
    end

    describe '#hold' do
      let(:declared) {
        build_declared do
          hold :foo
        end
      }

      it 'can hold foo' do
        c = subject.build
        c.foo = 'bar'
        expect(c.foo).to eq('bar')
      end

      it 'can introspect the held attributes' do
        expect(declared.held_attributes).to eq([:foo])
      end

      context 'with default value' do
        let(:declared) {
          build_declared do
            hold foo: 'bar'
          end
        }

        it 'can hold foo with default value' do
          c = subject.build
          expect(c.foo).to eq('bar')

          c.foo = 'baz'
          expect(c.foo).to eq('baz')
        end

        context 'when default value is a proc' do
          let(:declared) {
            build_declared do
              hold foo: proc { [] }
            end
          }

          it 'can hold foo with default value different for each new context through proc' do
            c = subject.build
            expect(c.foo).to eq([])

            other_c = subject.build
            expect(other_c.foo).to eq([])

            c.foo << 'baz'
            expect(c.foo).to eq(['baz'])
            expect(other_c.foo).to eq([])
          end
        end
      end
    end
  end
end
