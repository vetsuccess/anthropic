RSpec.describe Anthropic::Client do
  describe "#messages" do
    context "with a prompt and max_tokens", :vcr do
      let(:prompt) { "How high is the sky?" }
      let(:max_tokens) { 5 }

      let(:response) do
        Anthropic::Client.new.messages(
          parameters: {
            model: model,
            max_tokens: max_tokens,
            prompt: prompt
          }
        )
      end
      let(:text) { response.dig("choices", 0, "text") }
      let(:cassette) { "#{model} message #{prompt}".downcase }

      context "with model: claude-3" do
        let(:model) { "claude-3" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(response["content"].empty?).to eq(false)
          end
        end
      end
    end
  end
end
