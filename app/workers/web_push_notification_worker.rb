# frozen_string_literal: true

class WebPushNotificationWorker
  include Sidekiq::Worker

  sidekiq_options backtrace: true

  def perform(session_activation_id, notification_id)
    session_activation = SessionActivation.find(session_activation_id)
    notification = Notification.find(notification_id)

    begin
      session_activation.web_push_subscription.push(notification)
    rescue Webpush::InvalidSubscription, Webpush::ExpiredSubscription => e
      # Subscription expiration is not currently implemented in any browser
      session_activation.web_push_subscription.destroy!
      session_activation.update!(web_push_subscription: nil)

      raise e
    end
  end
end
