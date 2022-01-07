module Interactor
  describe Organizer do
    let(:organizer) {
      Class.new do
        include Organizer
        include Declaration
      end
    }

    describe ".organize" do
      let(:interactor2) { double(:interactor2) }
      let(:interactor3) { double(:interactor3) }

      it "sets interactors given class arguments" do
        expect {
          organizer.organize(interactor2, interactor3)
        }.to change {
          organizer.organized
        }.from([]).to([interactor2, interactor3])
      end

      it "sets interactors given an array of classes" do
        expect {
          organizer.organize([interactor2, interactor3])
        }.to change {
          organizer.organized
        }.from([]).to([interactor2, interactor3])
      end
    end

    describe ".organized" do
      it "is empty by default" do
        expect(organizer.organized).to eq([])
      end
    end

    describe "#call" do
      let(:instance) { organizer.new }
      let(:context) { double(:context) }
      let(:interactor2) { Class.new.send(:include, Interactor) }
      let(:interactor3) { Class.new.send(:include, Interactor) }
      let(:interactor4) { Class.new.send(:include, Interactor) }

      before do
        allow(instance).to receive(:context) { context }
        allow(organizer).to receive(:organized) {
          [interactor2, interactor3, interactor4]
        }
      end

      it "calls each interactor in order with the context" do
        expect(interactor2).to receive(:call!).once.ordered
        expect(interactor3).to receive(:call!).once.ordered
        expect(interactor4).to receive(:call!).once.ordered

        instance.call
      end
    end
  end
end