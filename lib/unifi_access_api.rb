require 'net/http'
require 'uri'
require 'openssl'
require 'json'
require 'dotenv/load'

class UnifiAccessApi
  attr_accessor :token, :uri

  BASE_URI = 'https://192.168.0.1:12445/api/v1/developer'
  TOKEN = ENV['UNIFI_SECRET_TOKEN']

  def initialize
    @token = TOKEN
  end

  def get_users(page_num = 1)
    make_get_request('/users', { page_num: page_num, page_size: 25, 'expand[]' => %w[access_policy] })
  end

  def create_user(email)
    params = {
      first_name: email[0],
      last_name: email[1],
      employee_number: '',
      user_email: email,
      pin_code: '',
      onboard_time: Time.now.to_i
    }
    make_post_request('/users', params)
  end

  def add_access(user = {})
    params = {
      access_policy_ids: [
        '3fa34ae6-5763-4237-9341-fc1537916885'
      ]
    }
    make_put_request("/users/#{user['id']}/access_policies", params)
  end

  def remove_access(user = {})
    params = {
      access_policy_ids: []
    }
    make_put_request("/users/#{user['id']}/access_policies", params)
  end

  def invite(user = {})
    params = [{
      user_id: user['id'],
      email: user['email']
    }]
    make_post_request('/users/identity/invitations', params)
  end

  private

  def make_get_request(path, params = {})
    uri = URI.parse(BASE_URI)
    uri.path += path
    uri.query = URI.encode_www_form(params)
    request = Net::HTTP::Get.new(uri)
    request.content_type = 'application/json'
    request['Authorization'] = "Bearer #{TOKEN}"
    request['Accept'] = 'application/json'

    req_options = {
      use_ssl: uri.scheme == 'https',
      verify_mode: OpenSSL::SSL::VERIFY_NONE
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    JSON.parse(response.body)
  end

  def make_post_request(path, params = {})
  puts params
    uri = URI.parse(BASE_URI)
    uri.path += path
    puts uri
    request = Net::HTTP::Post.new(uri)
    request.content_type = 'application/json'
    request['Authorization'] = "Bearer #{TOKEN}"
    request['Accept'] = 'application/json'
    request.body = params.to_json

    req_options = {
      use_ssl: uri.scheme == 'https',
      verify_mode: OpenSSL::SSL::VERIFY_NONE
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    puts response.code
    puts response.body.inspect

    JSON.parse(response.body)
  end

  def make_put_request(path, params = {})
    uri = URI.parse(BASE_URI)
    uri.path += path
    puts uri
    request = Net::HTTP::Put.new(uri)
    request.content_type = 'application/json'
    request['Authorization'] = "Bearer #{TOKEN}"
    request['Accept'] = 'application/json'
    request.body = params.to_json

    req_options = {
      use_ssl: uri.scheme == 'https',
      verify_mode: OpenSSL::SSL::VERIFY_NONE
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    JSON.parse(response.body)
  end

  def make_delete_request(path, params = {}); end
end

#access = UnifiAccessApi.new
#access.invite({'email'=> 'williamkennedyjnr@gmail.com', 'id'=> 'e2a82e46-6f8a-4fc3-a284-506db9163aba'})
# response = access.add_access({ 'alias' => '', 'avatar_relative_path' => '', 'email' => '', 'email_status' => 'UNVERIFIED',
#                               'employee_number' => '', 'first_name' => 't', 'full_name' => 't e', 'id' => '5966f85e-0b14-45c9-a1eb-241b82e01b6c', 'last_name' => 'e', 'onboard_time' => 1_721_224_943, 'phone' => '', 'status' => 'ACTIVE', 'user_email' => 'test@email.com', 'username' => '' })
# puts response.inspect
#
# response = access.remove_access({ 'alias' => '', 'avatar_relative_path' => '', 'email' => '', 'email_status' => 'UNVERIFIED',
#                                  'employee_number' => '', 'first_name' => 't', 'full_name' => 't e', 'id' => '5966f85e-0b14-45c9-a1eb-241b82e01b6c', 'last_name' => 'e', 'onboard_time' => 1_721_224_943, 'phone' => '', 'status' => 'ACTIVE', 'user_email' => 'test@email.com', 'username' => '' })
# puts response.inspect
#
# response = access.invite({ 'alias' => '', 'avatar_relative_path' => '', 'email' => '', 'email_status' => 'UNVERIFIED',
#                           'employee_number' => '', 'first_name' => 't', 'full_name' => 't e', 'id' => '5966f85e-0b14-45c9-a1eb-241b82e01b6c', 'last_name' => 'e', 'onboard_time' => 1_721_224_943, 'phone' => '', 'status' => 'ACTIVE', 'user_email' => 'test@email.com', 'username' => '' })
# puts response.inspect
