module Interactor

  describe Context do
    def build_interactor(&block)
      Class.new.send(:include, Interactor).tap do |interactor|
        interactor.class_eval(&block) if block
      end
    end

    let(:interactor) {
      build_interactor do
        receive :foo
      end
    }

    describe ".build" do
      it "converts the given hash to a context" do
        context = interactor.context_class.build(foo: "bar")

        expect(context).to be_a(Context)
        expect(context.foo).to eq("bar")
      end

      it "raises if a required argument is not provided" do
        expect { interactor.context_class.build }.to raise_error(ArgumentError)
      end

      it "doesn't affect the original hash" do
        hash = { foo: "bar" }
        context = interactor.context_class.build(**hash)

        expect(context).to be_a(interactor.context_class)
        expect {
          context.foo = "baz"
        }.not_to change {
          hash[:foo]
        }
      end

      it "ignores any additional argument" do
        hash = { foo: 'bar', bar: "baz" }
        expect { interactor.context_class.build(**hash) }.not_to raise_error
      end
    end

    describe "#success?" do
      let(:context) { Context.build }

      it "is true by default" do
        expect(context.success?).to eq(true)
      end
    end

    describe "#failure?" do
      let(:context) { Context.build }

      it "is false by default" do
        expect(context.failure?).to eq(false)
      end
    end

    describe "#fail!" do
      let(:context) { interactor.context_class.build(foo: "bar") }

      it "sets success to false" do
        expect {
          begin
            context.fail!
          rescue
            nil
          end
        }.to change {
          context.success?
        }.from(true).to(false)
      end

      it "sets failure to true" do
        expect {
          begin
            context.fail!
          rescue
            nil
          end
        }.to change {
          context.failure?
        }.from(false).to(true)
      end

      it "preserves failure" do
        begin
          context.fail!
        rescue
          nil
        end

        expect {
          begin
            context.fail!
          rescue
            nil
          end
        }.not_to change {
          context.failure?
        }
      end

      it "preserves the context" do
        expect {
          begin
            context.fail!
          rescue
            nil
          end
        }.not_to change {
          context.foo
        }
      end

      it "updates the context" do
        expect {
          begin
            context.fail!(error: "baz")
          rescue
            nil
          end
        }.to change {
          context.error
        }.to("baz")
      end

      it "raises failure" do
        expect {
          context.fail!
        }.to raise_error(Failure)
      end

      it "makes the context available from the failure" do
        begin
          context.fail!
        rescue Failure => error
          expect(error.context).to eq(context)
        end
      end
    end
  end
end
