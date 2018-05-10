class IssueChatNotificationsWorker
  include Sidekiq::Worker
  include IssuesHelper
  include CustomFieldsHelper

  ISSUE_NOTIFICATIONS_LOG = Logger.new(Rails.root.join('log/redmine_2chat', 'telegram-issue-notifications.log'))

  def perform(telegram_id, journal_id)
    I18n.locale = Setting['default_language']

    ISSUE_NOTIFICATIONS_LOG.info "TELEGRAM_ID: #{telegram_id}, JOURNAL_ID: #{journal_id}"
    sleep 1

    journal = Journal.find(journal_id)

    message = "<b>#{journal.user.name}</b>"

    message << "\n#{details_to_strings(journal.visible_details, true).join("\n")}" if journal.details.present?

    message << "\n<pre>#{journal.notes}</pre>" if journal.notes.present?

    ISSUE_NOTIFICATIONS_LOG.info "MESSAGE: #{message}"

    TelegramMessageSenderWorker.perform_async(telegram_id, message)
  rescue ActiveRecord::RecordNotFound => e
    TELEGRAM_ISSUE_NOTIFICATIONS_LOG.error "ERROR: #{e.message}"
  end
end
