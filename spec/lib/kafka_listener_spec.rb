describe KafkaListener do
  let(:test_listener_class) do
    Class.new(described_class) do
      def process_event(_event)
      end
    end
  end
  
  let(:client) { double(:client) }
  let(:service) { 'service' }
  let(:persist_ref) { 'ref' }
  let(:subject) { test_listener_class.new({:host => 'localhost', :port => 9092}, service, persist_ref) }
  let(:event) { ManageIQ::Messaging::ReceivedMessage.new(nil, 'test event', {'data' => 'value'}, {}, nil, client) }
  
  before do
    allow(ManageIQ::Messaging::Client).to receive(:open).with(
      :encoding => "json",
      :host     => "localhost",
      :port     => 9092,
      :protocol => :Kafka
    ).and_yield(client)
  
    allow(client).to receive(:subscribe_topic).with(
      :service     => service,
      :persist_ref => persist_ref,
      :max_bytes   => 500_000
    ).and_yield(event)
  
    allow(event).to receive(:ack)
  end

  context "when a message is received" do
    it "processes the message" do
      expect(subject).to receive(:process_event)
      expect(event).to receive(:ack)
      subject.subscribe
    end
  end

  context "when the event processing has an error" do  
    before do
      allow(subject).to receive(:process_event).and_raise(StandardError)
    end

    it "does not spin forever" do
      expect(client).to receive(:subscribe_topic).once
  
      Timeout.timeout(3) do
        subject.subscribe
      end
    end
  
    it "acks the event" do
      expect(event).to receive(:ack)
      subject.subscribe
    end
  
    it "logs an error" do
      expect(Rails.logger).to receive(:error).with(/Error processing event/).ordered
      subject.subscribe
    end
  end
end
