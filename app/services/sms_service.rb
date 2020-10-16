require "AfricasTalking"

class SmsService
  def initialize(mobile_number, message)
    @mobile_number = mobile_number
    @message = message
  end

  def send_sms
    at = AfricasTalking::Initialize.new(ENV['AT_USERNAME'], ENV['AT_API_KEY'])
    options = {"to" => @mobile_number, "message" => @message}
    reports = at.sms.send(options)
    puts reports.inspect
  end
end