describe EndpointCreateTaskService do
  include ::Spec::Support::TenantIdentity

  let(:source) { FactoryBot.create(:source, :tenant => tenant) }
  let(:subject) { described_class.new(params) }

  describe "#process" do
    let(:client_id) { SecureRandom.uuid }
    let(:params) { {"source_id" => source.id, "receptor_node" => client_id} }

    it "updates mqtt_client_id" do
      subject.process

      source.reload
      expect(source.mqtt_client_id).to eq(client_id)
    end

    context "when options missing receptor_node" do
      let(:params) { {"source_id" => source.id} }

      it "raise exception" do
        expect { subject.process }.to raise_error("Options must have source_id and receptor_node keys")
      end
    end

    context "when options missing source_id" do
      let(:params) { {"receptor_node" => client_id} }

      it "raise exception" do
        expect { subject.process }.to raise_error("Options must have source_id and receptor_node keys")
      end
    end
  end
end
