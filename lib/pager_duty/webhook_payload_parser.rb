# frozen_string_literal: true

module PagerDuty
  class WebhookPayloadParser
    def initialize(payload)
      @payload = payload
    end

    def self.call(payload)
      new(payload).call
    end

    def call
      Array(payload['messages']).map { |msg| parse_message(msg) }
    end

    private

    attr_reader :payload

    def parse_message(message)
      {
        'event' => message['event'],
        'incident' => parse_incident(message['incident'])
      }
    end

    def parse_incident(incident)
      return {} if incident.blank?

      {
        'url' => incident['html_url'],
        'incident_number' => incident['incident_number'],
        'title' => incident['title'],
        'status' => incident['status'],
        'created_at' => incident['created_at'],
        'urgency' => incident['urgency'],
        'incident_key' => incident['incident_key'],
        'assignees' => reject_empty(parse_assignees(incident)),
        'impacted_services' => reject_empty(parse_impacted_services(incident))
      }
    end

    def parse_assignees(incident)
      Array(incident['assignments']).map do |a|
        {
          'summary' => a.dig('assignee', 'summary'),
          'url' => a.dig('assignee', 'html_url')
        }
      end
    end

    def parse_impacted_services(incident)
      Array(incident['impacted_services']).map do |is|
        {
          'summary' => is['summary'],
          'url' => is['html_url']
        }
      end
    end

    def reject_empty(entities)
      Array(entities).reject { |e| e['summary'].blank? && e['url'].blank? }
    end
  end
end
