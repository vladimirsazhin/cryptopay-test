require 'sequel'

Sequel.connect(ENV.fetch('POSTGRES_URL'))

class User < Sequel::Model
  EMAIL_REGEX = /\A[^@]+@[^@]+\z/

  plugin :uuid, field: :id
  plugin :validation_helpers
  plugin :json_serializer

  def validate
    super
    validates_presence :email, message: :email_missing
    validates_format EMAIL_REGEX, :email, allow_blank: true, message: :wrong_email_format
    validates_unique :email, message: :email_already_exists
  end
end

class Error < StandardError
  attr_reader :status, :code

  def initialize(status, code)
    @status = status
    @code = code
  end
end

class App
  USERS_ROUTE_REGEX = /\A\/users(?:\/(?<id>[^\/]+))?\z/

  def call(env)
    request = Rack::Request.new(env)

    match = USERS_ROUTE_REGEX.match(request.path_info)
    if match
      if match[:id]
        return render_user(match[:id]) if request.get?
      else
        return render_users if request.get?
        return create_and_render_user(parse_params(request)) if request.post?
      end
    end

    render_errors(404, :not_found)
  rescue Error => error
    render_errors(error.status, error.code)
  end

  def render_user(id)
    render(200, data: User.first!(id: id))
  rescue Sequel::NoMatchingRow
    render_errors(404, :not_found)
  end

  def render_users
    render(200, data: User.all)
  end

  def create_and_render_user(params)
    render(201, data: User.create(params))
  rescue Sequel::ValidationFailed => error
    render_errors(422, *error.errors.values.flatten)
  rescue Sequel::MassAssignmentRestriction
    render_errors(400, :bad_request)
  end

  def parse_params(request)
    body = request.body.read
    return {} if body.empty?
    JSON.parse(body)
  rescue JSON::ParserError
    raise Error.new(400, :bad_request)
  end

  def render(status, **data)
    [status, {'Content-Type' => 'application/json'}, [JSON.pretty_generate(data), "\n"]]
  end

  def render_errors(status, *codes)
    render(status, errors: codes.map { |code| {code: code} })
  end
end

run App.new
