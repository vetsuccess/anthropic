module Anthropic
  module HTTP
    def get(path:)
      HTTParty.get(
        uri(path: path),
        headers: headers,
        timeout: request_timeout
      )
    end

    def json_post(path:, parameters:)
      HTTParty.post(
        uri(path: path),
        headers: headers,
        body: parameters&.to_json,
        timeout: request_timeout
      )
    end

    def multipart_post(path:, parameters: nil)
      HTTParty.post(
        uri(path: path),
        headers: headers.merge({ "Content-Type" => "multipart/form-data" }),
        body: parameters,
        timeout: request_timeout
      )
    end

    def delete(path:)
      HTTParty.delete(
        uri(path: path),
        headers: headers,
        timeout: request_timeout
      )
    end

    private

    def to_json(string)
      return unless string

      JSON.parse(string)
    rescue JSON::ParserError
      # Convert a multiline string of JSON objects to a JSON array.
      JSON.parse(string.gsub("}\n{", "},{").prepend("[").concat("]"))
    end

    # Given a proc, returns an outer proc that can be used to iterate over a JSON stream of chunks.
    # For each chunk, the inner user_proc is called giving it the JSON object. The JSON object could
    # be a data object or an error object as described in the Anthropic API documentation.
    #
    # If the JSON object for a given data or error message is invalid, it is ignored.
    #
    # @param user_proc [Proc] The inner proc to call for each JSON object in the chunk.
    # @return [Proc] An outer proc that iterates over a raw stream, converting it to JSON.
    def to_json_stream(user_proc:)
      proc do |chunk, _|
        chunk.scan(/(?:data|error): (\{.*\})/i).flatten.each do |data|
          user_proc.call(JSON.parse(data))
        rescue JSON::ParserError
          # Ignore invalid JSON.
        end
      end
    end

    # def conn(multipart: false)
    #   Faraday.new do |f|
    #     f.options[:timeout] = Anthropic.configuration.request_timeout
    #     f.request(:multipart) if multipart
    #   end
    # end

    def uri(path:)
      Anthropic.configuration.uri_base + Anthropic.configuration.api_version + path
    end

    def headers
      {
        "Content-Type" => "application/json",
        "x-api-key" => Anthropic.configuration.access_token,
        "Anthropic-Version" => Anthropic.configuration.anthropic_version
      }.merge(Anthropic.configuration.extra_headers)
    end

    def request_timeout
      Anthropic.configuration.request_timeout
    end

    # def multipart_parameters(parameters)
    #   parameters&.transform_values do |value|
    #     next value unless value.is_a?(File)
    #
    #     # Doesn't seem like Anthropic needs mime_type yet, so not worth
    #     # the library to figure this out. Hence the empty string
    #     # as the second argument.
    #     Faraday::UploadIO.new(value, "", value.path)
    #   end
    # end
  end
end
