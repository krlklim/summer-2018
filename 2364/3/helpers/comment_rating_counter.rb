require 'net/https'
require 'uri'
require 'json'

# Counts rating of comments
class CommentRatingCounter
  ACESS_KEY = 'sfdfds'.freeze
  URI = 'https://westcentralus.api.cognitive.microsoft.com'.freeze
  PATH = '/text/analytics/v2.0/sentiment'.freeze

  attr_reader :uri, :documents, :request

  def initialize(texts)
    @uri = URI(URI + PATH)
    create_documents(texts)
  end

  def run
    create_answer
  end

  private

  def create_answer
    response = create_response
    JSON.parse(response.body)['documents'].each_with_object([]) do |document, ratings|
      ratings << ((document['score'] * 200).to_i - 100)
    end
  end

  def create_response
    create_request
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end
  end

  def create_documents(texts)
    @documents = { documents: [] }
    texts.each_with_index do |text, index|
      documents[:documents] << { 'id' => index.to_s, 'language' => 'ru', 'text' => text }
    end
  end

  def create_request
    @request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['Ocp-Apim-Subscription-Key'] = ACESS_KEY
    request.body = documents.to_json
  end
end
